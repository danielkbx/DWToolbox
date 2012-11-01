//
//  UIImage+Additions.h
//  dwToolbox
//
//  Created by cme on 5/7/11.
//  Copyright 2011 danielkbx. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIImage (UIImage_Additions)

- (BOOL)hasAlphaChannel;

- (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize;
//- (UIImage *)imageScaledToSize:(CGSize)targetSize;

- (UIImage *)imageByScalingToWidth:(float)width;
//- (UIImage *)imageByScalingToHeight:(float)height;

- (UIImage *)imageByCenteredScalingToSize:(CGSize)size;

- (UIImage *)imageMatchingWidthOrHeightOfSize:(CGSize)size;

- (UIImage *)imageByCropingWithFrame:(CGRect)cropFrame;

- (UIImage *)imageByRotatingByDegrees:(CGFloat)degrees;
//
//- (UIImage *)imageByFlipingHorizontally;
- (UIImage *)imageByFlipingVertically;
//
//- (CGSize)sizeWhenScalingToWidth:(float)width;
//- (CGSize)sizeWhenScalingToHeight:(float)height;
//
- (BOOL)writeAsPNGToFile:(NSString *)filename;
- (BOOL)writeAsJPEGToFile:(NSString *)filename quality:(CGFloat)quality;

- (NSString *)hash;

- (NSData *)data;

- (UIImage*)imageFittingForOrientation:(UIInterfaceOrientation)orientation;

@end
