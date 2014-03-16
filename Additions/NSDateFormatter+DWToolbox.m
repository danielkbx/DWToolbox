//
//  NSDateFormatter+DWToolbox.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 16.11.12.
//
//

#import "NSDateFormatter+DWToolbox.h"

@implementation NSDateFormatter (DWToolbox)

+ (NSDateFormatter *)dateFormatterWithStyle:(NSDateFormatterStyle)style {
	return [self dateFormatterWithDateStyle:style timeStyle:style];
}

+ (NSDateFormatter *)dateFormatterWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle {
	
	static NSMutableDictionary *staticDateFormatters = nil;
	if (staticDateFormatters == nil) {
		staticDateFormatters = [[NSMutableDictionary alloc] init];
	}
	
	NSString *dateFormatterIdentifier = [NSString stringWithFormat:@"%lu-%lu",(long)dateStyle, (long)timeStyle];
	NSDateFormatter *dateFormatter = [staticDateFormatters objectForKey:dateFormatterIdentifier];
	
	if (dateFormatter == nil) {
		
		dateFormatter = [[NSDateFormatter alloc] init];
		dateFormatter.dateStyle = dateStyle;
		dateFormatter.timeStyle = timeStyle;
		[staticDateFormatters setObject:dateFormatter forKey:dateFormatterIdentifier];
		
	}
	
	return dateFormatter;
}

+ (NSDateFormatter *)relativeDateFormatter {
	static NSDateFormatter *relativeDateFormatter = nil;
	if (relativeDateFormatter == nil) {
		relativeDateFormatter = [[NSDateFormatter alloc] init];
		[relativeDateFormatter setTimeStyle:NSDateFormatterNoStyle];
		[relativeDateFormatter setDateStyle:NSDateFormatterShortStyle];
		[relativeDateFormatter setDoesRelativeDateFormatting:YES];
	}
	return relativeDateFormatter;
}

@end
