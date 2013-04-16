//
//  DWImageView.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 05.11.12.
//
//

#import <UIKit/UIKit.h>

@protocol DWImageViewDelegate;

@interface DWImageView : UIImageView

typedef enum {
	DWImageViewURLChangeBehaviorClearImmediately,			// the displayed image is cleared in the moment you set a new URL causing the image view to be empty until the new URL has been loaded
	DWImageViewURLChangeBehaviorAvoidClearing				// after changing the URL the old image is displayed until the new image has been downloaded
} DWImageViewURLChangeBehaviorType;

@property (nonatomic, copy) NSURL *URL;
@property (nonatomic, assign) CGSize imageSize;

@property (nonatomic, assign) DWImageViewURLChangeBehaviorType URLChangeBehavior;
@property (nonatomic, strong) UIImage *defaultImage;		// is displayed when no image or URL is assigned

@property (nonatomic, weak) id <DWImageViewDelegate> delegate;

+ (void)setDefaultImage:(UIImage *)defaultImage;
+ (UIImage *)defaultImage;

- (id)initWithURL:(NSURL *)URL;

@end

@protocol  DWImageViewDelegate <NSObject>
@optional

- (void)imageViewDidLoadRemoteImage:(DWImageView *)imageView;

@end