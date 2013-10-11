//
//  DWURLConnection.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 05.10.12.
//
//

#import "DWURLConnection.h"

#import "NSObject+DWToolbox.h"
#import "DWUploadField.h"

#import <UIApplication+DWToolbox.h>

@interface DWURLConnection() <NSURLConnectionDataDelegate>

@property (nonatomic, strong, readwrite) NSURL *URL;
@property (nonatomic, readwrite) DWURLConnectionState state;
@property (nonatomic, strong) NSMutableDictionary *requestHeaders;
@property (nonatomic, strong) DWURLConnectionCompletionHandler completionHandler;

@property (nonatomic, strong) NSURLConnection *connection;

@property (nonatomic, assign) NSUInteger responseStatusCode;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSDictionary *receivedHeaders;

@property (nonatomic, strong) NSMutableArray *uploadFields;
@property (nonatomic, strong) NSMutableData *postData;

@end

@implementation DWURLConnection

- (id)initWithURL:(NSURL *)URL {
	if ((self = [super init])) {
		self.URL = URL;
		self.state = DWURLConnectionStateIdle;
	}
	return self;
}

+ (DWURLConnection *)connectionWithURL:(NSURL *)URL {
	return [[[self class] alloc] initWithURL:URL];
}

+ (DWURLConnection *)startConnectionWithURL:(NSURL *)URL completion:(DWURLConnectionCompletionHandler)completion {
	DWURLConnection *connection = [self connectionWithURL:URL];
	[connection startWithCompletionHandler:completion];
	return connection;
}

- (void)dealloc {
	[self cancel];
}

#pragma mark - Headers

- (void)addHeaderValue:(NSString *)header forKey:(NSString *)key {
	assert(header);
	assert(key);
	@synchronized(self) {
		if (self.requestHeaders == nil) {
			self.requestHeaders = [[NSMutableDictionary alloc] init];
		}
		[self.requestHeaders setObject:header forKey:key];
	}
}

- (void)removeHeaderValueForKey:(NSString *)key {
	assert(key);
	[self.requestHeaders removeObjectForKey:key];
	if (self.requestHeaders.count == 0) {
		self.requestHeaders = nil;
	}
}

- (NSString *)headerValueForKey:(NSString *)key {
	assert(key);
	@synchronized(self) {
		return [self.requestHeaders objectForKey:key];
	}
}

- (NSString *)userAgent {
	if (self->_userAgent == nil) {
		NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
		NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
		NSString *systemName = [UIDevice currentDevice].systemName;;
		NSString *systemVersion = [UIDevice currentDevice].systemVersion;
		return [NSString stringWithFormat:@"%@/%@ (%@, %@)",appName,appVersion,systemName,systemVersion];
	} else {
		return self->_userAgent;
	}
}

#pragma mark - Post Data

- (void)addUploadField:(DWUploadField *)field {
	if (field) {
		
		self.method = DWURLConnectionFormPOSTMethod;
		self.postData = nil;
		
		if (self.uploadFields == nil) {
			self.uploadFields = [[NSMutableArray alloc] init];
		}
		
		[self.uploadFields addObject:field];
		
	}
}

- (void)removeUploadField:(DWUploadField *)field {
	if (field) {
		[self.uploadFields removeObject:field];
		
		if (self.uploadFields.count == 0) {
			self.uploadFields = nil;
		}
	}
}

- (DWUploadField *)addUploadValue:(NSString *)value forKey:(NSString *)key {
	assert(value);
	assert(key);
	
	DWUploadField *field = [[DWUploadField alloc] initWithIdentifier:key stringValue:value];
	if (field) {
		[self addUploadField:field];
	}
	return field;
}

- (DWUploadField *)addUploadImage:(UIImage *)image forKey:(NSString *)key filename:(NSString *)filename {
	assert(image);
	assert(key);
	
	DWUploadField *field = [[DWUploadField alloc] initWithIdentifier:key image:image filename:filename];
	if (field) {
		[self addUploadField:field];
	}
	return field;
}

- (void)appendPostData:(NSData *)postData {
	assert(postData);
	
	self.method = DWURLConnectionPOSTMethod;
	
	if (self.postData == nil) {
		self.postData = [[NSMutableData alloc] init];
	}
	[self.postData appendData:postData];
	
	self.uploadFields = nil;
	
}

#pragma mark - Action

