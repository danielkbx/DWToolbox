//
//  DWTreeNode_Private.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 13.12.12.
//
//

#import "DWTreeNode.h"

@class RXMLElement;
@class DWTreeCoder;

@interface DWTreeNode ()

@property (nonatomic, strong, readwrite) NSFileWrapper *fileWrapper;

@property (nonatomic, assign) DWTreeNodeType type;
@property (nonatomic, weak) DWTreeNode *parent;
@property (nonatomic, readonly) DWTreeCoder *treeCoder;

@property (nonatomic, assign) BOOL changed;

- (BOOL)readFileWrapper:(NSFileWrapper *)fileWrapper;

- (BOOL)readXMLElement:(RXMLElement *)element;

- (void)markAsChanged;

- (RXMLElement *)XMLElementPreferAttributes:(BOOL)preferAttributes;
- (NSDictionary *)JSONDictionary;

- (BOOL)importObject:(id)obejct;

@end
