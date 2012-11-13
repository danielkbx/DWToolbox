//
//  DWLabel.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 23.10.12.
//
//

#import "DWLabel.h"

@implementation DWLabel

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.verticalAlignment = DWLabelVerticalAlignmentMiddle;
		self.verticalContentOffset = 0.0f;
    }
    return self;
}

- (void)setVerticalAlignment:(DWLabelVerticalAlignment)verticalAlignment {
	
	if (verticalAlignment != self->_verticalAlignment) {
		self->_verticalAlignment = verticalAlignment;
		[self setNeedsDisplay];
	}
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];

	CGFloat verticalOffset = (textRect.size.height < (self.bounds.size.height + self.verticalContentOffset)) ? self.verticalContentOffset : 0.0f;
	
    switch (self.verticalAlignment) {
        case DWLabelVerticalAlignmentTop:
            textRect.origin.y = bounds.origin.y + verticalOffset;
            break;
        case DWLabelVerticalAlignmentBottom:
            textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height + verticalOffset;
            break;
        case DWLabelVerticalAlignmentMiddle:
        default:
            textRect.origin.y = bounds.origin.y + (bounds.size.height - textRect.size.height) / 2.0 + verticalOffset;
			break;
    }
    return textRect;
}

-(void)drawTextInRect:(CGRect)rect {
    CGRect actualRect = [self textRectForBounds:rect limitedToNumberOfLines:self.numberOfLines];
    [super drawTextInRect:actualRect];
}

@end