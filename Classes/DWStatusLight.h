//
//  DWCheckbox.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 12.11.12.
//
//

#import <UIKit/UIKit.h>

@interface DWStatusLight : UIControl

@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) UIColor *lightColor;

- (id)initWithFrame:(CGRect)frame; // the size component of size is ignored

@end
