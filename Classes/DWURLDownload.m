//
//  DWURLDownload.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 28.10.12.
//
//

#import "DWURLDownload.h"

#import "DWURLConnection.h"

@interface DWURLDownload()

@property (nonatomic, copy, readwrite) NSURL *URL;
@property (nonatomic, readwrite) DWURLDownloadState state;
@property (nonatomic, readwrite) DWURLDownloadSource source;

@end

@implementation DWURLDownload

- (id)initWithURL:(NSURL *)URL {
	if ((self = [super init])) {
		self.URL = URL;
		self.state = DWURLConnectionStateIdle;
	}
	return self;
}

- (void)downloadToFileURL:(NSURL *)fileURL completion:(DWURLDownloadHandler)completion {
	[self downloadToFileURL:fileURL completion:completion forceSource:DWURLDownloadSourceUnknown];
}
- (void)downloadToFileURL:(NSURL *)fileURL completion:(DWURLDownloadHandler)completion forceSource:(DWURLDownloadSource)source;
{
	if (self.state == DWURLConnectionStateIdle) {
		
		self.state = DWURLConnectionStateRunning;
		
		BOOL mustDownloadFile = (source == DWURLDownloadSourceNetwork);
		BOOL mustNOTDownloadFile = (source == DWURLDownloadSourceLocal);
		
		BOOL hasLocalFile = NO;
		if (mustDownloadFile == NO) {
			BOOL existingFileIsDirectory = NO;
			if (![[NSFileManager defaultManager] fileExistsAtPath:[fileURL path] isDirectory:&existingFileIsDirectory] || existingFileIsDirectory == YES)
			{
				// the file has NOT been downloaded yet
				mustDownloadFile = YES;
			} else {
				hasLocalFile = YES;
			}
		}
		
		if (!mustDownloadFile && hasLocalFile) {
			
			NSError *error = nil;
			NSData *localData = [[NSData alloc] initWithContentsOfURL:fileURL
															  options:NSDataReadingMappedIfSafe
																error:&error];
			completion(localData,fileURL,error);
		}
		
		if (mustDownloadFile && !mustNOTDownloadFile)
		{
			self.source = DWURLDownloadSourceNetwork;
			DWURLConnection *connection = [DWURLConnection connectionWithURL:self.URL];
			
			__weak DWURLDownload *blockself = self;
			
			[connection startWithCompletionHandler:^(NSData *receivedData, NSDictionary *responseHeaders, NSUInteger statusCode, NSError *error) {
				
				NSURL *targetURL = [fileURL copy];
				
				if (error == nil && receivedData.length > 0) {
					[receivedData writeToURL:targetURL
									 options:NSDataWritingAtomic
									   error:&error];
					if (error != nil) {
						targetURL = nil;
					}
				}
				
				if (error == nil) {
					blockself.state = DWURLDownloadStateFinsished;
				} else {
					blockself.state = DWURLDownloadStateFailed;
				}
				
				completion(receivedData, targetURL, error);
			}];
		}
	}
}

@end
