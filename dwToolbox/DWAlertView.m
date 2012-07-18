//
//  DWAlertView.m
//  dwToolbox
//
//  Created by danielkbx on 28.09.10.
//  Copyright 2010 danielkbx. All rights reserved.
//

#import "DWAlertView.h"
#import "CAKeyframeAnimation+Additions.h"
#import "TTTAttributedLabel.h"
#import <CoreText/CoreText.h>
#import "NSAttributedString+Attributes.h"

#import "UIView+Additions.h"
#import "DWAlertViewBackgroundView.h"

@interface DWAlertViewAction() {
	
}

- (void)invoke;

@end

@implementation DWAlertViewAction

@synthesize title;
@synthesize action;
@synthesize target;
@synthesize tappedBlock;
@synthesize invokationTiming;

+ (DWAlertViewAction *)YESAlertViewActionWithBlock:(DWAlertViewBlock)tappedBlock
{
	return [[DWAlertViewAction alloc] initWithTitle:NSLocalizedString(@"Ja", @"General")
																   block:tappedBlock];
}

+ (DWAlertViewAction *)NOAlertViewActionWithBlock:(DWAlertViewBlock)tappedBlock
{
	return [[DWAlertViewAction alloc] initWithTitle:NSLocalizedString(@"Nein", @"General")
											  block:tappedBlock];
	
}

+ (DWAlertViewAction *)CancelAlertViewActionWithBlock:(DWAlertViewBlock)tappedBlock
{
	return [[DWAlertViewAction alloc] initWithTitle:NSLocalizedString(@"Abbrechen", @"General")
											  block:tappedBlock];

}

+ (DWAlertViewAction *)ConfirmAlertViewActionWithBlock:(DWAlertViewBlock)tappedBlock
{
	return [[DWAlertViewAction alloc] initWithTitle:NSLocalizedString(@"Bestätigen", @"General")
											  block:tappedBlock];

}

- (id)init
{
	if ((self = [super init]))
	{
		self.invokationTiming = DWAlertViewInvokationTimingAfterDismissal;
	}
	return self;
}

- (id)initWithTitle:(NSString *)theTitle target:(id)theTarget action:(SEL)theAction
{
	if ((self = [self init]))
	{
		self.title = theTitle;
		self.target = theTarget;
		self.action = theAction;
	}
	return self;
}

- (id)initWithTitle:(NSString *)theTitle block:(DWAlertViewBlock)theTappedBlock
{
	if ((self = [self init]))
	{
		self.title = theTitle;
		self.tappedBlock = theTappedBlock;
	}
	return self;
}

- (void)invoke
{
	if (self.target != nil && self.action != NULL)
	{
		[self.target performSelectorOnMainThread:self.action
									  withObject:nil
								   waitUntilDone:NO];
	}
	else if (self.tappedBlock != nil)
	{
		self.tappedBlock();
	}
}

@end

//
// DWAlertView
// ----------------------------------------------------------
//

static NSMutableArray * DWAlertViewInstances;
static UIView * coverView;

@interface DWAlertView() {
	BOOL			didInvokeAction_;
	UIView *		view_;
	BOOL			isShown_;
}
@property (nonatomic, strong, readwrite) NSString *	title;
@property (nonatomic, copy, readwrite) id	message;
@property (nonatomic, copy, readwrite) NSMutableAttributedString *	attributedMessage;

@property (nonatomic, readonly) UIView *	view;

- (DWAlertViewAction *)actionWithTitle:(NSString *)title;

- (void)handleButtonPressed:(UIButton *)button;
- (void)handleCancelButtonPressed:(UIButton *)button;

+ (NSMutableArray *)instances;
+ (void)registerAlertView:(DWAlertView *)alertView;
+ (void)deregisterAlertView:(DWAlertView *)alertView;

- (void)handleKeyboardAppears:(NSNotification *)notification;
- (void)handleKeyboardDisappears:(NSNotification *)notification;

