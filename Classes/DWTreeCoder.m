//
//  DWTreeCoder.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 13.12.12.
//
//

#import "DWTreeCoder.h"
#import "DWTreeNode_Private.h"

#import "RXMLElement.h"

@interface DWTreeCoder()

@end

@implementation DWTreeCoder

- (void)loadFromURL:(NSURL *)URL completion:(DWTreeNodeCompletion)completion {
	
	NSFileWrapper *wrapper = [[NSFileWrapper alloc] initWithURL:URL
														options:0
														  error:NULL];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		BOOL success = [self readFileWrapper:wrapper];
		if (completion) {
			dispatch_async(dispatch_get_main_queue(), ^{
				completion(success);
			});
		}
	});
}

- (BOOL)writeToURL:(NSURL *)URL format:(DWTreeNodeFormat)format {
	
	NSData *data = nil;
	
	if (format == DWTreeNodeFormatXML) {
		
		RXMLElement *element = [self XMLElement];
		if (element) {
			data = [element dataWithOptions:RXMLWritingOptionIndent];
		}
		
	} else if (format == DWTreeNodeFormatJSON) {
		
		NSDictionary *JSONDictionary = [NSDictionary dictionaryWithObject:[self JSONDictionary] forKey:self.name];
		data = [NSJSONSerialization dataWithJSONObject:JSONDictionary
											   options:NSJSONWritingPrettyPrinted
												 error:NULL];
	}
	
	if (data) {
		return [data writeToURL:URL atomically:NO];
	}
	
	return NO;
}

@end
