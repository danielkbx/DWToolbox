//
//  DWTreeCoder.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 13.12.12.
//
//

#import <Foundation/Foundation.h>

#import "DWTreeNode.h"

typedef void (^DWTreeNodeCompletion)(BOOL success);

@interface DWTreeCoder : DWTreeNode

@property (nonatomic, strong, readonly) NSFileWrapper *fileWrapper;

- (void)loadFromURL:(NSURL *)URL completion:(DWTreeNodeCompletion)completion;
- (void)writeToURL:(NSURL *)URL completion:(DWTreeNodeCompletion)completion;

@end