@end

@implementation DWAlertView

@synthesize backgroundViewClass = backgroundViewClass_;

@synthesize title;
@synthesize message;
@synthesize attributedMessage;

@synthesize cancelAction = cancelAction_;
@synthesize additionalView;

@synthesize view = view_;

@synthesize titleColor;
@synthesize buttonHeight;

@synthesize dismissAutomatically;

#pragma mark - Creation & Lifecycle

+ (DWAlertView *)alertViewWithTitle:(NSString *)title andMessage:(id)message
{
	DWAlertView *newAlertView = [[DWAlertView alloc] initWithTitle:title andMessage:message];
	return newAlertView;
}

- (id)init {
	return [self initWithTitle:nil andMessage:nil];
}

- (id)initWithTitle:(NSString *)theTitle andMessage:(id)theMessage
{
	if ((self = [super init]))
	{
		self.backgroundViewClass = [DWAlertViewBackgroundView class];
		self->actions_ = [[NSMutableArray alloc] init];
		self.title = theTitle;
		self.message = theMessage;
		self.dismissAutomatically = YES;
		self.titleColor = [UIColor darkGrayColor];
		self.buttonHeight = 44.0f;
	}
	return self;
	
}

- (void)setMessage:(id)newMessage
{
	if (newMessage != self.message)
	{
		if ([newMessage isKindOfClass:[NSString class]])
		{
			self->attributedMessage = [[NSMutableAttributedString alloc] initWithString:newMessage];
			[self.attributedMessage setTextAlignment:kCTCenterTextAlignment lineBreakMode:NSLineBreakByWordWrapping];
			[self.attributedMessage setTextColor:[UIColor grayColor]];
			[self.attributedMessage setFont:[UIFont systemFontOfSize:15.0f]];
			self->message = [newMessage copy];
		}
		else if ([newMessage isKindOfClass:[NSAttributedString class]])
		{
			self->attributedMessage = [newMessage copy];
			self->message = [attributedMessage string];
		}
	}
}

#pragma mark - Background

- (void)setBackgroundViewClass:(Class)backgroundViewClass
{
	if (!self.isShown)
	{
		if (backgroundViewClass != backgroundViewClass_)
		{
			if ([backgroundViewClass isSubclassOfClass:[UIView class]])
			{
				self->backgroundViewClass_ = backgroundViewClass;
			}
		}
	}
}

#pragma mark - Actions

- (void)setCancelAction:(DWAlertViewAction *)cancelAction
{
	if (self->cancelAction_ != cancelAction)
	{
		self->cancelAction_ = cancelAction;
	}
}

- (void)addAction:(DWAlertViewAction *)action
{
	[self->actions_ addObject:action];
}

- (DWAlertViewAction *)addActionWithTitle:(NSString *)theTitle {
	return [self addActionWithTitle:theTitle block:nil];
}

- (DWAlertViewAction *)addActionWithTitle:(NSString *)theTitle target:(id)target action:(SEL)action
{
	DWAlertViewAction *newAction = [[DWAlertViewAction alloc] initWithTitle:theTitle
																	   target:target
																	   action:action];
	[self addAction:newAction];
	return newAction;
}

- (DWAlertViewAction *)addActionWithTitle:(NSString *)theTitle block:(DWAlertViewBlock)tappedBlock
{
	DWAlertViewAction *newAction = [[DWAlertViewAction alloc] initWithTitle:theTitle
																		block:tappedBlock];
	[self addAction:newAction];
	return newAction;
}

- (DWAlertViewAction *)actionWithTitle:(NSString *)theTitle
{
	if ([self->cancelAction_.title isEqualToString:theTitle])
	{
		return self->cancelAction_;
	}
	else
	{
		for (DWAlertViewAction *action in self->actions_)
		{
			if ([action.title isEqualToString:theTitle])
			{
				return action;
				break;
			}
		}
	}
	return nil;
}

