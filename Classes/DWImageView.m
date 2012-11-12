//
//  DWImageView.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 05.11.12.
//
//

#import "DWImageView.h"

#import "DWURLDownload.h"

static UIImage *staticDefaultImage;

@interface DWImageView ()

@property (nonatomic, strong) DWURLDownload *download;

@end

@implementation DWImageView

+ (void)setDefaultImage:(UIImage *)defaultImage {
	staticDefaultImage = defaultImage;
}

+ (UIImage *)defaultImage {
	return staticDefaultImage;
}

- (id)initWithURL:(NSURL *)URL {
	if ((self = [super initWithFrame:CGRectZero])) {
		self.URL = URL;
	}
	return self;
}

- (UIImage *)effectiveDefaultImage {
	UIImage *image = self.defaultImage;
	if (image == nil) {
		image = [[self class] defaultImage];
	}
	return image;
}

- (void)setDownload:(DWURLDownload *)download {
	if (self->_download != download) {
		
		if (self.download) {
			if (self.download.state == DWURLDownloadStateRunning) {
				[self.download cancel];
			}
		}
		
		self->_download = download;
	}
}

- (void)setURL:(NSURL *)URL {

	if (![self.URL.absoluteString isEqualToString:URL.absoluteString]) {
		self->_URL = [URL copy];
		
		if (self.URLChangeBehavior == DWImageViewURLChangeBehaviorClearImmediately) {
			self.image = nil;
		}
		
		if (URL != nil) {
			
			self.download = [DWURLDownload downloadWithURL:self.URL];
			[self.download downloadToFileURL:nil completion:^(NSData *receivedData, NSURL *fileURL, NSError *error) {
				if (receivedData.length > 0) {
					UIImage *image = [UIImage imageWithData:receivedData];
					if (image) {
						self.image = image;
						if ([self.delegate respondsToSelector:@selector(imageViewDidLoadRemoteImage:)]) {
							[self.delegate imageViewDidLoadRemoteImage:self];
						}
					}
				}
			}];
		} else {
			self.download = nil;
		}
	}
}

- (void)setImage:(UIImage *)image {
	UIImage *effectiveImage = image;
	if (effectiveImage == nil) {
		effectiveImage = [self effectiveDefaultImage];
	}
	
	[super setImage:effectiveImage];
}


@end
