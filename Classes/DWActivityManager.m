//
//  DWActivityManager.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 10.10.12.
//
//

#import "DWActivityManager.h"
#import "UIView+DWToolbox.h"
#import <QuartzCore/QuartzCore.h>
#import "CAKeyframeAnimation+DWToolbox.h"

#import "DWWindow.h"

#import <UIDevice+DWToolbox.h>
#import <DWLabel.h>

static UIColor *backgroundColor;
static UIColor *textColor;

static DWWindow *containerWindow;


@interface DWActivityItem()

@property (nonatomic, strong, readwrite) NSString *title;
@property (nonatomic, readwrite) DWActivityItemType type;

@property (nonatomic, weak) DWActivityManager *manager;
@property (nonatomic, strong) UIView *view;

@property (nonatomic, strong) NSTimer *hideTimer;

- (void)itemWillAppear;

@end

@interface DWActivityManager()

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong, readwrite) DWActivityItem *visibleActivityItem;

- (void)activityItemDidChangeProgress:(DWActivityItem *)item;

@end

@implementation DWActivityItem

+ (void)initialize {
	[self setBackgroundColor:nil];
	[self setTextColor:nil];
}

+ (void)setBackgroundColor:(UIColor *)color {
	if (color != nil) {
		backgroundColor = [color copy];
	} else {
		
		UIColor *defaultColor = [UIColor colorWithWhite:0.0f alpha:0.8f];
		if ([UIDevice currentDevice].isIOS7OrLater) {
			defaultColor = [UIColor colorWithWhite:1.0f alpha:0.5f];
		}
		[self setBackgroundColor:defaultColor];
	}
}

+ (void)setTextColor:(UIColor *)color {
	if (color != nil) {
		textColor = [color copy];
	} else {
		UIColor *defaultColor = [UIColor whiteColor];
		if ([UIDevice currentDevice].isIOS7OrLater) {
			
			UIViewController *rootController = [UIApplication sharedApplication].keyWindow.rootViewController;
			if (rootController) {
				UIView *rootView = rootController.view;
				if (rootView) {
					defaultColor = rootView.tintColor;
				}
			}
			
			if (defaultColor == nil) {
				defaultColor = [UIColor blackColor];
			}
			
		}
		[self setTextColor:defaultColor];
	}
}


- (id)initWithType:(DWActivityItemType)type title:(NSString *)title {
	if ((self = [super init])) {
		self.type = type;
		self.title = title;
		self.backgroundColor = backgroundColor;
		self.textColor = textColor;
	}
	return self;
}

- (void)setProgress:(float)progress {
	if (progress != self.progress) {
		if (progress < 0) progress = 0;
		if (progress > 1) progress = 1;
		self->_progress = progress;
		[self.manager activityItemDidChangeProgress:self];
	}
}

- (void)hide {
	[self.hideTimer invalidate];
	self.hideTimer = nil;
	[self.manager removeActivityItem:self];
}

- (BOOL)isVisible {
	return (self.manager.visibleActivityItem == self);
}

- (void)itemWillAppear {
	if (self.hideTimeout > 0) {
		self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:self.hideTimeout
														  target:self
														selector:@selector(hideTimerFired)
														userInfo:nil
														 repeats:NO];
	}
}

- (void)hideTimerFired {
	[self hide];
}

