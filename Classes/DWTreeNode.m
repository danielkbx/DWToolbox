//
//  DWTreeNode.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 13.12.12.
//
//

#import "DWTreeNode.h"
#import "DWTreeNode_Private.h"
#import "DWObjectPropertyDescription_Private.h"

#import "DWTreeCoder.h"

#import "RXMLElement.h"

#import "NSObject+DWToolbox.h"
#import "ISO8601DateFormatter.h"
#import "UIColor+Expanded.h"

#define kDWTreeNodeDictionarySerializingKeyKey @"oi7uz8w97er9b843trcw9"

@interface DWTreeNode () {
	
	NSMutableArray *_nodes;
	NSMutableDictionary *_attributes;
	
	BOOL _isReading;
	
}

- (id)initWithXMLElement:(RXMLElement *)element;

@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSDictionary *attributes;
@property (nonatomic, strong, readwrite) NSArray *nodes;

@end

@implementation DWTreeNode

@synthesize nodes = _nodes;
@synthesize attributes = _attributes;

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ %@='%@'%@, Attributes:%u",[super description], self.name, self.value, (self.changed) ? @" CHANGED" : @"", self.attributes.count];
}

+ (DWTreeNode *)nodeWithName:(NSString *)name {
	DWTreeNode *node = [[DWTreeNode alloc] init];
	node.name = name;
	return node;
}

