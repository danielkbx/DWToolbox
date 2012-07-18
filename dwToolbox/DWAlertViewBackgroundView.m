//
//  DWAlertViewBackgroundView.m
//  dwToolbox
//
//  Created by Daniel Wetzel on 12.07.12.
//
//

#import "DWAlertViewBackgroundView.h"
#import <QuartzCore/QuartzCore.h>

@implementation DWAlertViewBackgroundView {
		
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor whiteColor];
		self.layer.cornerRadius = 10.0f;
    }
    return self;
}

@end
