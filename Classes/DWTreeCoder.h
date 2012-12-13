//
//  DWTreeCoder.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 13.12.12.
//
//

#import <Foundation/Foundation.h>

#import "DWTreeNode.h"

typedef enum {
	DWTreeNodeFormatXML,
	DWTreeNodeFormatJSON
} DWTreeNodeFormat;

typedef void (^DWTreeNodeCompletion)(BOOL success);

@interface DWTreeCoder : DWTreeNode

- (void)loadFromURL:(NSURL *)URL completion:(DWTreeNodeCompletion)completion;
- (BOOL)writeToURL:(NSURL *)URL format:(DWTreeNodeFormat)format;

@end
