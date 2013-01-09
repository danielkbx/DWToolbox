//
//  DWURLConnection.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 05.10.12.
//
//

#import <Foundation/Foundation.h>

@class DWUploadField;
/** The completion handler which gets invoked when the connection finishes or fails. */
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

/** DWURLConnection is a replacement for NSURLConnection with upload and block support.
 
 Besides supporting blocks and uploads it does not need a request object to be build. Simply create an instance with an URL.
 */
@interface DWURLConnection : NSObject

/** @name Creating a connection */

/** Creates a new connection object with the provided URL.
 
 The connection does not get started automatically.
 @param URL The URL to connect to.
 */
+ (DWURLConnection *)connectionWithURL:(NSURL *)URL;
/** Creates a new connection and starts downloading.
 
 After creating the object, the download is started immediately using the provied block.
 @param URL The URL to connecto to.
 @param completion The block to invoke when the connection finishes or fails.
 */
+ (DWURLConnection *)startConnectionWithURL:(NSURL *)URL completion:(DWURLConnectionCompletionHandler)completion;

/** Initializes a new connection object with the provied URL.
 
 The connection does not get started automatically.
 @param URL The URL to connect to.
 */
- (id)initWithURL:(NSURL *)URL;

/** The URL of the connection. */
@property (nonatomic, strong, readonly) NSURL *URL;

#pragma mark - Headers

/** @name Settings */

/** The User Agent of the connection. 
 
 When you provided a custom header named "User-Agent" this setting is ignored.
 */
@property (nonatomic, strong) NSString *userAgent;

/** Adds a HTTP header to the connection.
 
 This has no effect if the connection has been started already.
 @param header The value of the header.
 @param key The key (or name) of the header.
 */
- (void)addHeaderValue:(NSString *)header forKey:(NSString *)key;

/** Removes an HTTP header.
 
 This has no effect if the connection has been started already.
 @param key The key (or name) of the header to remove.
 */
- (void)removeHeaderValueForKey:(NSString *)key;

/** Returns the value of an HTTP header.
 @param key The key (or name) of the header to return.
 */
- (NSString *)headerValueForKey:(NSString *)key;

#pragma mark - Post Data

/** The HTTP method used for connecting.
 
 The following values are valid
 
 - DWURLConnectionGETMethod
 - DWURLConnectionPOSTMethod
 - DWURLConnectionFormPOSTMethod

 If you choose DWURLConnectionFormPOSTMethod, the provided data is wrapped in a HTML form structure to simulate a browser upload.
 
 @see addUploadField:
 @see addUploadValue:forKey:
 */
@property (nonatomic, assign) DWURLConnectionMethod method;

/** Adds an upload field to the connection.
 
 @warning Using this method sets the HTTP method to DWURLConnectionFormPOSTMethod.
 @param field The upload field to add.
 */
- (void)addUploadField:(DWUploadField *)field;

/** Removes an upload field.
 @param field The field to remove.
 */
- (void)removeUploadField:(DWUploadField *)field;

/** Adds an upload field created from the provided string.
 
 The method conveniently creates a new upload field with a string and returns it after adding it to the connection.
 @warning Using this method sets the HTTP method to DWURLConnectionFormPOSTMethod.
 @param value The string to add as upload.
 @param key The name of the upload field.
 @see addUploadField:
 */
- (DWUploadField *)addUploadValue:(NSString *)value forKey:(NSString *)key;

/** Adds an upload field created from the provided image.
 
 The method conveniently creates a new upload field with an image and returns it after adding it to the connection.
 @warning Using this method sets the HTTP method to DWURLConnectionFormPOSTMethod.
 @param image The image to add as upload.
 @param key The name of the upload field.
 @param filename The filename to send to the server.
 @see addUploadField:
 */
- (DWUploadField *)addUploadImage:(UIImage *)image forKey:(NSString *)key filename:(NSString *)filename;

/** Appends any data to an upload connection.
 
 @warning Using this method sets the HTTP method to DWURLConnectionPOSTMethod. Any fields added to the connection are ignored and NOT sent.
 @param postData The data to upload.
 */
- (void)appendPostData:(NSData *)postData;

#pragma mark - Action

/** @name Starting the connection */

/** Starts the connection (if not yet)
 
 When a completion block is provided it gets executed when the connection finishes or fails.
 @param completion The block to invoke when finishing or failing.
 */
- (void)startWithCompletionHandler:(DWURLConnectionCompletionHandler)completion;

/** Cancels the connection. */
- (void)cancel;

/** The current state of the connection. */
@property (nonatomic, readonly) DWURLConnectionState state;

@end
