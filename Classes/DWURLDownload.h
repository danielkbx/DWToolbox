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

- (id)initWithURL:(NSURL *)URL;

- (void)downloadToFileURL:(NSURL *)fileURL completion:(DWURLDownloadHandler)completion;
- (void)downloadToFileURL:(NSURL *)fileURL completion:(DWURLDownloadHandler)completion forceSource:(DWURLDownloadSource)source;

@end
