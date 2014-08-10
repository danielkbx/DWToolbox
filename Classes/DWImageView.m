//
//  DWImageView.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 05.11.12.
//
//

#import "DWImageView.h"

#import "DWURLDownload.h"

#import "NSURL+DWToolbox.h"
#import "UIDevice+DWToolbox.h"

static UIImage *staticDefaultImage;

@interface DWImageView ()

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) DWURLDownload *download;

@end

@implementation DWImageView

+ (void)setDefaultImage:(UIImage *)defaultImage {
	staticDefaultImage = defaultImage;
}

+ (UIImage *)defaultImage {
	return staticDefaultImage;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self awakeFromNib];
    }
    return self;
}

- (id)initWithURL:(NSURL *)URL {
	if ((self = [self initWithFrame:CGRectZero])) {
		self.URL = URL;
	}
	return self;
}

- (void)awakeFromNib {
    self.showActivityIndicator = NO;
    self.clipsToBounds = YES;
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
			
            __block BOOL showActivityIndicator = YES;
            
			self.download = [DWURLDownload downloadWithURL:self.URL];
			[self.download downloadToFileURL:nil completion:^(NSData *receivedData, NSURL *fileURL, NSError *error) {
                [self _hideActivityIndicator];
                showActivityIndicator = NO;
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
            
            if (showActivityIndicator) {
                [self _showActivityIndicator];
            }
		} else {
			self.download = nil;
		}
	}
}

- (void)setImage:(UIImage *)image {
	self.contentMode = UIViewContentModeScaleAspectFit;
	UIImage *effectiveImage = image;
	if (effectiveImage == nil) {
		effectiveImage = [self effectiveDefaultImage];
	}
	
	[super setImage:effectiveImage];
}

- (void)_showActivityIndicator {
    
    if (self.showActivityIndicator && !self.activityIndicator) {
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.activityIndicator startAnimating];
        self.activityIndicator.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        self.activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:self.activityIndicator];
    }
}

- (void)_hideActivityIndicator {
    if (self.activityIndicator && self.activityIndicator.superview == self) {
        [self.activityIndicator removeFromSuperview];
        self.activityIndicator = nil;
    }
}


@end
