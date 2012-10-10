//
//  DWActivityManager.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 10.10.12.
//
//

#import <Foundation/Foundation.h>

typedef enum {
	DWActivityItemTypeDefault,
	DWActivityItemTypeProgress,
	DWActivityItemTypeTextOnly
} DWActivityItemType;

@interface DWActivityItem : NSObject

@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, readonly) DWActivityItemType type;

@property (nonatomic, assign) float progress;

@property (nonatomic, readonly) BOOL isVisible;

@property (nonatomic, copy) UIColor *backgroundColor;
@property (nonatomic, copy) UIColor *textColor;

- (id)initWithType:(DWActivityItemType)type title:(NSString *)title;
- (void)hide;

@end

@interface DWActivityManager : NSObject

@property (nonatomic, strong, readonly) DWActivityItem *visibleActivityItem;

+ (DWActivityManager *)sharedManager;

- (void)addActivityItem:(DWActivityItem *)item;
- (DWActivityItem *)addActivityWithTitle:(NSString *)title;
- (DWActivityItem *)addActivityWithTitle:(NSString *)title progress:(float)progress;

- (void)removeActivityItem:(DWActivityItem *)item;

@end
