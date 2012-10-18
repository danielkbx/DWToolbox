//
//  DWActivityManager.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 10.10.12.
//
//

#import "DWActivityManager.h"
#import "UIView+Additions.h"
#import <QuartzCore/QuartzCore.h>
#import "CAKeyframeAnimation+Additions.h"

static UIColor *backgroundColor;
static UIColor *textColor;

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
		[self setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.8f]];
	}
}

+ (void)setTextColor:(UIColor *)color {
	if (color != nil) {
		textColor = [color copy];
	} else {
		[self setTextColor:[UIColor whiteColor]];
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
	
	UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
	item.view.center = DWMakeCenter(CGPointMake(rootView.bounds.size.width / 2.0f, rootView.bounds.size.height / 2.0f), item.view.frame.size);
	
	CATransform3D lastTransform;
	CAAnimation *bumpInAnimation = [CAKeyframeAnimation bumpInAnimation:&lastTransform];
	[item.view.layer addAnimation:bumpInAnimation forKey:@"intro"];
	item.view.layer.transform = lastTransform;
	
	[item itemWillAppear];
	[rootView addSubview:item.view];

}

- (void)hideCurrentItem {
	if (self.visibleActivityItem != nil) {
		
		CATransform3D lastTransform;
		CAAnimation *bumpOutAnimation = [CAKeyframeAnimation bumpOutAnimation:&lastTransform];
		[bumpOutAnimation setDelegate:self];
		[bumpOutAnimation setRemovedOnCompletion:NO];
		[self.visibleActivityItem.view.layer addAnimation:bumpOutAnimation forKey:@"outro"];
		self.visibleActivityItem.view.layer.transform = lastTransform;
		
	}
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
	if ([self.visibleActivityItem.view.layer animationForKey:@"outro"] == anim) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.visibleActivityItem.view removeFromSuperview];
			self.visibleActivityItem = nil;
			[self showNextItem];
		});
	}
}

- (void)activityItemDidChangeProgress:(DWActivityItem *)item {
	
}

@end
