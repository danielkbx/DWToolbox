//
//  DWURLDownload.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 28.10.12.
//
//

#import "DWURLDownload.h"

#import "DWURLConnection.h"
#import "NSString+Additions.h"

#define kDWURLDownloadDefaultCacheLifetime 60*60*24*7 // one week

static NSTimeInterval cacheLifetime;

@interface DWURLDownload()

@property (nonatomic, copy, readwrite) NSURL *URL;
@property (nonatomic, readwrite) DWURLDownloadState state;
@property (nonatomic, readwrite) DWURLDownloadSource source;

@property (nonatomic, strong) DWURLConnection *connection;

@end

@implementation DWURLDownload

+ (void)setCacheLifetime:(NSTimeInterval)lifetime {
	if (lifetime > 0) {
		cacheLifetime = lifetime;
	}
}

+ (NSTimeInterval)cacheLifetime {
	return cacheLifetime;
}

+ (void)initialize {
	cacheLifetime = kDWURLDownloadDefaultCacheLifetime;
}

+ (DWURLDownload *)downloadWithURL:(NSURL *)URL {
	DWURLDownload *download = [[DWURLDownload alloc] initWithURL:URL];
	return download;
}

+ (DWURLDownload *)startDownloadWithURL:(NSURL *)URL completion:(DWURLDownloadHandler)completion {
	NSURL *localURL = [[self cacheDirectory] URLByAppendingPathComponent:URL.absoluteString.MD5 isDirectory:NO];
	if (localURL) {
		DWURLDownload *download = [self downloadWithURL:URL];
		[download downloadToFileURL:localURL completion:completion];
		return download;
	} else {
		return nil;
	}
}

+ (NSURL *)cacheDirectory {
	NSArray *libraryDirs = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	if (libraryDirs.count > 0) {
		NSURL *libraryURL = [NSURL fileURLWithPath:[libraryDirs objectAtIndex:0] isDirectory:YES];
		libraryURL = [libraryURL URLByAppendingPathComponent:@"DownloadCache" isDirectory:YES];
		BOOL isDir = NO;
		if (![[NSFileManager defaultManager] fileExistsAtPath:libraryURL.path isDirectory:&isDir] || isDir == NO) {
			[[NSFileManager defaultManager] createDirectoryAtURL:libraryURL
									 withIntermediateDirectories:YES
													  attributes:nil
														   error:NULL];
		}
		return libraryURL;
	}
	return nil;
}

+ (void)cleanup {
	NSURL *cacheDir = [self cacheDirectory];
	DWLog(@"Cleaning up %@ with a cache lifetime of %0.0f",cacheDir.path,[self cacheLifetime]);
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:cacheDir
												   includingPropertiesForKeys:nil
																	  options:NSDirectoryEnumerationSkipsHiddenFiles
																		error:NULL];
	NSMutableArray *filesToRemove = [NSMutableArray array];
	for (NSURL *file in files) {
		NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:file.path error:NULL];
		if (attributes) {
			NSDate *modificationDate = [attributes objectForKey:NSFileModificationDate];
			if (modificationDate) {
				if (([modificationDate timeIntervalSinceNow] * -1) > [self cacheLifetime]) {
					[filesToRemove addObject:file];
				}
			}
		}
	}
	if (filesToRemove.count == 0) {
		DWLog(@"Nothing to cleanup");
	} else {
		for (NSURL *fileToRemove in filesToRemove) {
			DWLog(@"Removing cached file %@",fileToRemove.path);
			[[NSFileManager defaultManager] removeItemAtURL:fileToRemove error:NULL];
		}
	}
}

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

		if (fileURL == nil) {
			fileURL = [[[self class] cacheDirectory] URLByAppendingPathComponent:self.URL.absoluteString.MD5 isDirectory:NO];
		}
		
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
			if (error == nil) {
				NSDictionary *fileAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
												[NSDate date], NSFileModificationDate,
												nil];
				[[NSFileManager defaultManager] setAttributes:fileAttributes
												 ofItemAtPath:fileURL.path
														error:&error];
			}
			completion(localData,fileURL,error);
		}
		
		if (mustDownloadFile && !mustNOTDownloadFile)
		{
			self.source = DWURLDownloadSourceNetwork;
			self.connection = [DWURLConnection connectionWithURL:self.URL];
			
			__weak DWURLDownload *blockself = self;
			
			[self.connection startWithCompletionHandler:^(NSData *receivedData, NSDictionary *responseHeaders, NSUInteger statusCode, NSError *error) {
				
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

- (void)cancel {
	[self.connection cancel];
	self.connection = nil;
}

@end
