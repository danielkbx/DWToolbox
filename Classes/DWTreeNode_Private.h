//
//  DWTreeNode_Private.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 13.12.12.
//
//

#import "DWTreeNode.h"

@class RXMLElement;

@interface DWTreeNode ()

@property (nonatomic, strong, readwrite) NSFileWrapper *fileWrapper;
@property (nonatomic, weak) DWTreeNode *parent;

- (BOOL)readFileWrapper:(NSFileWrapper *)fileWrapper;
- (BOOL)readXMLElement:(RXMLElement *)element;

- (RXMLElement *)XMLElement;

@end
