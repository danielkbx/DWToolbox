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

- (void)writeToURL:(NSURL *)URL completion:(DWTreeNodeCompletion)completion {
	
	if (self.format == DWTreeNodeStorageTypeXML) {
		
		BOOL success = NO;
		
		RXMLElement *element = [self XMLElement];
		if (element) {
			NSData *elementData = [element dataWithOptions:RXMLWritingOptionIndent];
			if (elementData) {
				success =[elementData writeToURL:URL atomically:YES];
			}
		}
		
		completion(success);
	}
}

@end