- (UIView *)view {
	if (self->_view == nil) {
		
		if ([UIDevice currentDevice].isIOS7OrLater) {
			
			UIFont *textFont = [UIFont boldSystemFontOfSize:12.0f];
			
			UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 100.0f)];
			view.backgroundColor = self.backgroundColor;
			
			if (self.type == DWActivityItemTypeDefault) {
				
				UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
				activityView.center = CGPointMake(ceilf(activityView.frame.size.width / 2.0f) + 10, (view.bounds.size.height - activityView.frame.size.height) / 2.0f + 35.0f);
				activityView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
				activityView.color = self.textColor;
				[activityView startAnimating];
				[view addSubview:activityView];
				
				CGFloat offsetX = CGRectGetMaxX(activityView.frame) + 10.0f;
				CGFloat textWidth = view.bounds.size.width - offsetX - 10.0f;
				
				
				CGSize textSize = [self.title sizeWithFont:textFont forWidth:textWidth lineBreakMode:NSLineBreakByWordWrapping];
				CGFloat viewHeight = MAX(activityView.frame.size.height, textSize.height);
				view.frame = CGRectMake(0.0f, 0.0f, 320.0f, viewHeight + 44.0f);
				
				
				DWLabel *textLabel = [[DWLabel alloc] initWithFrame:CGRectMake(offsetX, 30.0f, textSize.width, textSize.height)];
				textLabel.numberOfLines = 0;
				textLabel.backgroundColor = [UIColor clearColor];
				textLabel.verticalAlignment = DWLabelVerticalAlignmentTop;
				textLabel.text = self.title;
				textLabel.font = textFont;
				textLabel.textColor = self.textColor;
				[view addSubview:textLabel];
				
				if (textSize.height <= activityView.frame.size.height) {
					textLabel.center = CGPointMake(textLabel.center.x, activityView.center.y);
				}
				
			} else if (self.type == DWActivityItemTypeProgress) {
				
				
				view.frame = CGRectMake(0.0f, 0.0f, 320.0f, 60.0f);
				
				UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
				activityView.center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));
				activityView.color = self.textColor;
				[activityView startAnimating];
				[view addSubview:activityView];
				
			} else if (self.type == DWActivityItemTypeTextOnly) {
				
				CGSize textSize = [self.title sizeWithFont:textFont forWidth:view.bounds.size.width - 20.0f lineBreakMode:NSLineBreakByWordWrapping];
				CGFloat viewHeight = MAX(20.0f, textSize.height);
				view.frame = CGRectMake(0.0f, 0.0f, 320.0f, viewHeight + 20.0f);
				
				DWLabel *textLabel = [[DWLabel alloc] initWithFrame:CGRectMake(10.0f, 10.0f, textSize.width, textSize.height)];
				textLabel.numberOfLines = 0;
				textLabel.backgroundColor = [UIColor clearColor];
				textLabel.verticalAlignment = DWLabelVerticalAlignmentMiddle;
				textLabel.text = self.title;
				textLabel.font = textFont;
				textLabel.textColor = self.textColor;
				[view addSubview:textLabel];
				
			}
			
			self->_view = view;
			
		} else {
			CGRect viewFrame = CGRectMake(0.0f, 0.0f, 200.0f, 200.0f);
			UIFont *textFont = [UIFont systemFontOfSize:16.0f];
			
			UIActivityIndicatorView *activityIndicator = nil;
			
			CGSize textSize = [self.title sizeWithFont:textFont constrainedToSize:CGSizeMake(250.0f, 400.0f) lineBreakMode:NSLineBreakByWordWrapping];
			if (self.type == DWActivityItemTypeTextOnly) {
				
				if (textSize.width < 100) textSize.width = 100;
				if (textSize.height < 60.0f) textSize.height = 60.0f;
				viewFrame.size = (CGSize){textSize.width + 20.0f, textSize.height + 20.0f};
				
			} else if (self.type == DWActivityItemTypeDefault) {
				if (textSize.width < 100) textSize.width = 100;
				activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
				[activityIndicator startAnimating];
				viewFrame.size = (CGSize){textSize.width + 20.0f, textSize.height + activityIndicator.frame.size.height + 30.0f};
				
			}
			
			UIView *view = [[UIView alloc] initWithFrame:viewFrame];
			view.layer.cornerRadius = 10.0f;
			view.backgroundColor = self.backgroundColor;
			
			UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, 10.0f)];
			textLabel.textColor = self.textColor;
			textLabel.font = textFont;
			textLabel.text = self.title;
			textLabel.backgroundColor = [UIColor clearColor];
			textLabel.textAlignment = NSTextAlignmentCenter;
			textLabel.numberOfLines = 0;
			textLabel.lineBreakMode = NSLineBreakByWordWrapping;
			
			if (self.type == DWActivityItemTypeTextOnly) {
				
				textLabel.frame = CGRectInset(view.bounds, 10.0f, 10.0f);
				
			} else if (self.type == DWActivityItemTypeDefault) {
				
				textLabel.frame = CGRectMake(10.0f, view.bounds.size.height - textSize.height - 10.0f, view.bounds.size.width - 20.0f, textSize.height);
				if (self.title) {
					activityIndicator.center = CGPointMake(view.bounds.size.width / 2.0f, activityIndicator.frame.size.height / 2.0f + 10.0f);
				} else {
					activityIndicator.center = DWMakeCenter(CGPointMake(view.bounds.size.width / 2.0f, view.bounds.size.height / 2.0f), activityIndicator.frame.size);
				}
				[view addSubview:activityIndicator];
			}
			
			[view addSubview:textLabel];
			
			self->_view = view;
			
		}
	}
	return self->_view;
}

@end



@implementation DWActivityManager

+ (DWActivityManager *)sharedManager {
	
	static DWActivityManager *sharedManager = nil;
	if (sharedManager == nil) {
		sharedManager = [[DWActivityManager alloc] init];
	}
	return sharedManager;
}

- (void)addActivityItem:(DWActivityItem *)item {
	assert(item);
	item.manager = self;
	
	if (self.items == nil) {
		self.items = [[NSMutableArray alloc] init];
	}
	[self.items addObject:item];
	if (self.items.count == 1) {
		[self showNextItem];
	}
}

