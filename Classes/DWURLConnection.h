//
//  DWURLConnection.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 05.10.12.
//
//

#import <Foundation/Foundation.h>

@class DWUploadField;

typedef void (^DWURLConnectionCompletionHandler)(NSData *receivedData, NSDictionary *responseHeaders, NSUInteger statusCode, NSError *error);

typedef enum {
	DWURLConnectionStateIdle,
	DWURLConnectionStateRunning,
	DWURLConnectionStateFinished,
	DWURLConnectionStateFailed,
	DWURLConnectionStateCanceled
} DWURLConnectionState;

typedef enum {
	DWURLConnectionGETMethod,
	DWURLConnectionPOSTMethod,
	DWURLConnectionFormPOSTMethod
} DWURLConnectionMethod;

@interface DWURLConnection : NSObject

@property (nonatomic, strong, readonly) NSURL *URL;
@property (nonatomic, readonly) DWURLConnectionState state;

@property (nonatomic, strong) NSString *userAgent;

@property (nonatomic, assign) DWURLConnectionMethod method;

+ (DWURLConnection *)connectionWithURL:(NSURL *)URL;
+ (DWURLConnection *)startConnectionWithURL:(NSURL *)URL completion:(DWURLConnectionCompletionHandler)completion;

- (id)initWithURL:(NSURL *)URL;

#pragma mark - Headers

- (void)addHeaderValue:(NSString *)header forKey:(NSString *)key;
- (void)removeHeaderValueForKey:(NSString *)key;
- (NSString *)headerValueForKey:(NSString *)key;

#pragma mark - Post Data

/**
 Using any of the addUpload… methods causes the method type to be set to FormPOST
 */
- (void)addUploadField:(DWUploadField *)field;
- (void)removeUploadField:(DWUploadField *)field;

- (DWUploadField *)addUploadValue:(NSString *)value forKey:(NSString *)key;
- (DWUploadField *)addUploadImage:(UIImage *)image forKey:(NSString *)key filename:(NSString *)filename;

/**
 Using appendPostData: causes the method to be set to POST
 */
- (void)appendPostData:(NSData *)postData;	// using this causes only this data to be sent (and not any assigned post values)

#pragma mark - Action

- (void)startWithCompletionHandler:(DWURLConnectionCompletionHandler)completion;
- (void)cancel;

@end
