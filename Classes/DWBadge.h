//
//  DWBadge.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 05.11.12.
//
//

#import <UIKit/UIKit.h>

@interface DWBadge : UIView

@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, assign) CGFloat cornerRadius;

@property (nonatomic, copy) UIColor *textColor;
@property (nonatomic, copy) UIFont *font;

@property (nonatomic, copy) NSString *badgeText;

@end
