//
//  UIImage+Additions.m
//  dwToolbox
//
//  Created by cme on 5/7/11.
//  Copyright 2011 danielkbx. All rights reserved.
//

#define degreesToRadians(x) (M_PI * x / 180.0)


#import "UIImage+DWToolbox.h"
#import <CommonCrypto/CommonDigest.h>
#import <QuartzCore/QuartzCore.h>

#import "Log.h"

@implementation UIImage (DWToolbox)

- (BOOL)hasAlphaChannel {
	CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(self.CGImage);
	if (alphaInfo == kCGImageAlphaNone ||
		alphaInfo == kCGImageAlphaNoneSkipFirst ||
		alphaInfo == kCGImageAlphaNoneSkipLast) {
		return NO;
	}
	return YES;
}

- (UIImage*)imageScaledToSize:(CGSize)targetSize {
	
	UIGraphicsBeginImageContextWithOptions(targetSize, NO, self.scale);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextConvertRectToDeviceSpace(context, (CGRect){CGPointZero,targetSize});
	
	[self drawInRect:CGRectMake(0, 0, roundf(targetSize.width), roundf(targetSize.height))];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize
{
	if (targetSize.width > 0.0f && targetSize.height > 0.0f)
	{
		UIImage *sourceImage = self;
		UIImage *newImage = nil;        
		CGSize imageSize = sourceImage.size;
		CGFloat width = imageSize.width;
		CGFloat height = imageSize.height;
		CGFloat targetWidth = targetSize.width;
		CGFloat targetHeight = targetSize.height;
		CGFloat scaleFactor = 0.0;
		CGFloat scaledWidth = targetWidth;
		CGFloat scaledHeight = targetHeight;
		CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
		
		if (CGSizeEqualToSize(imageSize, targetSize) == NO) 
		{
			CGFloat widthFactor = targetWidth / width;
			CGFloat heightFactor = targetHeight / height;
			
			if (widthFactor > heightFactor) 
				scaleFactor = widthFactor; // scale to fit height
			else
				scaleFactor = heightFactor; // scale to fit width
			scaledWidth  = width * scaleFactor;
			scaledHeight = height * scaleFactor;
			
			// center the image
			if (widthFactor > heightFactor)
			{
				thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
			}
			else 
				if (widthFactor < heightFactor)
				{
					thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
				}
		}       
		
        UIGraphicsBeginImageContextWithOptions(targetSize, !self.hasAlphaChannel, self.scale);  // this will crop

		CGContextRef context = UIGraphicsGetCurrentContext();
		NSAssert(context, @"No graphics context in place");
		
		CGRect thumbnailRect = CGRectZero;
		thumbnailRect.origin = thumbnailPoint;
		thumbnailRect.size.width  = scaledWidth;
		thumbnailRect.size.height = scaledHeight;
		
		[sourceImage drawInRect:thumbnailRect];
		
		newImage = UIGraphicsGetImageFromCurrentImageContext();	
		//pop the context to get back to the default
		UIGraphicsEndImageContext();
		return newImage;
	}
	else
	{
		return nil;
	}
}

- (UIImage*)imageByScalingToWidth:(float)width {
	CGRect newRect = CGRectMake(0,0,width, roundf(self.size.height * width / self.size.width));
	
	UIGraphicsBeginImageContextWithOptions(newRect.size, !self.hasAlphaChannel, self.scale);
    
	[self drawInRect:newRect];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

- (UIImage*)imageByScalingToHeight:(float)height {
	CGRect newRect = CGRectMake(0,0,roundf(self.size.width * height / self.size.height), height);
	
	UIGraphicsBeginImageContextWithOptions(newRect.size, !self.hasAlphaChannel, self.scale);
	
	[self drawInRect:newRect];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

- (CGSize)sizeWithWidth:(float)width {
	return CGSizeMake(width, self.size.height * width / self.size.width);
}

- (CGSize)sizeWithHeight:(float)height {
	return CGSizeMake(self.size.width * height / self.size.height, height);
}

- (UIImage*)imageByCenteredScalingToSize:(CGSize)size {
	CGSize newSize = size;
	if (self.size.width <= size.width && self.size.height <= size.height) {
		// we're smaller so we just need to fix the position
		newSize = self.size;
	} else if (self.size.width > size.width && self.size.height <= size.height) {
		// we're wider
		newSize = CGSizeMake(size.width,self.size.height * size.width / self.size.width);
	} else if (self.size.width <= size.width && self.size.height > size.height) {
		// we're higher
		newSize = CGSizeMake(self.size.width * size.height / self.size.height, size.height);
	} else {
		// we're just bigger :-)
		if (size.height / self.size.height > size.width / self.size.width) {
			newSize = CGSizeMake(size.width,self.size.height * size.width / self.size.width);
		} else {
			newSize = CGSizeMake(self.size.width * size.height / self.size.height, size.height);
		}
	}
	
	// finally the position
	CGRect targetRect = CGRectMake((size.width - newSize.width) / 2, (size.height - newSize.height) / 2, newSize.width, newSize.height);
	
    UIGraphicsBeginImageContextWithOptions(size, !self.hasAlphaChannel, self.scale);

	[self drawInRect:targetRect];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
	
}

- (UIImage *)imageByMatchingWidthOrHeightOfSize:(CGSize)size {
	CGSize size1 = [self sizeWithWidth:size.width];
	CGSize size2 = [self sizeWithHeight:size.height];
	
	CGFloat area1 = size1.width * size1.height;
	CGFloat area2 = size2.width * size2.height;
	
	if (area1 < area2) {
		return [self imageScaledToSize:size1];
	} else {
		return [self imageScaledToSize:size2];
	}
}

- (UIImage *)imageByCropingWithFrame:(CGRect)cropFrame {
    UIGraphicsBeginImageContextWithOptions(cropFrame.size, !self.hasAlphaChannel, self.scale);
    CGRect drawingRect = CGRectMake(cropFrame.origin.x * -1, cropFrame.origin.y * -1, self.size.width, self.size.height);	
	[self drawInRect:drawingRect];
	UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return theImage;
}

- (BOOL)writeAsPNGToFile:(NSString *)filename {
	NSData *data = UIImagePNGRepresentation(self);
	if (data) {
		NSError *error = nil;
		[data writeToFile:filename options:NSDataWritingAtomic error:&error];
		if (error) {
			DWLog(@"Error writing PNG to file %@", filename);
			return NO;
		}
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)writeAsJPEGToFile:(NSString *)filename quality:(CGFloat)quality {
	NSData *data = UIImageJPEGRepresentation(self, quality);
	if (data) {
		NSError *error = nil;
		[data writeToFile:filename options:NSDataWritingAtomic error:&error];
		if (error) {
			DWLog(@"Error writing PNG to file %@", filename);
			return NO;
		}
		return YES;
	} else {
		return NO;
	}
}

- (NSData *)data {
	NSData *imageData = nil;
	if (self) {
		if ([self hasAlphaChannel]) {
			imageData = UIImagePNGRepresentation(self);
		} else {
			imageData = UIImageJPEGRepresentation(self, 0.7);
		}
	}
	return imageData;
}

- (NSString *)hash {
	unsigned char result[16];
	
	NSData *imageData = (__bridge_transfer NSData *)CGDataProviderCopyData(CGImageGetDataProvider(self.CGImage));
	
	//	NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(self)];
	CC_MD5([imageData bytes], [imageData length], result);
	NSString *  s = [NSString stringWithFormat:
                     @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                     result[0], result[1], result[2], result[3], 
                     result[4], result[5], result[6], result[7],
                     result[8], result[9], result[10], result[11],
                     result[12], result[13], result[14], result[15]
                     ];
    return s;
}

- (UIImage*)imageFittingForOrientation:(UIInterfaceOrientation)orientation
{
    UIImageOrientation newImageOrientation = 0;
    
    switch (orientation) 
    {
        case UIInterfaceOrientationLandscapeLeft:
            newImageOrientation = UIImageOrientationDown;
            break;
        case UIInterfaceOrientationPortrait:
            newImageOrientation = UIImageOrientationLeft;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            newImageOrientation = UIImageOrientationRight;
            break;
            
        default:
            break;
    }
    
    return [UIImage imageWithCGImage: self.CGImage
                               scale: self.scale
                         orientation: newImageOrientation];
}

- (UIImage *)imageByRotatingByDegrees:(CGFloat)degrees {
	
	// calculate the size of the rotated view's containing box for our drawing space
	CGAffineTransform t = CGAffineTransformMakeRotation(degreesToRadians(degrees));
	CGSize rotatedSize = CGRectApplyAffineTransform(CGRectMake(0,0,self.size.width, self.size.height), t).size;
	
	// Create the bitmap context
	UIGraphicsBeginImageContextWithOptions(rotatedSize, !self.hasAlphaChannel, self.scale);

	CGContextRef bitmap = UIGraphicsGetCurrentContext();
	
	// Move the origin to the middle of the image so we will rotate and scale around the center.
	CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
	
	//   // Rotate the image context
	CGContextRotateCTM(bitmap, degreesToRadians(degrees));
	
	// Now, draw the rotated/scaled image into the context
	CGContextScaleCTM(bitmap, 1.0, -1.0);
	CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
	
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
	
}

- (UIImage *)imageByFlipingHorizontally {
    UIGraphicsBeginImageContextWithOptions(self.size, !self.hasAlphaChannel, self.scale);

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, -1.0, 1.0f);
	
	CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, self.size.width, self.size.height), self.CGImage);
	
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
	
}

- (UIImage *)imageByFlipingVertically {
    UIGraphicsBeginImageContextWithOptions(self.size, !self.hasAlphaChannel, self.scale);

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 1.0, -1.0f);
	
	CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, self.size.width, self.size.height), self.CGImage);
	
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
	
}

@end
