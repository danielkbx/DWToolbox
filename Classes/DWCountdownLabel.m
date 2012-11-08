//
//  DWCountdownLabel.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 06.11.12.
//
//

#import "DWCountdownLabel.h"

@implementation DWCountdownLabel {
	
	NSTimer *_updateTimer;
	
}

- (id)init {
	if ((self = [super init])) {
		[self prepareString];
	}
	return self;
}

- (void)awakeFromNib {
	[self prepareString];
}

- (void)prepareString {
	self.positivPrefixString = NSLocalizedString(@"in ", @"Countdown");
	self.positivSuffixString = nil;
	self.negativPrefixString = nil;
	self.negativSuffixString = NSLocalizedString(@" ago", @"Countdown");

}

- (void)setText:(NSString *)text {
	[super setText:text];
	if (text != nil) {
		if (self->_updateTimer) {
			[self->_updateTimer invalidate];
			self->_updateTimer = nil;
		}
	}
}

- (void)setDate:(NSDate *)date {
	if (date != self.date) {
		self->_date = [date copy];
		if (date != nil) {
			if (self->_updateTimer == nil) {
				self->_updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
																	  target:self
																	selector:@selector(updateTextFromDate)
																	userInfo:nil
																	 repeats:YES];
			}
			[self updateTextFromDate];
		}
	}
}

- (void)updateTextFromDate {
	NSTimeInterval interval = [self.date timeIntervalSinceNow];

	BOOL wasPast = (interval < 0);
	if (wasPast) {
		interval = interval * -1;
	}
	
	NSInteger days = (int)floor(interval / (60 * 60 * 24));
	interval = interval - (days * 60 * 60 * 24);
	NSInteger hours = (int)floor(interval / (60 * 60));
	interval = interval - (hours * 60 *60);
	NSInteger minutes = (int)floor(interval / 60);
	interval = interval - (minutes * 60);
	NSInteger seconds = (int)interval;

	NSString *text = nil;
	if (days >= 2) {
		text = [NSString stringWithFormat:NSLocalizedString(@"%i days", @"Countdown"),days];
	} else if (days == 1) {
		text = [NSString stringWithFormat:NSLocalizedString(@"%1 day, %i hours", @"Countdown"),hours];
	} else {
		if (hours > 1) {
			text = [NSString stringWithFormat:NSLocalizedString(@"%i hours", @"Countdown"),hours];
		} else if (hours == 1) {
			text = [NSString stringWithFormat:NSLocalizedString(@"1 hour, %i minutes", @"Countdown"),minutes];
		} else {
			if (minutes > 1) {
				text = [NSString stringWithFormat:NSLocalizedString(@"%i minutes", @"Countdown"),minutes];
			} else if (minutes == 1) {
				text = [NSString stringWithFormat:NSLocalizedString(@"1 minute, %i seconds", @"Countdown"),seconds];
			} else {
				text = [NSString stringWithFormat:NSLocalizedString(@"%i seconds", @"Countdown"),seconds];
			}
		}
	}
	
	NSString *prefix = nil;
	NSString *suffix = nil;
	
	if (wasPast) {
		prefix = (self.negativPrefixString) ? self.negativPrefixString : @"";
		suffix = (self.negativSuffixString) ? self.negativSuffixString : @"";
	} else {
		prefix = (self.positivPrefixString) ? self.positivPrefixString : @"";
		suffix = (self.positivSuffixString) ? self.positivSuffixString : @"";
	}

	text = [NSString stringWithFormat:NSLocalizedString(@"%@%@%@", @"Countdown"),prefix, text, suffix];
	
	[super setText:text];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
 