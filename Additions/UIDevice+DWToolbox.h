//
//  UIDevice+Additions.h
//  dwToolbox
//
//  Created by Daniel Wetzel on 19.07.12.
//
//

#import <UIKit/UIKit.h>

@interface UIDevice (DWToolbox)

- (BOOL)isIPad;
- (BOOL)has35Display;
- (BOOL)hasRetinaDisplay;
- (BOOL)hasRetina35Display;
- (BOOL)hasRetina4Display;
- (BOOL)hasRetina47Display;
- (BOOL)hasRetina55Display;

- (BOOL)isIOS5OrLater;
- (BOOL)supportsViewContainer;

- (BOOL)isIOS7OrLater;

- (BOOL)canMakeCalls;


- (void)addNetworkActivity;
- (void)removeNetworkActivity;

- (NSString *)MACAddress;
- (NSString *)uniqueDeviceIdentifier;
- (NSString *)uniqueGlobalDeviceIdentifier;

@end