- (id)init {
	if ((self = [super init])) {
		self->_nodes = [[NSMutableArray alloc] init];
		self->_attributes = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (id)initWithFileWrapper:(NSFileWrapper *)fileWrapper {
	if ((self = [self init])) {
		
		if ([self readFileWrapper:fileWrapper] == NO) {
			self = nil;
		}
	}
	return self;
}

- (id)initWithXMLElement:(RXMLElement *)element {
	if ((self = [self init])) {
		if ([self readXMLElement:element] == NO) {
			self = nil;
		}
	}
	return self;
}

- (id)initWithJSONDictionary:(NSDictionary *)data {
	if ((self = [self init])) {
		if ([self readJSONDictionary:data] == NO) {
			self = nil;
		}
	}
	return self;
}

- (id)initWithJSONDictionary:(NSDictionary *)data name:(NSString *)name {
	return [self initWithJSONDictionary:[NSDictionary dictionaryWithObject:data forKey:name]];
}

- (BOOL)readFileWrapper:(NSFileWrapper *)fileWrapper {
	if (self.fileWrapper != nil) {
		self.fileWrapper = nil;
		self.attributes = nil;
		self.nodes = nil;
		self.name = nil;
		self.value = nil;
	}
	
	self.fileWrapper = fileWrapper;
	
	BOOL success = NO;
	
	if (self.fileWrapper.isRegularFile) {
		
		NSData *content = fileWrapper.regularFileContents;
		if ([self.fileWrapper.filename hasSuffix:@".xml"]) {
			
			RXMLElement *fileElement = [RXMLElement elementFromXMLData:content];
			if (fileElement) {
				success = [self readXMLElement:fileElement];
			}
		} else if ([self.fileWrapper.filename hasSuffix:@".json"]) {
			
			id JSONObject = [NSJSONSerialization JSONObjectWithData:content
															options:NSJSONReadingAllowFragments
															  error:NULL];
			if (JSONObject) {
				success = [self readJSONDictionary:JSONObject];
			}
		}
		
	}
	
	return success;
}

- (NSString *)path {
	
	NSMutableArray *segments = [NSMutableArray array];
	[segments addObject:self.name];
	DWTreeNode *parent = self.parent;
	
	while(parent) {
		[segments addObject:parent.name];
		parent = parent.parent;
	}
	
	return [segments componentsJoinedByString:@"."];
}

#pragma mark - XML

- (BOOL)readXMLElement:(RXMLElement *)element {
	_isReading = YES;
	
	BOOL success = NO;
	
	if (element) {
		success = YES;
		self.name = element.tag;
		
		[self->_attributes addEntriesFromDictionary:element.attributes];
		
		[element iterate:@"*" usingBlock:^(RXMLElement *subelement) {
			DWTreeNode *node = [[DWTreeNode alloc] initWithXMLElement:subelement];
			if (node) {
				node.parent = self;
				[self->_nodes addObject:node];
			}
		}];
		if (self->_nodes.count == 0) {
			self.value = [element text];
		}
		
		if (self.value.length == 0) {
			self.value = nil;
		}
	}
	
	_isReading = NO;
	
	return success;
}

- (RXMLElement *)XMLElementPreferAttributes:(BOOL)preferAttributes {
	
	NSString *name = self.name;
	if ([self.treeCoder.objectCreationDelegate respondsToSelector:@selector(treeCoder:nodeNameForProposedNodeName:)]) {
		name = [self.treeCoder.objectCreationDelegate treeCoder:self.treeCoder nodeNameForProposedNodeName:name];
	}
	
	RXMLElement *element = [RXMLElement elementWithTag:name];
	
	for (NSString *attributeName in self.attributes) {
		NSString *attributeValue = [self.attributes objectForKey:attributeName];
		if (preferAttributes ||
			[attributeName isEqualToString:kDWTreeNodeDictionarySerializingKeyKey] ||
			[attributeName.lowercaseString isEqualToString:@"identifier"]) {
			NSString *usedAttributeName = nil;
			if ([attributeName isEqualToString:kDWTreeNodeDictionarySerializingKeyKey]) {
				usedAttributeName = self.treeCoder.dictionaryKeyString;
			} else if ([attributeName.lowercaseString isEqualToString:@"identifier"]) {
				usedAttributeName = @"id";
			} else {
				usedAttributeName = attributeName;
			}
			[element setAttribute:usedAttributeName value:attributeValue];
		} else {
			RXMLElement *attributeSubnode = [RXMLElement elementWithTag:attributeName];
			if (attributeSubnode) {
				[attributeSubnode setText:attributeValue];
				[element appendChild:attributeSubnode];
			}
		}
	}
	
	if (self.nodes.count > 0) {
		for (DWTreeNode *node in self.nodes) {
			RXMLElement *subElement = [node XMLElementPreferAttributes:preferAttributes];
			if (subElement) {
				[element appendChild:subElement];
			}
		}
	} else if (self.value.length > 0) {
		[element setText:self.value];
	}
	
	return element;
}

- (BOOL)readJSONDictionary:(NSDictionary *)data {
	
	BOOL success = NO;
	
	if ([data isKindOfClass:[NSDictionary class]]) {
		if ([data count] > 0) {
			NSString *firstNodeName = [data.allKeys objectAtIndex:0];
			if (firstNodeName.length > 0) {
				
				success = YES;
				
				id firstNodeData = [data objectForKey:firstNodeName];
				
				
				self.name = firstNodeName;
				for (NSString *key in firstNodeData) {
					id value = [firstNodeData objectForKey:key];
					if ([value isKindOfClass:[NSDictionary class]]) {
						
						DWTreeNode *node = [[DWTreeNode alloc] initWithJSONDictionary:value name:key];
						if (node) {
							node.parent = self;
							[self->_nodes addObject:node];
						}
						
					} else if ([value isKindOfClass:[NSString class]]) {
						if ([key isEqualToString:@"value"]) {
							self.value = value;
						} else {
							[self setAttribute:key value:value];
						}
					}
				}
			}
			
		}
	}
	
	return success;
}

#pragma mark - JSON

- (id)JSONDictionary {
	
	if (self.type == DWTreeNodeTypeDictionary) {
		
		NSMutableDictionary *data = [NSMutableDictionary dictionary];
		for (DWTreeNode *subnode in self.nodes) {
			NSString *keyValue = [subnode attribute:kDWTreeNodeDictionarySerializingKeyKey];
			if (keyValue) {
				NSDictionary *subnodeDict = [subnode JSONDictionary];
				if (subnodeDict) {
					[data setObject:subnodeDict forKey:keyValue];
				}
			}
		}
		return data;
	} else if (self.type == DWTreeNodeTypeArray) {
		NSMutableArray *data = [NSMutableArray array];
		for (DWTreeNode *subnode in self.nodes) {
			NSDictionary *subnodeDict = [subnode JSONDictionary];
			if (subnodeDict) {
				[data addObject:subnodeDict];
			}
		}
		return data;
	} else {
		
		NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:self.attributes];
		[data removeObjectForKey:kDWTreeNodeDictionarySerializingKeyKey];
		
		if (self.nodes.count > 0) {

			for (DWTreeNode *node in self.nodes) {
				
				NSString *name = node.name;
				if ([self.treeCoder.objectCreationDelegate respondsToSelector:@selector(treeCoder:nodeNameForProposedNodeName:)]) {
					name = [self.treeCoder.objectCreationDelegate treeCoder:self.treeCoder nodeNameForProposedNodeName:name];
				}
				
				NSDictionary *nodeDictionary = [node JSONDictionary];
				[data setObject:nodeDictionary forKey:name];
			}
			
		} else if (self.value != nil) {
			[data setObject:self.value forKey:@"value"];
		}
		return data;
	}
	return nil;
}

#pragma mark - Relations

- (DWTreeCoder *)treeCoder {
	if ([self isKindOfClass:[DWTreeCoder class]]) {
		return (DWTreeCoder *)self;
	} else {
		
		id parent = self.parent;
		while (parent) {
			if ([parent isKindOfClass:[DWTreeCoder class]]) {
				return (DWTreeCoder *)parent;
			} else {
				parent = ((DWTreeNode *)parent).parent;
			}
		}
	}
	
	return nil;
}

#pragma mark - State

- (void)markAsChanged {
	if (!_isReading) {
		self.changed = YES;
		if (![self isKindOfClass:[DWTreeCoder class]]) {
			[self.treeCoder markAsChanged];
		}
	}
}

#pragma mark - Value

- (void)setValue:(NSString *)value {
	if (![value isEqualToString:self.value]) {
		[self markAsChanged];
		self->_value = value;
		if (self.value != nil) {
			[self->_nodes removeAllObjects];
		}
	}
}

#pragma mark - Attributes

- (NSString *)attribute:(NSString *)name {
	return [self.attributes objectForKey:name];
}

- (void)setAttribute:(NSString *)name value:(NSString *)value {
	if (name != nil && value != nil) {
		
		NSString *existingAttribute = [self attribute:name];
		if (existingAttribute == nil || ![existingAttribute isEqualToString:value]) {
			[self markAsChanged];
			[self->_attributes setObject:value forKey:name];
		}
	}
}

- (void)removeAttribute:(NSString *)name {
	if (name != nil) {
		if ([self.attributes.allKeys containsObject:name]) {
			[self markAsChanged];
			[self->_attributes removeObjectForKey:name];
		}
	}
}

#pragma mark - Nodes

- (DWTreeNode *)nodeWithName:(NSString *)name {
	DWTreeNode *node = nil;
	for (DWTreeNode *subNode in self.nodes) {
		if ([subNode.name isEqualToString:name]) {
			node = subNode;
			break;
		}
	}
	return node;
}

- (void)addNode:(DWTreeNode *)node {
	if (node.name) {
		[self markAsChanged];
		[self->_nodes addObject:node];
		node.parent = self;
		self.value = nil;
	}
}

- (void)removeNode:(DWTreeNode *)node {
	if (node) {
		if ([self.nodes containsObject:node]) {
			[self markAsChanged];
			[self->_nodes removeObject:node];
		}
	}
}

#pragma mark - Importing Objects

+ (NSDictionary *)attributeClasses {
	static NSDictionary *attributeClasses = nil;
	if (attributeClasses == nil) {
		attributeClasses = [[NSDictionary alloc] initWithObjectsAndKeys:
							@"NSString", [NSString class],
							@"NSNumber", [NSNumber class],
							@"NSURL", [NSURL class],
							@"NSDate", [NSDate class],
							@"UIColor", [UIColor class],
							@"NSData", [NSData class],
							nil];
	}
	return attributeClasses;
}

+ (Class)attributeClassForClass:(Class)class {
	for (Class attributeClass in [[self attributeClasses] allKeys]) {
		if ([class isSubclassOfClass:attributeClass]) {
			return attributeClass;
		}
	}
	return nil;
}

+ (BOOL)isAttributeClass:(Class)class {
	return ([self attributeClassForClass:class] != nil);
}

+ (BOOL)isAttributeObject:(id)object {
	return [self isAttributeClass:[object class]];
}

- (BOOL)importObject:(id)object {
	
	Class rootClass = [object class];
	if (rootClass) {
		if (self.name == nil) {
			self.name  = [self nodeNameForClass:rootClass];
		}
		self.type = DWTreeNodeTypeCustomClass;
	}
	
	NSArray *propertyNames = [self propertiesOfObject:object];
	NSMutableArray *processingProperties = [NSMutableArray array];
	for (NSString *propertyName in propertyNames) {
		DWObjectPropertyDescription *description = [object propertyDescriptionForName:propertyName];
		if (description) {
			if (description.accessMode == DWPropertyAccessModeReadonly ||
				description.accessMode == DWPropertyAccessModeWeak) {
				DWLog(@"Treecoder skips property \"%@\". It is READONLY or WEAK. Consider defining a list of properties by implementing DWTreeCoding for %@!",propertyName,rootClass);
			} else if ([description.typeString isEqualToString:@"id"]) {
				DWLog(@"Treecoder skips property \"%@\" of class %@. Since its type is \"id\" it can be writen but not read.",propertyName,rootClass);
			} else {
				[processingProperties addObject:description];
			}
		} else {
			DWLog(@"Propery \"%@\" not found for class %@.",propertyName,rootClass);
		}
	}
	
	for (DWObjectPropertyDescription *propertyDescription in processingProperties) {
		
		id nativeValue = propertyDescription.value;
		if (nativeValue) {
			
			NSString *propertyName = propertyDescription.name;
			
			if ([[self class] isAttributeObject:nativeValue]) {
				[self setAttribute:propertyName value:[self stringFromObject:nativeValue]];
			} else {
				if ([nativeValue isKindOfClass:[NSArray class]]) {
					DWTreeNode *arrayNode = [DWTreeNode nodeWithName:propertyName];
					arrayNode.type = DWTreeNodeTypeArray;
					for (id arrayElement in (NSArray *)nativeValue) {
						DWTreeNode *subnode = [[DWTreeNode alloc] init];
						if ([subnode importObject:arrayElement]) {
							[arrayNode addNode:subnode];
						}
					}
					[self addNode:arrayNode];
				} else if ([nativeValue isKindOfClass:[NSDictionary class]]) {
					DWTreeNode *dictNode = [DWTreeNode nodeWithName:propertyName];
					dictNode.type = DWTreeNodeTypeDictionary;
					for (NSString *elementKey in (NSDictionary *)nativeValue) {
						id dictElement = [((NSDictionary *)nativeValue) objectForKey:elementKey];
						DWTreeNode *subnode = [[DWTreeNode alloc] init];
						if ([subnode importObject:dictElement]) {
							[dictNode addNode:subnode];
							[subnode setAttribute:kDWTreeNodeDictionarySerializingKeyKey value:elementKey];
						}
					}
					[self addNode:dictNode];
				} else {
					DWTreeNode *subnode = [DWTreeNode nodeWithName:propertyName];
					subnode.type = DWTreeNodeTypeCustomClass;
					if ([subnode importObject:nativeValue]) {
						[self addNode:subnode];
					}
				}
			}
		}
	}
	
	if (self.attributes.count + self.nodes.count == 0) {
		NSString *objectsValue = nil;
		
		objectsValue = [self stringFromObject:object];
		
		if (objectsValue) {
			[self setValue:objectsValue];
			self.type = DWTreeNodeTypeNativeClass;
		}
	}
	
	return (self.name != nil);
}

- (NSString *)nodeNameForClass:(Class)class {
	NSString *name = nil;
	
	Class attributeClass = [[self class] attributeClassForClass:class];
	if (attributeClass) {
		name = [[[self class] attributeClasses] objectForKey:attributeClass];
	}
	
	if (name == nil) {
		name = NSStringFromClass(class);
	}
	
	return name;
}

- (NSString *)stringFromObject:(id)object {
	
	NSString *value = nil;
	
	if ([object isKindOfClass:[NSString class]]) {
		value = (NSString *)object;
	} else if ([object isKindOfClass:[NSDate class]]) {
		
		static ISO8601DateFormatter *isoDateFormatter = nil;
		if (isoDateFormatter == nil) {
			isoDateFormatter = [[ISO8601DateFormatter alloc] init];
			isoDateFormatter.includeTime = YES;
		}
		value = [isoDateFormatter stringFromDate:object];
	} else if ([object isKindOfClass:[NSNumber class]]) {
		value = [((NSNumber *)object) stringValue];
	} else if ([object isKindOfClass:[UIColor class]]) {
		value = [NSString stringWithFormat:@"#%@",[((UIColor *)object) hexStringFromColorAndAlpha]];
	} else if ([object isKindOfClass:[NSURL class]]) {
		value = [((NSURL *)object) absoluteString];
	}
	
	return value;
}

- (NSArray *)propertiesOfObject:(id)object {
	
	NSArray *properties = nil;
	
	if ([object respondsToSelector:@selector(treeNodePropertyNames)]) {
		properties = [object treeNodePropertyNames];
	}
	
	if (properties == nil) {
		Class objectsClass = [object class];
		if ([objectsClass respondsToSelector:@selector(treeNodePropertyNames)]) {
			properties = [objectsClass treeNodePropertyNames];
		}
	}
	
	if (properties == nil) {
		properties = [((NSObject *)object) properties];
	}
	
	return properties;
}

@end