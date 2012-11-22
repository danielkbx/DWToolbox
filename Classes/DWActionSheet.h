//
//  DWActionSheet.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 15.11.12.
//
//

#import <Foundation/Foundation.h>

typedef void (^DWActionSheetItemPressedHandler)();

@interface DWActionSheetItem : NSObject

@property (nonatomic, copy, readonly) NSString *title;

- (id)initWithTitle:(NSString *)title handler:(DWActionSheetItemPressedHandler)handler;
- (id)initCancelItemWithTitle:(NSString *)title handler:(DWActionSheetItemPressedHandler)handler;

@end

@interface DWActionSheet : NSObject

- (id)initWithTitle:(NSString *)title;

- (void)addItem:(DWActionSheetItem *)item;
- (DWActionSheetItem *)addItemWithTitle:(NSString *)title handler:(DWActionSheetItemPressedHandler)handler;
- (DWActionSheetItem *)addCancelItemWithTitle:(NSString *)title handler:(DWActionSheetItemPressedHandler)handler;

- (void)showInView:(UIView *)view;
- (void)showFromToolbar:(UIToolbar *)toolbar;
- (void)showFromTabbar:(UITabBar *)tabbar;
- (void)showFromBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated;
- (void)showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated;

@end
