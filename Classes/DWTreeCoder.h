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

@protocol DWTreeCoderObjectCreationDelegate;

typedef void (^DWTreeCoderLoadCompletion)(BOOL success,id rootObject);

@interface DWTreeCoder : DWTreeNode

@property (nonatomic, weak) id <DWTreeCoderObjectCreationDelegate> objectCreationDelegate;

- (void)loadFromURL:(NSURL *)URL completion:(DWTreeCoderLoadCompletion)completion;
- (BOOL)writeToURL:(NSURL *)URL format:(DWTreeNodeFormat)format;

#pragma mark - Object creation

- (void)mapTreeNodePath:(NSString *)path toClass:(Class)class;

@end

@protocol DWTreeCoderObjectCreationDelegate <NSObject>

@optional

- (BOOL)treeCoder:(DWTreeCoder *)coder shouldCreateObjectForTreeNode:(DWTreeNode *)node;
- (Class)treeCoder:(DWTreeCoder *)coder classForTreeNode:(DWTreeNode *)node proposedClass:(Class)proposedClass;

@end