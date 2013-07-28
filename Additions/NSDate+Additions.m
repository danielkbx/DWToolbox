//
//  UIColor+Additions.m
//  dwToolbox
//
//  Created by Daniel Wetzel on 28.08.13.
//
//


#import "NSDate+Additions.h"

@implementation NSDate (Additions)

- (NSString*)stringFromDateWithStyle:(NSDateFormatterStyle)style localeIdentifier:(NSString*)localeIdent
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	NSLocale *deLocale = [[NSLocale alloc] initWithLocaleIdentifier:localeIdent];
	[formatter setLocale:deLocale];
	[formatter setDateStyle:style];
	NSString *stringDate = [formatter stringFromDate:self];	
	return stringDate;
}


- (NSString*)stringFromDateWithLongStyle
{
	
	// Set Date String
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	NSLocale *myLocale = [NSLocale currentLocale];
	[formatter setLocale:myLocale];
	[formatter setDateStyle:NSDateFormatterLongStyle];
	NSString *stringDate = [formatter stringFromDate:self];
	
	return stringDate;
}


- (NSString*)stringFromDateWithFullStyle
{
	
	// Set Date String
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	NSLocale *myLocale = [NSLocale currentLocale];
	[formatter setLocale:myLocale];
	[formatter setDateStyle:NSDateFormatterFullStyle];
	NSString *stringDate = [formatter stringFromDate:self];
	
	return stringDate;
}

- (NSDate *)noon {
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [gregorian components:(NSYearCalendarUnit |
														  NSMonthCalendarUnit |
														  NSDayCalendarUnit)
												fromDate:self];
	return [[gregorian dateFromComponents:components] dateByAddingTimeInterval:12*60*60];
}

- (NSDate *)midnight
{
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [gregorian components:(NSYearCalendarUnit |
														  NSMonthCalendarUnit |
														  NSDayCalendarUnit)
												fromDate:self];
	components.hour = 0;
	components.minute = 0;
	components.second = 0;
	return [gregorian dateFromComponents:components];
}

+ (NSDate *)today {
	return [[NSDate date] noon];
}

+ (NSDate *)yesterday {
	return [[NSDate dateWithTimeIntervalSinceNow:(-1*24*60*60)] noon];
}

+ (NSDate *)tomorrow {
	return [[NSDate dateWithTimeIntervalSinceNow:(24*60*60)] noon];
}

- (BOOL)isBeforeDate:(NSDate *)otherDate
{
    if ([self isEqualToDate:otherDate]) return NO;
    
	return ([self earlierDate:otherDate] == self);
}

- (BOOL)isAfterDate:(NSDate *)otherDate
{
    if ([self isEqualToDate:otherDate]) return NO;
    
	return ([self earlierDate:otherDate] == otherDate);
}

- (BOOL)isToday {
	return ([[self noon] timeIntervalSinceDate:[[NSDate date] noon]] == 0);
}


- (BOOL)isEqualToTheDay:(NSDate*)date
{
    NSCalendar *selfCalender = [[NSCalendar alloc]
                                  initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *selfComps = [selfCalender components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit
                                                      fromDate:self];
    NSCalendar *givenCalender = [[NSCalendar alloc]
                                 initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *givenComps = [givenCalender components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit 
                                                    fromDate:date];
        
    if (selfComps.day == givenComps.day &&
        selfComps.year == givenComps.year &&
        selfComps.month == givenComps.month)
    {
        return YES;
    }
    
    return NO;
}

+ (NSDate *)dayBeforeDay:(NSDate *)day {
	NSDate *noon = [day noon];
	NSDate *dayBefore = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:noon];
	return [dayBefore noon];
}

+ (NSDate *)dayAfterDay:(NSDate *)day {
    assert(day != nil);
    NSDate *dayAfter = [NSDate dateWithTimeInterval:(60*60*24) sinceDate:[day noon]];
	return [dayAfter noon];

}

- (NSString *)relativeTimeText {
	
	if ([self isToday]) {
		NSTimeInterval delta = ([self timeIntervalSinceNow] * -1);

		if (delta < 0) {
			return NSLocalizedString(@"Noch nicht",@"Calendar");
		} else if (delta < 60) {
			return NSLocalizedString(@"eben",@"Calendar");
		} else if (delta < (60 * 60)) {
			return [NSString stringWithFormat:NSLocalizedString(@"vor %i min",@"Calendar"),(int)(delta / 60)];
		} else if (delta < (60 * 60 * 10)) {
			NSInteger hours = (int)(delta / 60 / 60);
			if (hours == 1) {
				return NSLocalizedString(@"vor 1 h",@"Calendar");
			} else {
				return [NSString stringWithFormat:NSLocalizedString(@"vor %i h",@"Calendar"),(int)(delta / 60 / 60)];
			}
		} else {
			return nil;
		}
	} else {
		return nil;
	}
}

@end
