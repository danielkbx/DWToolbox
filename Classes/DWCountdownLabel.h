//
//  DWCountdownLabel.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 06.11.12.
//
//

#import "DWLabel.h"

@interface DWCountdownLabel : DWLabel

@property (nonatomic, copy) NSDate *date;

@property (nonatomic, copy) NSString *positivPrefixString;
@property (nonatomic, copy) NSString *positivSuffixString;
@property (nonatomic, copy) NSString *negativPrefixString;
@property (nonatomic, copy) NSString *negativSuffixString;

@end
