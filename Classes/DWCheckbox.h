//
//  DWCheckbox.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 12.11.12.
//
//

#import <UIKit/UIKit.h>

@interface DWCheckbox : UIControl

- (void)setImage:(UIImage *)image forState:(UIControlState)state;
- (UIImage *)imageForState:(UIControlState)state;

@end
