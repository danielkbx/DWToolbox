//
//  DWAlertView.h
//  dwToolbox
//
//  Created by danielkbx on 28.09.10.
//  Copyright 2010 danielkbx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^DWAlertViewBlock)(void);

typedef enum {
	DWAlertViewInvokationTimingBeforeDismissal,
	DWAlertViewInvokationTimingAfterDismissal
} DWAlertViewInvokationTiming;

@interface DWAlertViewAction: NSObject
@property (nonatomic, retain) NSString *		title;
@property (nonatomic, assign) SEL				action;
@property (nonatomic, retain) id				target;

@property (nonatomic, copy) DWAlertViewBlock	tappedBlock;
@property (nonatomic, assign) DWAlertViewInvokationTiming	invokationTiming;

+ (DWAlertViewAction *)YESAlertViewActionWithBlock:(DWAlertViewBlock)tappedBlock;
+ (DWAlertViewAction *)NOAlertViewActionWithBlock:(DWAlertViewBlock)tappedBlock;
+ (DWAlertViewAction *)CancelAlertViewActionWithBlock:(DWAlertViewBlock)tappedBlock;
+ (DWAlertViewAction *)ConfirmAlertViewActionWithBlock:(DWAlertViewBlock)tappedBlock;

- (id)initWithTitle:(NSString *)title target:(id)target action:(SEL)action;
- (id)initWithTitle:(NSString *)title block:(DWAlertViewBlock)tappedBlock;



@end

@interface DWAlertView : NSObject {

	NSMutableArray *		actions_;
	DWAlertViewAction *	cancelAction_;
	
	
}

@property (nonatomic, strong) Class backgroundViewClass;

@property (nonatomic, strong, readonly) NSString *	title;
@property (nonatomic, copy, readonly) id			message;
@property (nonatomic, copy, readonly) NSMutableAttributedString *	attributedMessage;
@property (nonatomic, strong) DWAlertViewAction *	cancelAction;

@property (nonatomic, copy) UIColor *titleColor;
@property (nonatomic, assign) CGFloat buttonHeight;

@property (nonatomic, strong) UIView *				additionalView;

@property (nonatomic, readonly) BOOL				isShown;

@property (nonatomic, assign) BOOL					dismissAutomatically;

+ (void)setScreenBackgroundColor:(UIColor *)color;
+ (UIColor *)screenBackgroundColor;

+ (UIColor *)messageColor;
+ (UIFont *)messageFont;

+ (DWAlertView *)alertViewWithTitle:(NSString *)title andMessage:(id)message;
- (id)initWithTitle:(NSString *)title andMessage:(id)message;

- (void)addAction:(DWAlertViewAction *)action;

- (DWAlertViewAction *)addActionWithTitle:(NSString *)title;
- (DWAlertViewAction *)addActionWithTitle:(NSString *)title target:(id)target action:(SEL)action;
- (DWAlertViewAction *)addActionWithTitle:(NSString *)title block:(DWAlertViewBlock)tappedBlock;

- (void)show;
- (void)dismiss;

@end

