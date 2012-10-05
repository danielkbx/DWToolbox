//
//  DWURLConnection.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 05.10.12.
//
//

#import "DWURLConnection.h"

@interface DWURLConnection() <NSURLConnectionDataDelegate>

@property (nonatomic, strong, readwrite) NSURL *URL;
@property (nonatomic, readwrite) DWURLConnectionState state;
@property (nonatomic, strong) NSMutableDictionary *requestHeaders;
@property (nonatomic, strong) DWURLConnectionCompletionHandler completionHandler;

@property (nonatomic, strong) NSURLConnection *connection;

@property (nonatomic, assign) NSUInteger responseStatusCode;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSDictionary *receivedHeaders;

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

#pragma mark - Action

- (void)startWithCompletionHandler:(DWURLConnectionCompletionHandler)completion {
	@synchronized(self) {
		if (self.state == DWURLConnectionStateIdle ||
			self.state == DWURLConnectionStateCanceled) {
			self.completionHandler = completion;
			
			if (self.URL) {
				NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.URL];
				
				[request addValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
				
				for (NSString *headerKey in self.requestHeaders) {
					[request addValue:[self.requestHeaders valueForKey:headerKey] forHTTPHeaderField:headerKey];
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
}

@end