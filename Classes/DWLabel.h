//
//  DWLabel.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 23.10.12.
//
//

#import <Foundation/Foundation.h>

#import "DWTextStyle.h"

typedef enum {
	DWLabelVerticalAlignmentMiddle,
	DWLabelVerticalAlignmentTop,
	DWLabelVerticalAlignmentBottom
} DWLabelVerticalAlignment;

@interface DWLabel : UILabel

@property (nonatomic, assign) DWLabelVerticalAlignment verticalAlignment;
@property (nonatomic, assign) CGFloat verticalContentOffset;

@property (nonatomic, strong) DWTextStyle *textStyle;
@property (nonatomic, copy) NSString *textStyleKey;

@end