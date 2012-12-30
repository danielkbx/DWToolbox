//
//  DWTreeNode.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 13.12.12.
//
//

#import <Foundation/Foundation.h>

typedef enum {
	DWTreeNodeTypeOrigin,
	DWTreeNodeTypeCustomClass,
	DWTreeNodeTypeNativeClass,
	DWTreeNodeTypeArray,
	DWTreeNodeTypeDictionary
} DWTreeNodeType;

@interface DWTreeNode : NSObject

@property (nonatomic, strong, readonly) NSFileWrapper *fileWrapper;

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong) NSString *value;

@property (nonatomic, readonly) DWTreeNodeType type;

@property (nonatomic, strong, readonly) NSDictionary *attributes;
@property (nonatomic, strong, readonly) NSArray *nodes;

@property (nonatomic, readonly) NSString *path;

+ (DWTreeNode *)nodeWithName:(NSString *)name;

- (id)initWithFileWrapper:(NSFileWrapper *)fileWrapper;

- (NSString *)attribute:(NSString *)name;

- (DWTreeNode *)nodeWithName:(NSString *)name;

#pragma mark - Mutation
- (void)setAttribute:(NSString *)name value:(NSString *)value;
- (void)removeAttribute:(NSString *)name;

- (void)addNode:(DWTreeNode *)node;
- (void)removeNode:(DWTreeNode *)node;

@end
