//
//  DWBadge.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 05.11.12.
//
//

#import "DWBadge.h"

@interface DWBadge() {
	
	UIColor *_badgeBackgroundColor;
	
}


@end

@implementation DWBadge

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self prepareUI];
    }
    return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	[self prepareUI];
}

- (void)prepareUI {
	[super setBackgroundColor:[UIColor clearColor]];
	self.cornerRadius = 5.0f;
	self.insets = UIEdgeInsetsMake(2.0f, 7.0f, 2.0f, 7.0f);
	self.backgroundColor = [UIColor colorWithWhite:0.5f alpha:1.0f];
	self.textColor = [UIColor whiteColor];
	self.font = [UIFont boldSystemFontOfSize:13.0f];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
	if (backgroundColor != self->_badgeBackgroundColor) {
		self->_badgeBackgroundColor = [backgroundColor copy];
		[self setNeedsDisplay];
	}
}

- (UIColor *)backgroundColor {
	return self->_badgeBackgroundColor;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
	if (cornerRadius != self->_cornerRadius) {
		self->_cornerRadius = MIN(10.0f,MAX(0.0f,cornerRadius));
		[self setNeedsDisplay];
	}
}

- (CGSize)sizeThatFits:(CGSize)size {
	CGSize textSize = [self.badgeText sizeWithFont:self.font];
	return (CGSize){textSize.width + self.insets.left + self.insets.right, textSize.height + self.insets.top + self.insets.bottom};
}

//- (void)setBadgeText:(NSString *)badgeText {
//	if (![badgeText isEqualToString:self->_badgeText]) {
//		self->_badgeText = [badgeText copy];
//		CGSize size = [self sizeThatFits:CGSizeZero];
//		
//	}
//}

- (void)drawRect:(CGRect)rect
{
	//CGContextRef context = UIGraphicsGetCurrentContext();
	
	[self.backgroundColor setFill];
	
	UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.cornerRadius];
	[path fill];
	
	[self.textColor setFill];
	[self.badgeText drawAtPoint:CGPointMake(self.insets.left, self.insets.top) withFont:self.font];
	
}


@end
