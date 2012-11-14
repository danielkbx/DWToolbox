//
//  DWUploadField.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 14.11.12.
//
//

#import "DWUploadField.h"

@interface DWUploadField ()

@property (nonatomic, strong, readwrite) NSString *identifier;
@property (nonatomic, strong, readwrite) NSData *dataValue;

@property (nonatomic, strong, readwrite) NSString *filename;

@end

@implementation DWUploadField

- (id)initWithIdentifier:(NSString *)identifier dataValue:(NSData *)data {
	if ((self = [self initWithIdentifier:identifier binary:data filename:nil])) {
		self.contentType = @"application/octet-stream";
	}
	return self;
}

- (id)initWithIdentifier:(NSString *)identifier stringValue:(NSString *)value {
	if ((self  = [self initWithIdentifier:identifier dataValue:[value dataUsingEncoding:NSUTF8StringEncoding]])) {
		self.contentType = @"text/plain";
	}
	return self;
}

- (id)initWithIdentifier:(NSString *)identifier image:(UIImage *)image filename:(NSString *)filename {
	NSData *imageData = UIImagePNGRepresentation(image);
	if ((self = [self initWithIdentifier:identifier binary:imageData filename:filename])) {
		self.contentType = @"image/png";
	}
	return self;
}

- (id)initWithIdentifier:(NSString *)identifier binary:(NSData *)data filename:(NSString *)filename {
	if ((self = [super init])) {
		self.identifier = identifier;
		self.dataValue = data;
		self.filename = filename;
		self.contentType = @"application/octet-stream";
	}
	return self;
}

- (NSString *)stringValue {
	if ([self.contentType isEqualToString:@"image/png"]) {
		return nil;
	} else {
		return [[NSString alloc] initWithData:self.dataValue encoding:NSUTF8StringEncoding];
	}
}

- (NSString *)contentDisposition {
	NSMutableString *disposition = [NSMutableString stringWithFormat:@"form-data; name=\"%@\"",self.identifier];
	if (self.filename != nil) {
		[disposition appendFormat:@"; filename=\"%@\"",self.filename];
	}
	return [NSString stringWithString:disposition];
}

@end
