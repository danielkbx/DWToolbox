//
//  DWTreeNode.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 13.12.12.
//
//

#import <Foundation/Foundation.h>

typedef enum {
	DWTreeNodeStorageTypeXML,
} DWTreeNodeFormat;

@interface DWTreeNode : NSObject

@property (nonatomic, strong, readonly) NSFileWrapper *fileWrapper;

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong) NSString *value;

@property (nonatomic, strong, readonly) NSDictionary *attributes;
@property (nonatomic, strong, readonly) NSDictionary *nodes;

@property (nonatomic, readonly) DWTreeNodeFormat format;

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
