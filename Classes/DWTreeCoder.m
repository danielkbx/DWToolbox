//
//  DWTreeCoder.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 13.12.12.
//
//

#import "DWTreeCoder.h"

#import "DWTreeNode_Private.h"
#import "NSObject+DWToolbox.h"

#import "RXMLElement.h"

@interface DWTreeCoder()

@end

@implementation DWTreeCoder

- (id)init {
	if ((self = [super init])) {
		self.dictionaryKeyString = @"key";
	}
	return self;
}

- (void)loadFromURL:(NSURL *)URL completion:(DWTreeCoderLoadCompletion)completion {
	
	NSFileWrapper *wrapper = [[NSFileWrapper alloc] initWithURL:URL
														options:0
														  error:NULL];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		BOOL success = [self readFileWrapper:wrapper];
		if (completion && success) {
			DWLog(@"Trying to create object from treenode %@", self.name);
			id rootObject = nil;
			if (success) {
				rootObject = [self object];
			}
			
			dispatch_async(dispatch_get_main_queue(), ^{
				completion(success,rootObject);
			});
			
		}
	});
}

- (BOOL)writeToURL:(NSURL *)URL options:(NSUInteger)optionsMask {
	
	NSData *data = nil;
	
	BOOL prettyFormat = ((optionsMask & DWTreeCoderWritePrettyOption) == DWTreeCoderWritePrettyOption);
	
	RXMLElement *element = [self XMLElement];
	if (element) {
		data = [element dataWithOptions:((prettyFormat) ? RXMLWritingOptionIndent : RXMLWritingOptionNone)];
	}
			
	if (data) {
		return [data writeToURL:URL atomically:NO];
	}
	
	return NO;
}

#pragma mark - Serialization

+ (DWTreeCoder *)coderFromObject:(id)object {
	
	BOOL success = NO;
	
	DWTreeCoder *coder = nil;
	if (object) {
		coder = [[DWTreeCoder alloc] init];
		if (coder) {
			success = [coder importObject:object];
		}
	}
	
	if (success == NO) {
		coder = nil;
	}
	return coder;
}

#pragma mark - Creation

- (BOOL)importObject:(id)object {
	BOOL success = [super importObject:object];
	return success;
}

@end