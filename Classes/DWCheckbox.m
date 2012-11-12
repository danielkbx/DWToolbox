//
//  DWCheckbox.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 12.11.12.
//
//

#import "DWCheckbox.h"

#import "UIImage+Additions.h"

@interface DWCheckbox ()

@property (nonatomic, strong) UIButton *button;

@end

@implementation DWCheckbox

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self prepareControl];
    }
    return self;
}

- (void)awakeFromNib {
	[self prepareControl];
}

- (UIButton *)button {
	if (self->_button == nil) {
		self->_button = [UIButton buttonWithType:UIButtonTypeCustom];
		self->_button.frame = self.bounds;
		self->_button.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		self->_button.backgroundColor = [UIColor clearColor];
		[self->_button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:self->_button];
	}
	return self->_button;
}

- (void)prepareControl {
	self.backgroundColor = [UIColor clearColor];

		
	UIImage *image1 = [UIImage imageNamed:@"checkbox" bundle:[NSBundle toolboxAssetsBundle]];
	[image1 writeAsPNGToFile:@"/Users/daniel/bild.png"];
	if (image1) {
		[self setImage:image1 forState:UIControlStateNormal];
	}

	UIImage *image2 = [UIImage imageNamed:@"checkbox_selected" bundle:[NSBundle toolboxAssetsBundle]];
	[image2 writeAsPNGToFile:@"/Users/daniel/bild2.png"];
	if (image2) {
		[self setImage:image2 forState:UIControlStateSelected];
	}

	//self.button.selected = YES;
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
	[self.button setImage:image forState:state];

}

- (UIImage *)imageForState:(UIControlState)state {
	return [self.button imageForState:state];
}

- (void)buttonPressed {
	self.selected = !self.selected;
}

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];
	self.button.selected = selected;
}

- (void)setEnabled:(BOOL)enabled {
	[super setEnabled:enabled];
	self.button.enabled = enabled;
}

@end
