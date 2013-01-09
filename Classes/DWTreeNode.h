//
//  DWTreeNode.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 13.12.12.
//
//

#import <Foundation/Foundation.h>

@interface DWTreeNode : NSObject

@property (nonatomic, strong, readonly) NSFileWrapper *fileWrapper;

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong) id value;

@property (nonatomic, strong, readonly) NSString *type;

@property (nonatomic, strong, readonly) NSArray *nodes;

@property (nonatomic, readonly) NSString *path;

+ (DWTreeNode *)nodeWithName:(NSString *)name;

- (id)initWithFileWrapper:(NSFileWrapper *)fileWrapper;

- (DWTreeNode *)nodeWithName:(NSString *)name;

- (void)addNode:(DWTreeNode *)node;
- (void)removeNode:(DWTreeNode *)node;

@end
