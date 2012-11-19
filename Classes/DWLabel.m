//
//  DWLabel.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 23.10.12.
//
//

#import "DWLabel.h"
#import "DWTextStyle_Private.h"

#import "DWConfiguration.h"
#import "UIFont+DWToolbox.h"

NSInteger textStyleObervanceContext;

@implementation DWLabel

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.verticalAlignment = DWLabelVerticalAlignmentMiddle;
		self.verticalContentOffset = 0.0f;
    }
    return self;
}

- (void)dealloc {
	self.textStyle = nil;	// needed to remove the observance
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

- (void)drawTextInRect:(CGRect)rect {
    CGRect actualRect = [self textRectForBounds:rect limitedToNumberOfLines:self.numberOfLines];
    [super drawTextInRect:actualRect];
}

- (void)layoutSubviews {
	
	if (self.textStyle) {
		self.font = self.textStyle.font;
		self.textColor = self.textStyle.color;
	}
	
	[super layoutSubviews];
}

- (void)setTextStyle:(DWTextStyle *)textStyle {
	if (![textStyle isEqualToTextStyle:self.textStyle]) {
		
		[self.textStyle removeObserver:self forKeyPath:@"font" context:&textStyleObervanceContext];
		[self.textStyle removeObserver:self forKeyPath:@"color" context:&textStyleObervanceContext];
		
		self->_textStyle = textStyle;
		
		if (textStyle.color == nil) {
			textStyle.color = [UIColor blackColor];
		}
		
		if (textStyle.font == nil) {
			textStyle.font = [UIFont customFontWithSize:[UIFont labelFontSize]];
		}
		
		[self.textStyle addObserver:self forKeyPath:@"font" options:NSKeyValueObservingOptionNew context:&textStyleObervanceContext];
		[self.textStyle addObserver:self forKeyPath:@"color" options:NSKeyValueObservingOptionNew context:&textStyleObervanceContext];
		
		[self setNeedsLayout];
	}
}

- (void)setFont:(UIFont *)font {
	
	if (font != self.textStyle.font) {
		self.textStyleKey = nil;
	}
	[super setFont:font];
}

- (void)setTextStyleKey:(NSString *)textStyleKey {
	if (![self->_textStyleKey isEqualToString:textStyleKey]) {
		self->_textStyleKey = [textStyleKey copy];
		DWTextStyle *style = [DWTextStyle textStyleWithKey:textStyleKey];
		self.textStyle = style;
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == &textStyleObervanceContext) {
		[self setNeedsLayout];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

@end