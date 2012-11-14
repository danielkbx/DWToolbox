//
//  DWUploadField.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 14.11.12.
//
//

#import <Foundation/Foundation.h>

@interface DWUploadField : NSObject

@property (nonatomic, strong, readonly) NSString *identifier;
@property (nonatomic, strong, readonly) NSString *stringValue;
@property (nonatomic, strong, readonly) NSData *dataValue;
@property (nonatomic, strong, readonly) NSString *filename;

@property (nonatomic, strong, readwrite) NSString *contentType;

- (id)initWithIdentifier:(NSString *)identifier stringValue:(NSString *)value;
- (id)initWithIdentifier:(NSString *)identifier dataValue:(NSData *)data;

- (id)initWithIdentifier:(NSString *)identifier binary:(NSData *)data filename:(NSString *)filename;
- (id)initWithIdentifier:(NSString *)identifier image:(UIImage *)image filename:(NSString *)filename;

#pragma mark - DWURLConnection stuff

- (NSString *)contentDisposition;

@end