- (DWActivityItem *)addActivityWithTitle:(NSString *)title {
	DWActivityItem *item = [[DWActivityItem alloc] initWithType:DWActivityItemTypeDefault title:title];
	[self addActivityItem:item];
	return item;
}

- (DWActivityItem *)addActivityWithTitle:(NSString *)title timeout:(NSTimeInterval)timeout {
	DWActivityItem *item = [self addActivityWithTitle:title];
	item.hideTimeout = timeout;
	return item;
}

- (DWActivityItem *)addActivityWithTitle:(NSString *)title progress:(float)progress {
	DWActivityItem *item = [[DWActivityItem alloc] initWithType:DWActivityItemTypeProgress title:title];
	item.progress = progress;
	[self addActivityItem:item];
	return item;
}

- (void)removeActivityItem:(DWActivityItem *)item {
	assert(item);
	[self.items removeObject:item];
	
	if (self.items.count == 0) {
		self.items = nil;
	}
	
	if (item == self.visibleActivityItem) {
		[self hideCurrentItem];
	}
}

- (void)showNextItem {
	if (self.items.count > 0) {
		if (self.visibleActivityItem == nil) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[self showItem:[self.items objectAtIndex:0]];
			});
		} else {
			[self hideCurrentItem];
		}
	}
}

- (void)showItem:(DWActivityItem *)item {
	
	self.visibleActivityItem = item;
	
	if (containerWindow == nil) {
		containerWindow = [[DWWindow alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.frame];
		containerWindow.backgroundColor = [UIColor clearColor];
		containerWindow.windowLevel = UIWindowLevelNormal;
		[containerWindow makeKeyAndVisible];
	}
		
	if ([UIDevice currentDevice].isIOS7OrLater) {
		
		item.view.center = DWMakeCenter(CGPointMake(containerWindow.bounds.size.width / 2.0f, item.view.frame.size.height / -2.0f), item.view.frame.size);
		[containerWindow addSubview:item.view];
		
		[UIView animateWithDuration:0.2f animations:^{
			item.view.center = DWMakeCenter(CGPointMake(containerWindow.bounds.size.width / 2.0f, item.view.frame.size.height / 2.0f), item.view.frame.size);
		}];
		
		
	} else {
		
		item.view.center = DWMakeCenter(CGPointMake(containerWindow.bounds.size.width / 2.0f, containerWindow.bounds.size.height / 2.0f), item.view.frame.size);
		
		CATransform3D lastTransform;
		CAAnimation *bumpInAnimation = [CAKeyframeAnimation bumpInAnimation:&lastTransform];
		[item.view.layer addAnimation:bumpInAnimation forKey:@"intro"];
		item.view.layer.transform = lastTransform;
		
		[item itemWillAppear];
		item.view.center = DWMakeCenterInSize(containerWindow.bounds.size, item.view.frame.size);
		[containerWindow addSubview:item.view];
	}
	
}

- (void)hideCurrentItem {
	if (self.visibleActivityItem != nil) {
		
		if ([UIDevice currentDevice].isIOS7OrLater) {
			
			[UIView animateWithDuration:0.2f animations:^{
				self.visibleActivityItem.view.center = DWMakeCenter(CGPointMake(containerWindow.bounds.size.width / 2.0f, self.visibleActivityItem.view.frame.size.height / -2.0f), self.visibleActivityItem.view.frame.size);
			} completion:^(BOOL finished) {
				[self.visibleActivityItem.view removeFromSuperview];
				self.visibleActivityItem = nil;
				if (self.items.count > 0) {
					[self showNextItem];
				} else {
					[containerWindow resignKeyWindow];
					containerWindow = nil;
				}
			}];
						
		} else {
			
			CATransform3D lastTransform;
			CAAnimation *bumpOutAnimation = [CAKeyframeAnimation bumpOutAnimation:&lastTransform];
			[bumpOutAnimation setDelegate:self];
			[bumpOutAnimation setRemovedOnCompletion:NO];
			[self.visibleActivityItem.view.layer addAnimation:bumpOutAnimation forKey:@"outro"];
			self.visibleActivityItem.view.layer.transform = lastTransform;
		}
	}
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
	if ([self.visibleActivityItem.view.layer animationForKey:@"outro"] == anim) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.visibleActivityItem.view removeFromSuperview];
			self.visibleActivityItem = nil;
			if (self.items.count > 0) {
				[self showNextItem];
			} else {
				
				[containerWindow resignKeyWindow];
				containerWindow = nil;
				
			}
		});
	}
}

- (void)activityItemDidChangeProgress:(DWActivityItem *)item {
	
}

@end
