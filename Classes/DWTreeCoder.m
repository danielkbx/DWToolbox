//
//  DWTreeCoder.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 13.12.12.
//
//

#import "DWTreeCoder.h"

#import "DWTreeNode_Private.h"
#import "NSObject+DWToolbox.h"

#import "DWObjectPropertyDescription.h"
#import "DWObjectPropertyDescription_Private.h"

#import "RXMLElement.h"

@interface DWTreeCoder()

@property (nonatomic, strong) NSMutableDictionary *objectDescriptions;

@end

@implementation DWTreeCoder

- (id)init {
	if ((self = [super init])) {
		self.objectDescriptions = [[NSMutableDictionary alloc] init];
		self.dictionaryKeyString = @"key";
	}
	return self;
}

- (void)loadFromURL:(NSURL *)URL completion:(DWTreeCoderLoadCompletion)completion {
	
	NSFileWrapper *wrapper = [[NSFileWrapper alloc] initWithURL:URL
														options:0
														  error:NULL];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		BOOL success = [self readFileWrapper:wrapper];
		id rootObject = nil;
		if (success) {
			rootObject = [self objectCreatedFromTreenode:self];
		}
		
		if (completion) {
			dispatch_async(dispatch_get_main_queue(), ^{
				completion(success,rootObject);
			});
		}
	});
}

- (BOOL)writeToURL:(NSURL *)URL format:(DWTreeNodeFormat)format options:(NSUInteger)optionsMask {
	
	NSData *data = nil;
	
	BOOL prettyFormat = ((optionsMask & DWTreeCoderWritePrettyOption) == DWTreeCoderWritePrettyOption);
	BOOL preferAttributes = ((optionsMask & DWTreeCoderWriteXMLPreferAttributesOption) == DWTreeCoderWriteXMLPreferAttributesOption);
	
	if (format == DWTreeNodeFormatXML) {
		
		RXMLElement *element = [self XMLElementPreferAttributes:preferAttributes];
		if (element) {
			data = [element dataWithOptions:((prettyFormat) ? RXMLWritingOptionIndent : RXMLWritingOptionNone)];
		}
		
	} else if (format == DWTreeNodeFormatJSON) {
		
		NSString *name = self.name;
		if ([self.treeCoder.objectCreationDelegate respondsToSelector:@selector(treeCoder:nodeNameForProposedNodeName:)]) {
			name = [self.treeCoder.objectCreationDelegate treeCoder:self.treeCoder nodeNameForProposedNodeName:name];
		}
		
		NSDictionary *JSONDictionary = [NSDictionary dictionaryWithObject:[self JSONDictionary] forKey:name];
		data = [NSJSONSerialization dataWithJSONObject:JSONDictionary
											   options:((prettyFormat) ? NSJSONWritingPrettyPrinted : 0)
												 error:NULL];
	}
	
	if (data) {
		return [data writeToURL:URL atomically:NO];
	}
	
	return NO;
}

#pragma mark - Serialization

+ (DWTreeCoder *)coderFromObject:(id)object {
	
	BOOL success = NO;
	
	DWTreeCoder *coder = nil;
	if (object) {
		coder = [[DWTreeCoder alloc] init];
		if (coder) {
			success = [coder importObject:object];
		}
	}
	
	if (success == NO) {
		coder = nil;
	}
	return coder;
}

#pragma mark - Creation

- (BOOL)importObject:(id)object {
	BOOL success = [super importObject:object];
	self.type = DWTreeNodeTypeOrigin;
	return success;
}

- (id)objectCreatedFromTreenode:(DWTreeNode *)node {
	id object = nil;
	
	DWObjectDescription *description = [self propertyDescriptionForTreeNode:node];
	
	// create an instance
	Class rootClass = [self classForTreeNode:self];
	if (rootClass) {
		
		// allocating
		object = [rootClass alloc];
		BOOL didInitializeObject = NO;
		
		// initialising
		if ([rootClass conformsToProtocol:@protocol(DWTreeCoding)]) {
			if ([object respondsToSelector:@selector(initWithTreeNode:)]) {
				object = [((id <DWTreeCoding>)object) initWithTreeNode:node];
				didInitializeObject = YES;
			}
		}
		if (didInitializeObject == NO) {
			object = [[rootClass alloc] init];
			// apply properties
			
			NSArray *objectsProperties = [((NSObject *)object) properties];
			
			NSMutableArray *failedPropertyNames = [NSMutableArray array];
			
			for (NSString *attributeName in self.attributes) {
				
				DWObjectPropertyDescription *propertyDescription = nil;
				for (DWObjectPropertyDescription *i in objectsProperties) {
					if ([i.name isEqualToString:attributeName]) {
						propertyDescription = i;
					}
				}
				
				if (propertyDescription != nil) {
					id attributeValue = [self.attributes valueForKey:attributeName];
					if ([propertyDescription assignValue:attributeValue] == NO) {
						[failedPropertyNames addObject:attributeName];
					}
				}
			}
		}
	}
	
	return object;
}

- (void)addObjectDescription:(DWObjectDescription *)description {
	if (description.treeNodePath.length > 0 && description.class) {
		[self.objectDescriptions setObject:description forKey:description.treeNodePath];
	}
}

- (DWObjectDescription *)propertyDescriptionForTreeNode:(DWTreeNode *)node {
	NSString *nodePath = node.path;
	return [self.objectDescriptions objectForKey:nodePath];
}

- (Class)classForTreeNode:(DWTreeNode *)node {
	
	BOOL shouldCreate = YES;
	if ([self.objectCreationDelegate respondsToSelector:@selector(treeCoder:shouldCreateObjectForTreeNode:)]) {
		shouldCreate = [self.objectCreationDelegate treeCoder:self shouldCreateObjectForTreeNode:node];
	}
	
	if (shouldCreate) {
		
		DWObjectDescription *description = [self propertyDescriptionForTreeNode:node];
		Class class = description.objectClass;
		
		if ([self.objectCreationDelegate respondsToSelector:@selector(treeCoder:classForTreeNode:proposedClass:)]) {
			class = [self.objectCreationDelegate treeCoder:self classForTreeNode:node proposedClass:class];
		}
		return class;
	}
	
	return nil;
}

@end