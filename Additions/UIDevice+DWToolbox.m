//
//  UIDevice+Additions.m
//  dwToolbox
//
//  Created by Daniel Wetzel on 19.07.12.
//
//

#import "UIDevice+DWToolbox.h"

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include "NSString+DWToolbox.h"

static NSUInteger staticNetworkActivity;

@implementation UIDevice (DWToolbox)

- (BOOL)isIPad
{
	return (self.userInterfaceIdiom == UIUserInterfaceIdiomPad);
}

- (BOOL)hasRetinaDisplay {
	UIScreen *mainScreen = [UIScreen mainScreen];
	return [mainScreen respondsToSelector:@selector(displayLinkWithTarget:selector:)] && (mainScreen.scale == 2.0);
}

- (BOOL)hasRetina4Display {
	UIScreen *mainScreen = [UIScreen mainScreen];
	return (self.hasRetinaDisplay && mainScreen.bounds.size.height > 480.0f);
}

- (BOOL)isIOS5OrLater
{
	return ([self.systemVersion floatValue] >= 5.0) ? YES : NO;
}

- (BOOL)supportsViewContainer
{
	return [self isIOS5OrLater];
}

- (BOOL)canMakeCalls {
	return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://+11111"]];
}

- (void)addNetworkActivity
{
	staticNetworkActivity++;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)removeNetworkActivity
{
	if (staticNetworkActivity > 0)
	{
		staticNetworkActivity--;
	}
	if (staticNetworkActivity == 0)
	{
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
}

- (NSString *)MACAddress {
    
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}

- (NSString *) uniqueDeviceIdentifier{
    NSString *macaddress = [[UIDevice currentDevice] MACAddress];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *stringToHash = [NSString stringWithFormat:@"%@%@",macaddress,bundleIdentifier];
    NSString *uniqueIdentifier = [stringToHash MD5];
    return uniqueIdentifier;
}

- (NSString *) uniqueGlobalDeviceIdentifier{
    NSString *macaddress = [[UIDevice currentDevice] MACAddress];
    NSString *uniqueIdentifier = [macaddress MD5];
    return uniqueIdentifier;
}


@end