#pragma mark - Showing & Hiding

- (BOOL)isShown
{
	return self->isShown_;
}

- (void)show
{
	if (!self.isShown)
	{
		self->isShown_ = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handleKeyboardAppears:)
													 name:UIKeyboardWillShowNotification
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handleKeyboardDisappears:)
													 name:UIKeyboardWillHideNotification
												   object:nil];
		
		[[self class] registerAlertView:self];
		self->didInvokeAction_ = NO;
	}
}

- (void)dismiss
{
	if (self.isShown)
	{
		self->isShown_ = NO;
		[[NSNotificationCenter defaultCenter] removeObserver:self];
		[[self class] deregisterAlertView:self];
	}
}

#pragma mark - View

- (UIView *)view
{
	if (self->view_ == nil)
	{
		NSMutableArray *actions = [NSMutableArray arrayWithArray:self->actions_];
		if (self.cancelAction != nil && self.cancelAction.title != nil)
		{
			[actions addObject:self.cancelAction];
		}
		
		self->view_ = [[self.backgroundViewClass alloc] initWithFrame:CGRectMake(50.0f, 50.0f, 300.0f, 500.0f)];

		UIView *contentView = [[UIView alloc] initWithFrame:CGRectInset(self->view_.bounds, 5.0f, 5.0f)];
		[self->view_ addSubview:contentView];
		
		
		UIView *buttonsCoverView = [[UIView alloc] initWithFrame:CGRectZero];
		
		if ([actions count] > 0)
		{
			buttonsCoverView.frame = CGRectMake(0.0f, 0.0f, 0.0f, self.buttonHeight);
		}
		
		buttonsCoverView.backgroundColor = [UIColor clearColor];

		CGFloat positionX = 0.0f;
		CGFloat positionY = 0.0f;
		NSUInteger i = 0;

		for (DWAlertViewAction *action in actions)
		{
			UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
			[actionButton setTitle:action.title forState:UIControlStateNormal];
			
			[actionButton sizeToFit];
			actionButton.frame = CGRectMake(positionX, 0.0f, actionButton.frame.size.width + 10.0f, buttonsCoverView.bounds.size.height);
			positionX = CGRectGetMaxX(actionButton.frame) + 10.0f;
			
			[buttonsCoverView addSubview:actionButton];
			buttonsCoverView.frame = CGRectMake(buttonsCoverView.frame.origin.x,
												buttonsCoverView.frame.origin.y,
												buttonsCoverView.frame.size.width + actionButton.frame.size.width,
												buttonsCoverView.frame.size.height);
			
			[actionButton addTarget:self action:@selector(handleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
			actionButton.tag = i;
			i++;
		}
		
		if (i > 0)
		{
			buttonsCoverView.frame = CGRectMake(buttonsCoverView.frame.origin.x,
												buttonsCoverView.frame.origin.y,
												buttonsCoverView.frame.size.width + (7.0f * i),
												buttonsCoverView.frame.size.height);

		}
		
		CGFloat viewWidth = MAX(self->view_.frame.size.width,buttonsCoverView.frame.size.width + 20.0f);
		CGFloat viewHeight = 500.0f;
		self->view_.frame = CGRectMake(self->view_.frame.origin.x,
									   self->view_.frame.origin.y,
									   viewWidth,
									   viewHeight);
		
		buttonsCoverView.center = DWMakeCenter(CGPointMake(self->view_.bounds.size.width / 2.0f, self->view_.bounds.size.height - 100.0f),
											   self->view_.bounds.size);
		[contentView addSubview:buttonsCoverView];
		
		CGFloat contentWidth = self->view_.bounds.size.width - 20.0f;
		
		positionY = 15.0f;
		if ([self.title length] > 0)
		{
			UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f,
																			0.0f,
																			contentWidth,
																			50.0f)];
			positionY = CGRectGetMaxY(titleLabel.frame);
			titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
			titleLabel.textColor = self.titleColor;
			titleLabel.backgroundColor = [UIColor clearColor];
			titleLabel.text = self.title;
			titleLabel.textAlignment = NSTextAlignmentCenter;
			[contentView addSubview:titleLabel];
		}
		
		UIFont *messageFont = [UIFont systemFontOfSize:15.0f];

		TTTAttributedLabel *messageLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
		messageLabel.font = messageFont;
		messageLabel.backgroundColor = [UIColor clearColor];
		messageLabel.textColor = [UIColor whiteColor];
		messageLabel.textAlignment = NSTextAlignmentCenter;
		messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
		messageLabel.numberOfLines = 0;

		messageLabel.text = self.attributedMessage;
		CGSize messageSize = [messageLabel sizeThatFits:CGSizeMake(contentWidth, 500.0f)];
		
		messageLabel.frame = CGRectMake(10.0f,
										positionY + 5.0f,
										contentWidth,
										messageSize.height);
		positionY = CGRectGetMaxY(messageLabel.frame);
		
//		CGSize messageSize = [self.message sizeWithFont:messageFont
//									  constrainedToSize:CGSizeMake(contentWidth, 500.0f)
//										  lineBreakMode:UILineBreakModeWordWrap];
		
		[contentView addSubview:messageLabel];
		
		if (self.additionalView)
		{
			self.additionalView.frame = CGRectMake(0.0f,positionY + 10.0f , self.additionalView.frame.size.width, self.additionalView.frame.size.height);
			self.additionalView.center = DWMakeCenter(CGPointMake(self->view_.bounds.size.width / 2.0f, self.additionalView.center.y),
													  contentView.bounds.size);
			[contentView addSubview:self.additionalView];
			positionY = CGRectGetMaxY(self.additionalView.frame);
		}
		
		if ([actions count] > 0)
		{
			buttonsCoverView.frame = CGRectMake(roundf((contentView.bounds.size.width - buttonsCoverView.frame.size.width) / 2.0f), positionY + 20.0f,
												buttonsCoverView.frame.size.width, buttonsCoverView.frame.size.height);
			positionY = CGRectGetMaxY(buttonsCoverView.frame);
		}
		
		self->view_.bounds = CGRectMake(0.0f, 0.0f,
										self->view_.bounds.size.width,
										positionY + 10.0f);
		contentView.frame = self->view_.bounds;
		
		if ([actions count] > 0)
		{
			buttonsCoverView.center = CGPointMake(roundf(contentView.bounds.size.width / 2.0f), buttonsCoverView.center.y);
		}
		
		UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self->view_.bounds, -1.0f, -1.0f) cornerRadius:10.0f];
		self->view_.layer.shadowPath = shadowPath.CGPath;
		self->view_.layer.shadowColor = [UIColor blackColor].CGColor;
		self->view_.layer.shadowOpacity = 0.7;
		self->view_.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
		
		if (self.cancelAction != nil && self.cancelAction.title == nil) {
			
			self->view_.bounds = CGRectMake(self->view_.bounds.origin.x, self->view_.bounds.origin.y,
											self->view_.bounds.size.width + 20.0f,
											self->view_.bounds.size.height + 20.0f);
			contentView.center = DWMakeCenter(CGPointMake(self->view_.bounds.size.width / 2.0f, self->view_.bounds.size.height / 2.0f),
											  self->view_.bounds.size);
			self->view_.layer.shadowOffset = CGSizeMake(10.0f, 10.0f);
			
			UIImage *cancelImage = [UIImage imageNamed:@"btn_cancel"];
			UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
			[cancelButton setImage:cancelImage forState:UIControlStateNormal];
			[cancelButton addTarget:self action:@selector(handleCancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
			cancelButton.frame = (CGRect){CGPointZero,cancelImage.size};
			cancelButton.center = contentView.frame.origin;
			[self->view_ addSubview:cancelButton];
			
		}
		
	}
	return self->view_;
}