- (void)startWithCompletionHandler:(DWURLConnectionCompletionHandler)completion {
	@synchronized(self) {
		if (self.state == DWURLConnectionStateIdle ||
			self.state == DWURLConnectionStateCanceled) {
			self.completionHandler = completion;
			
			if (self.URL) {
				
				[[UIApplication sharedApplication] increaseActivityCounter];
				
				NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.URL];
								
				[request addValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
				
				for (NSString *headerKey in self.requestHeaders) {
					[request addValue:[self.requestHeaders valueForKey:headerKey] forHTTPHeaderField:headerKey];
				}
				
				if (self.method == DWURLConnectionPOSTMethod) {
					
					[request setHTTPMethod:@"POST"];
					[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
					[request setHTTPBody:self.postData];
					
				} else  if (self.method == DWURLConnectionFormPOSTMethod) {
					
					NSString *boundary = [NSString stringWithFormat:@"DWURLConnectionFormBoundary-%@", [[NSUUID UUID] UUIDString]];
					NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
					
					[request setHTTPMethod:@"POST"];
					[request setValue:contentType forHTTPHeaderField:@"Content-Type"];
					if (self.postData.length > 0) {
						[request setHTTPBody:self.postData];
					} else {
						
						NSMutableData *postData = [NSMutableData data];
						
						for (NSUInteger i = 0; i < self.uploadFields.count; i++) {
						
							DWUploadField *field = [self.uploadFields objectAtIndex:i];
							
							if (i > 0) {
								[postData appendData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
							}
							[postData appendData:[[NSString stringWithFormat:@"--%@\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
														
							NSString *disposition = field.contentDisposition;
							NSString *contentType = field.contentType;
							if (disposition && contentType.length > 0) {
								
								disposition = [NSString stringWithFormat:@"Content-Disposition: %@\n", disposition];
								[postData appendData:[disposition dataUsingEncoding:NSUTF8StringEncoding]];
								
								if (![contentType isEqualToString:@"text/plain"]) {
									contentType = [NSString stringWithFormat:@"Content-Type: %@\n",contentType];
									[postData appendData:[contentType dataUsingEncoding:NSUTF8StringEncoding]];
									
								}
								[postData appendData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
								[postData appendData:field.dataValue];
							}
						}
						
						NSString *footer = [NSString stringWithFormat:@"\n--%@--",boundary];
						[postData appendData:[footer dataUsingEncoding:NSUTF8StringEncoding]];
						
						[request setHTTPBody:postData];
					}
					
				}
				
				self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
				self.state = DWURLConnectionStateRunning;
				[self.connection start];
				
			} else {
				self.completionHandler(nil,nil,0,[[NSError alloc] initWithDomain:@"NoURLGivenErrorDomain" code:0 userInfo:nil]);
			}
		}
	}
}

- (void)cancel {
	if (self.state == DWURLConnectionStateRunning) {
		[self.connection cancel];
		self.connection = nil;
		self.receivedData = nil;
		self.receivedHeaders = nil;
		self.state = DWURLConnectionStateCanceled;
	}
}

#pragma mark - NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	if (connection == self.connection) {
		if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
			NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
			
			self.responseStatusCode = HTTPResponse.statusCode;
			self.receivedHeaders = [HTTPResponse.allHeaderFields copy];
			
			self.receivedData = [[NSMutableData alloc] init];
		}
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	if (connection == self.connection) {
		[self.receivedData appendData:data];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	self.state = DWURLConnectionStateFinished;
	self.connection = nil;
	if (self.completionHandler) {
		dispatch_async(dispatch_get_main_queue(), ^{
			self.completionHandler([NSData dataWithData:self.receivedData],[NSDictionary dictionaryWithDictionary:self.receivedHeaders],self.responseStatusCode, nil);
			self.receivedData = nil;
			self.receivedHeaders = nil;
		});
	} else {
		self.receivedData = nil;
		self.receivedHeaders = nil;
	}
	[[UIApplication sharedApplication] decreaseActivityCounter];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	self.state = DWURLConnectionStateFailed;
	self.connection = nil;
	if (self.completionHandler) {
		dispatch_async(dispatch_get_main_queue(), ^{
			self.completionHandler([NSData dataWithData:self.receivedData],[NSDictionary dictionaryWithDictionary:self.receivedHeaders],self.responseStatusCode, [error copy]);
			self.receivedData = nil;
			self.receivedHeaders = nil;
		});
	} else {
		self.receivedData = nil;
		self.receivedHeaders = nil;
	}
	[[UIApplication sharedApplication] decreaseActivityCounter];
}

@end