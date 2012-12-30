//
//  DWTreeCoder.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 13.12.12.
//
//

#import <Foundation/Foundation.h>

#import "DWTreeNode.h"

#import "DWObjectDescription.h"

typedef enum {
	DWTreeNodeFormatXML,
	DWTreeNodeFormatJSON
} DWTreeNodeFormat;

typedef enum {
	DWTreeCoderWritePrettyOption				= 1,
	DWTreeCoderWriteXMLPreferAttributesOption	= 2,
} DWTreeCoderWriteOptions;

@protocol DWTreeCoding <NSObject>
@optional
- (id)initWithTreeNode:(DWTreeNode *)node;

+ (NSArray *)treeNodePropertyNames;
- (NSArray *)treeNodePropertyNames;
@end

@protocol DWTreeCoderObjectCreationDelegate;


typedef void (^DWTreeCoderLoadCompletion)(BOOL success,id rootObject);

@interface DWTreeCoder : DWTreeNode

@property (nonatomic, copy) NSString *dictionaryKeyString;
@property (nonatomic, weak) id <DWTreeCoderObjectCreationDelegate> objectCreationDelegate;

- (void)loadFromURL:(NSURL *)URL completion:(DWTreeCoderLoadCompletion)completion;
- (BOOL)writeToURL:(NSURL *)URL format:(DWTreeNodeFormat)format options:(NSUInteger)optionsMask;

#pragma mark - Object creation

- (void)addObjectDescription:(DWObjectDescription *)description;

#pragma mark - Serialization

+ (DWTreeCoder *)coderFromObject:(id)object;

@end

@protocol DWTreeCoderObjectCreationDelegate <NSObject>

@optional
- (BOOL)treeCoder:(DWTreeCoder *)coder shouldCreateObjectForTreeNode:(DWTreeNode *)node;
- (Class)treeCoder:(DWTreeCoder *)coder classForTreeNode:(DWTreeNode *)node proposedClass:(Class)proposedClass;

- (NSString *)treeCoder:(DWTreeCoder *)coder nodeNameForProposedNodeName:(NSString *)proposedName;
@end