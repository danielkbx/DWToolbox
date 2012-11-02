//
//  DWURLDownload.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 28.10.12.
//
//

#import <Foundation/Foundation.h>

typedef void (^DWURLDownloadHandler)(NSData *receivedData, NSURL *fileURL, NSError *error);

typedef enum {
	DWURLDownloadStateIdle,
	DWURLDownloadStateRunning,
	DWURLDownloadStateFinsished,
	DWURLDownloadStateFailed
} DWURLDownloadState;

typedef enum {
	DWURLDownloadSourceUnknown,
	DWURLDownloadSourceNetwork,
	DWURLDownloadSourceLocal
} DWURLDownloadSource;

@interface DWURLDownload : NSObject

@property (nonatomic, readonly) DWURLDownloadState state;
@property (nonatomic, readonly) DWURLDownloadSource source;

#pragma mark - Cleanup

/**
 Calling cleanup will erase all cached files which are older than the cache lifetime. The default value is a week, you can, however, set
 your own lifetime (as positiv value) in seconds.
 
 Cleanup needs to be called on the main thread.
 */
+ (void)setCacheLifetime:(NSTimeInterval)lifetime;
+ (NSTimeInterval)cacheLifetime;
+ (void)cleanup;

#pragma mark - Creation

/**
 You can create an instance by calling initWithURL: or downloadWithURL: (class method!). Both methods only create and setup the object.
 The download is not started automatically.
 */
+ (DWURLDownload *)downloadWithURL:(NSURL *)URL;
- (id)initWithURL:(NSURL *)URL;


#pragma mark - Download

/**
 Downloads need to be started manually (except for the class method) by passing a local file URL and a completion block.
 By specifying a local file you can set the file where the downloaded data is saved. If you pass nil as fileURL, DWURLDownload will create its own
 file URL within its cache directory.
 ATTENTION: by passing your own file URL you are responsible for any cleanup/removal action. Those files are not erase by calling cleanup.
 */
+ (DWURLDownload *)startDownloadWithURL:(NSURL *)URL completion:(DWURLDownloadHandler)completion;
- (void)downloadToFileURL:(NSURL *)fileURL completion:(DWURLDownloadHandler)completion;
- (void)downloadToFileURL:(NSURL *)fileURL completion:(DWURLDownloadHandler)completion forceSource:(DWURLDownloadSource)source;

- (void)cancel;

@end
