//
//  DWURLConnection.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 05.10.12.
//
//

#import <Foundation/Foundation.h>

typedef void (^DWURLConnectionCompletionHandler)(NSData *receivedData, NSDictionary *responseHeaders, NSUInteger statusCode, NSError *error);

typedef enum {
	DWURLConnectionStateIdle,
	DWURLConnectionStateRunning,
	DWURLConnectionStateFinished,
	DWURLConnectionStateFailed,
	DWURLConnectionStateCanceled
} DWURLConnectionState;

@interface DWURLConnection : NSObject

@property (nonatomic, strong, readonly) NSURL *URL;
@property (nonatomic, readonly) DWURLConnectionState state;

@property (nonatomic, strong) NSString *userAgent;

+ (DWURLConnection *)connectionWithURL:(NSURL *)URL;
- (id)initWithURL:(NSURL *)URL;

#pragma mark - Headers

- (void)addHeaderValue:(NSString *)header forKey:(NSString *)key;
- (void)removeHeaderValueForKey:(NSString *)key;
- (NSString *)headerValueForKey:(NSString *)key;

#pragma mark - Action

- (void)startWithCompletionHandler:(DWURLConnectionCompletionHandler)completion;
- (void)cancel;

@end
