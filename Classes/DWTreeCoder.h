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
	DWTreeCoderWritePrettyOption				= 1
} DWTreeCoderWriteOptions;

/**
 DWTreeCoding helps DWTreeCoder to transform an object into a treenode. Though it works without, it is recommended to implement this protocol on all classes which are intended to be serialized.
 */
@protocol DWTreeCoding <NSObject>
@optional
- (id)initWithTreeNode:(DWTreeNode *)node;

+ (NSArray *)treeNodePropertyNames;
- (NSArray *)treeNodePropertyNames;
@end

@protocol DWTreeCoderDelegate;

typedef void (^DWTreeCoderLoadCompletion)(BOOL success,id rootObject);

/**
 DWTreeCoder loads XML files into treenode graphs and vice versa. It is used to serialize object graphs to XML.
 
 Serialization examines the properties of the imported objects following any paths to other objects. With this information a tree of nodes is created which 
 contains the very same information but a normalized structure.
 This structure then can be transformed to XML data. During this step, every supported type is split into parts. This continues until only trivial or Foundation types are 
 left over. Therefore, every custom Objective-C class is supported. However, there are limitations:
 
 - C arrays are not supported
 - C unions are not supported
 - most structs (even from within Foundation) are not supported
 - Objective-C's BOOL gets transformed to a C++ char (which works fine but creates weird XML)
 
 On the other hand, the following types are supported:
 
 - NSString
 - NSDate (uses ISO8601 format)
 - NSColor (uses hex representation including alpha channel, e.g. #660F12FF)
 - all number types (int, float, double …)
 - C++'s bool (and BOOL as a char)
 - NSArray
 - NSURL
 - NSDictionary
 - NSSet
 - NSCountableSet
 - NSOrderedSet
 - NSData
 - CLLocation
 - all custom Objective-C classes
 
 In general, all custom classes can be instantly used to create a treenode (and XML). You can, however, customize the behavior of DWTreeCode by assigning a delegate and/or implementing DWTreeCoding for the classes to be used.
 
 */
@interface DWTreeCoder : DWTreeNode

@property (nonatomic, copy) NSString *dictionaryKeyString;
@property (nonatomic, weak) id <DWTreeCoderDelegate> delegate;

- (void)loadFromURL:(NSURL *)URL completion:(DWTreeCoderLoadCompletion)completion;
- (BOOL)writeToURL:(NSURL *)URL options:(NSUInteger)optionsMask;


#pragma mark - Serialization

+ (DWTreeCoder *)coderFromObject:(id)object;

@end

@protocol DWTreeCoderDelegate <NSObject>

@optional
- (NSString *)treeCoder:(DWTreeCoder *)coder typeStringForClass:(Class)class;
- (Class)treeCoder:(DWTreeCoder *)coder classForTypeString:(NSString *)typeString;
@end