- (void)handleButtonPressed:(UIButton *)button
{
	NSMutableArray *actions = [NSMutableArray arrayWithArray:self->actions_];
	
	NSUInteger tag = button.tag;
	if ([actions count] > tag)
	{
		DWAlertViewAction *action = [actions objectAtIndex:tag];
		[action invoke];
	}
	
	if (self.dismissAutomatically)
	{
		[[self class] deregisterAlertView:self];
	}
}

- (void)handleCancelButtonPressed:(UIButton *)button
{
	if (self.cancelAction)
	{
		[self.cancelAction invoke];
	}
	if (self.dismissAutomatically)
	{
		[[self class] deregisterAlertView:self];
	}
}

#pragma mark - Instance management

+ (NSMutableArray *)instances
{
	if (DWAlertViewInstances == nil)
	{
		DWAlertViewInstances = [[NSMutableArray alloc] init];
	}
	return DWAlertViewInstances;
}

+ (void)registerAlertView:(DWAlertView *)alertView
{
	if (alertView != nil)
	{

		if ([self instances].count == 0)
		{
			if (coverView == nil)
			{
				coverView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.frame];
				coverView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
				coverView.backgroundColor = [UIColor clearColor];
				coverView.userInteractionEnabled = YES;
			}
			[[UIApplication sharedApplication].keyWindow.rootViewController.view insertSubview:coverView atIndex:0];
		}
		
		[[self instances] addObject:alertView];
				
		UIView *alertViewView = alertView.view;
		alertViewView.layer.shouldRasterize = NO;
		alertViewView.center = CGPointMake(roundf(coverView.bounds.size.width / 2.0f), roundf(coverView.bounds.size.height / 2.0f));
		[coverView addSubview:alertViewView];
	
		CATransform3D endTransform;
		CAKeyframeAnimation *bumpInAnimation = [CAKeyframeAnimation bumpInAnimation:&endTransform];
		[alertViewView.layer addAnimation:bumpInAnimation forKey:@"transform"];
		alertViewView.layer.transform = endTransform;

	}
}

