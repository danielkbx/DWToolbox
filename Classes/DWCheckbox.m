//
//  DWCheckbox.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 12.11.12.
//
//

#import "DWCheckbox.h"

#import "UIImage+DWToolbox.h"
#import "NSBundle+DWToolbox.h"
#import "UIColor+DWToolbox.h"

#define kDWCheckboxSize CGSizeMake(24.0f,24.0f)

@interface DWCheckbox ()

@property (nonatomic, copy) UIColor *borderColor;
@property (nonatomic, copy) UIColor *checkmarkColor;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation DWCheckbox

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:(CGRect){frame.origin,kDWCheckboxSize}];
    if (self) {
		[self prepareControl];
    }
    return self;
}

- (void)awakeFromNib {
	[self prepareControl];
	[self sizeToFit];
}

- (void)prepareControl {
	self.backgroundColor = [UIColor clearColor];
	self.borderColor = [UIColor colorWithWhite:0.7f alpha:1.0f];
	self.checkmarkColor = [UIColor colorFromHexString:@"#3dba72"];
	
	self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonPressed)];
	[self addGestureRecognizer:self.tapGesture];
}

- (void)buttonPressed {
	self.checked = !self.checked;
}

- (void)setChecked:(BOOL)checked {
	self->_checked = checked;
	[self setNeedsDisplay];
}

- (void)setEnabled:(BOOL)enabled {
	[super setEnabled:enabled];
	self.tapGesture.enabled = enabled;
}

- (CGSize)sizeThatFits:(CGSize)size {
	return kDWCheckboxSize;
}

- (void)drawRect:(CGRect)rect {
	
	CGRect circleRect = CGRectInset(self.bounds, 6.0f, 6.0f);
	
	UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:circleRect];
	
	[self.borderColor setStroke];
	circlePath.lineWidth = 2.0f;
	[circlePath stroke];
	
	if (self.checked) {
		
		CGRect baseCircle = CGRectInset(self.bounds, 2.0f, 2.0f);
		CGFloat offsetX = 0.0f;
		CGFloat offsetY = -3.0f;
		
		UIBezierPath *checkmarkPath = [UIBezierPath bezierPath];
		[checkmarkPath moveToPoint:CGPointMake(baseCircle.origin.x + 7.0f + offsetX, baseCircle.origin.y + 7.0f + offsetY)];
		[checkmarkPath addLineToPoint:CGPointMake(CGRectGetMidX(baseCircle) + offsetX, CGRectGetMaxY(baseCircle) - 5.0f + offsetY)];
		[checkmarkPath addLineToPoint:CGPointMake(CGRectGetMaxX(baseCircle) - 4.0f + offsetX, baseCircle.origin.y + 4.0f + offsetY)];

		checkmarkPath.lineWidth = 2.0f;
		[self.checkmarkColor setStroke];
		[checkmarkPath stroke];
	}
	
	
}

@end