+ (void)deregisterAlertView:(DWAlertView *)alertView
{
	
	[[NSNotificationCenter defaultCenter] removeObserver:alertView];
	
	[UIView animateWithDuration:0.2 animations:^{
		alertView.view.alpha = 0.0f;
	} completion:^(BOOL finished) {
		
		[alertView.view removeFromSuperview];
		[[self instances] removeObject:alertView];
		
		if ([self instances].count == 0) {
			[coverView removeFromSuperview];
		}
	}];		
	
}

// MARK: - Keyboard

- (void)handleKeyboardAppears:(NSNotification *)notification
{
	NSValue *rectValue = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	CGRect keyboardRect = [rectValue CGRectValue];
	keyboardRect = [[UIApplication sharedApplication].keyWindow convertRect:keyboardRect fromView:self.view.superview];
	
	
	NSNumber *animationDurationValue = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
	CGFloat animationDuration = [animationDurationValue floatValue];
	
	CGFloat keyboardDistanceToCenter = 32.0f;
	CGFloat hiddenHeight = (self.view.frame.size.height / 2.0f) - keyboardDistanceToCenter;
	
	[UIView animateWithDuration:animationDuration
					 animations:^{
						 self.view.center = CGPointMake(self.view.superview.bounds.size.width / 2.0f,
														self.view.superview.bounds.size.height / 2.0f - hiddenHeight - 20.0f); 

					 }];
}

- (void)handleKeyboardDisappears:(NSNotification *)notification
{
	NSNumber *animationDurationValue = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
	CGFloat animationDuration = [animationDurationValue floatValue];
	[UIView animateWithDuration:animationDuration
					 animations:^{
						self.view.center = CGPointMake(self.view.superview.bounds.size.width / 2.0f,
													   self.view.superview.bounds.size.height / 2.0f); 
					 }];	
}

@end