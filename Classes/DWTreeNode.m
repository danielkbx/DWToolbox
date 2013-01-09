//
//  DWTreeNode.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 13.12.12.
//
//

#import "DWTreeNode.h"
#import "DWTreeNode_Private.h"

#import "DWTreeCoder.h"

#import "RXMLElement.h"

#import "NSObject+DWToolbox.h"
#import "ISO8601DateFormatter.h"
#import "UIColor+Expanded.h"
#import "NSString+DWToolbox.h"

#import "DWObjectPropertyDescription_Private.h"
#import <CoreLocation/CoreLocation.h>

#define kDWTreeNodeDictionarySerializingKeyKey @"oi7uz8w97er9b843trcw9"

#define kDWTreeNodeArrayKey @"NSArray"
#define kDWTreeNodeSetKey @"NSSet"
#define kDWTreeNodeOrderedSetKey @"NSOrderedSet"
#define kDWTreeNodeBagKey @"NSCountableSet"
#define kDWTreeNodeDictKey @"NSDictionary"

@interface DWTreeNode () {
	
	NSMutableArray *_nodes;
	
	BOOL _isReading;
	
	Class _objectClass;
	
}

- (id)initWithXMLElement:(RXMLElement *)element parent:(id)parent;

@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSArray *nodes;

@end

@implementation DWTreeNode

@synthesize nodes = _nodes;

- (NSString *)description {
	return [self descriptionWithIndentionLevel:0];
}

- (NSString *)descriptionWithIndentionLevel:(uint)level {
	
	NSMutableString *desc = [NSMutableString string];
	if (level == 0) {
		[desc appendFormat:@"\n"];
	}
	
	[desc appendFormat:@"%@ (%@) %@\n",self.name, self.type, [super description]];
	
	if (self.value != nil) {
		[desc appendString:[NSString stringByRepeatingString:@"\t" times:level + 1]];
		[desc appendFormat:@"└ Value: %@\n",self.value];
	} else if (self.nodes.count > 0) {
		[desc appendString:[NSString stringByRepeatingString:@"\t" times:level + 1]];
		[desc appendFormat:@"└ Nodes: %i\n",self.nodes.count];
		
		for (int i = 0; i < self.nodes.count; i++) {
			DWTreeNode *subnode = [self.nodes objectAtIndex:i];
			[desc appendString:[NSString stringByRepeatingString:@"\t" times:level + 2]];
			if (i == self.nodes.count - 1) {
				[desc appendString:@"└ "];
			} else {
				[desc appendString:@"├ "];
			}
			[desc appendString:[subnode descriptionWithIndentionLevel:level + 2]];
		}
	}
	
	return desc;
}

+ (DWTreeNode *)nodeWithName:(NSString *)name {
	DWTreeNode *node = [[DWTreeNode alloc] init];
	node.name = name;
	return node;
}

- (id)init {
	if ((self = [super init])) {
		self->_nodes = [[NSMutableArray alloc] init];
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

- (id)initWithXMLElement:(RXMLElement *)element parent:(id)parent {
	if ((self = [self init])) {
		self.parent = parent;
		if ([self readXMLElement:element] == NO) {
			self = nil;
		}
	}
	return self;
}

- (BOOL)readFileWrapper:(NSFileWrapper *)fileWrapper {
	if (self.fileWrapper != nil) {
		self.fileWrapper = nil;
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
		
		[element iterate:@"*" usingBlock:^(RXMLElement *subelement) {
			DWTreeNode *node = [[DWTreeNode alloc] initWithXMLElement:subelement parent:self];
			if (node) {
				[self->_nodes addObject:node];
			}
		}];
		
		//
		//		if (self->_nodes.count == 0 && self->_attributes.count == 0) {
		//			self.value = [element text];
		//		}
		//
		//		if (self.value.length == 0) {
		//			self.value = nil;
		//		}
	}
	
	_isReading = NO;
	
	return success;
}

- (RXMLElement *)XMLElement {
	
	NSString *name = nil;
	
	BOOL isList = ([self.type isEqualToString:kDWTreeNodeArrayKey] ||
				   [self.type isEqualToString:kDWTreeNodeSetKey] ||
				   [self.type isEqualToString:kDWTreeNodeOrderedSetKey] ||
				   [self.type isEqualToString:kDWTreeNodeBagKey] ||
				   [self.type isEqualToString:kDWTreeNodeDictKey]);
	
	BOOL parentIsList = ([self.parent.type isEqualToString:kDWTreeNodeArrayKey] ||
						 [self.parent.type isEqualToString:kDWTreeNodeSetKey] ||
						 [self.parent.type isEqualToString:kDWTreeNodeOrderedSetKey] ||
						 [self.parent.type isEqualToString:kDWTreeNodeBagKey] ||
						 [self.parent.type isEqualToString:kDWTreeNodeDictKey]);
	
	if (parentIsList) {
		name = [self typeStringOfEncoding:self.type];
	} else {
		name = self.name;
	}
	
	RXMLElement *appendingElement = nil;
	
	RXMLElement *element = [RXMLElement elementWithTag:name];
	
	if (!parentIsList && self.treeCoder != self && ![self.type isEqualToString:@"B"]) {
		NSString *subname = [self typeStringOfEncoding:self.type];
		if (isList) {
			if ([self.type isEqualToString:kDWTreeNodeDictKey]) {
				subname = @"map";
			} else {
				subname = @"list";
			}
		}
		RXMLElement *typeElement = [RXMLElement elementWithTag:subname];
		[element appendChild:typeElement];
		
		if (isList) {
			if ([self.type isEqualToString:kDWTreeNodeSetKey]) {
				[typeElement setAttribute:@"unique" value:@"true"];
			} else if ([self.type isEqualToString:kDWTreeNodeOrderedSetKey]) {
				[typeElement setAttribute:@"unique" value:@"true"];
				[typeElement setAttribute:@"ordered" value:@"true"];
			} else if ([self.type isEqualToString:kDWTreeNodeBagKey]) {
				[typeElement setAttribute:@"unique" value:@"true"];
				[typeElement setAttribute:@"countable" value:@"true"];
			}
		}
		
		appendingElement = typeElement;
	} else {
		appendingElement = element;
		if ([self.parent.type isEqualToString:kDWTreeNodeDictKey]) {
			[appendingElement setAttribute:self.treeCoder.dictionaryKeyString value:self.name];
		}
	}
	
	if (self.nodes.count > 0) {
		for (DWTreeNode *subnode in self.nodes) {
			RXMLElement *subElement = subnode.XMLElement;
			if (subElement) {
				[appendingElement appendChild:subElement];
			}
		}
	} else {
		NSString *encoding = [self.type copy];
		if ([encoding isEqualToString:@"B"]) {
			NSNumber *boolNumber = (NSNumber *)self.value;
			RXMLElement *boolElement = nil;
			if ([boolNumber boolValue]) {
				boolElement = [RXMLElement elementWithTag:@"true"];
			} else {
				boolElement = [RXMLElement elementWithTag:@"false"];
			}
			[appendingElement appendChild:boolElement];
		} else {
			[appendingElement setText:[self.class stringValueFromObject:self.value encoding:&encoding]];
		}
	}
	
	return element;
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

- (void)setValue:(id)value {
	if (![value isEqual:self.value]) {
		[self markAsChanged];
		self->_value = value;
		if (self.value != nil) {
			[self->_nodes removeAllObjects];
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

#pragma mark - Types/Encodings

- (NSString *)typeStringOfEncoding:(NSString *)encoding {
	NSString *string = [self.class internalTypeStringForEncoding:encoding];
	
	if (string == nil) {
		string = [encoding copy];
	}
	
	return string;
}

+ (NSDictionary *)internalTypes {
	static NSDictionary *internalTypes = nil;
	if (internalTypes == nil) {
		internalTypes = [[NSDictionary alloc] initWithObjectsAndKeys:
						 @"string",		@"NSString",
						 @"string",		@"NSMutableString",
						 @"url",		@"NSURL",
						 @"date",		@"NSDate",
						 @"color",		@"UIColor",
						 @"binary",		@"NSData",
						 @"binary",		@"NSMutableData",
						 @"number",		@"i",
						 @"number",		@"s",
						 @"number",		@"l",
						 @"number",		@"q",
						 @"number",		@"I",
						 @"number",		@"S",
						 @"number",		@"L",
						 @"number",		@"Q",
						 @"number",		@"f",
						 @"number",		@"d",
						 @"char",		@"c",
						 @"rect",		@"CGRect",
						 @"point",		@"CGPoint",
						 @"size",		@"CGSize",
						 @"bool",		@"B",
						 @"location",	@"CLLocation",
						 nil];
	}
	return internalTypes;
}

+ (NSString *)internalTypeStringForEncoding:(NSString *)encoding {
	return [[self internalTypes] objectForKey:encoding];
}

+ (BOOL)isInternalType:(NSString *)encoding {
	return ([self internalTypeStringForEncoding:encoding] != nil);
}

#pragma mark - Importing Objects



- (BOOL)importObject:(id)object {
	
	Class rootClass = [object class];
	if (rootClass) {
		if (self.name == nil) {
			self.name  = NSStringFromClass([object class]);
		}
	}
	
	NSString *objectEncoding = NSStringFromClass([object class]);
	
	if (self.type == nil) {
		self.type = [self typeStringOfEncoding:objectEncoding];
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
			} else if ([description.typeString isEqualToString:@"v"]) {
				DWLog(@"Treecoder skips property \"%@\" of class %@. Unsupported type 'void'.",propertyName,rootClass);
			} else if ([description.typeString isEqualToString:@"#"]) {
				DWLog(@"Treecoder skips property \"%@\" of class %@. Unsupported type 'Class'.",propertyName,rootClass);
			} else if ([description.typeString isEqualToString:@":"]) {
				DWLog(@"Treecoder skips property \"%@\" of class %@. Unsupported type 'SEL'.",propertyName,rootClass);
			} else if ([description.typeString hasPrefix:@"{"]) {
				DWLog(@"Treecoder skips property \"%@\" of class %@. Unsupported type 'struct'.",propertyName,rootClass);
			}  else if ([description.typeString hasPrefix:@"["]) {
				DWLog(@"Treecoder skips property \"%@\" of class %@. Unsupported type 'C array'.",propertyName,rootClass);
			}  else if ([description.typeString hasPrefix:@"("]) {
				DWLog(@"Treecoder skips property \"%@\" of class %@. Unsupported type 'union'.",propertyName,rootClass);
			}  else if ([description.typeString hasPrefix:@"^"]) {
				DWLog(@"Treecoder skips property \"%@\" of class %@. Unsupported type 'pointer'.",propertyName,rootClass);
			}  else if ([description.typeString hasPrefix:@"?"]) {
				DWLog(@"Treecoder skips property \"%@\" of class %@. Unknown type.",propertyName,rootClass);
			}  else if ([description.typeString hasPrefix:@"b"]) {
				DWLog(@"Treecoder skips property \"%@\" of class %@. Unsupported type 'bitfield'.",propertyName,rootClass);
			}			
			else {
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
			
			if ([propertyName isEqualToString:@"CGSize"]) {
				NSLog(@"Size");
			}
			
			if ([self.class isInternalType:propertyDescription.typeString]) {
				
				DWTreeNode *subnode = [DWTreeNode nodeWithName:propertyName];
				subnode.type = propertyDescription.typeString;
				subnode.value = nativeValue;
				[self addNode:subnode];
				
			} else if ([nativeValue isKindOfClass:[NSArray class]]) {
				
				DWTreeNode *arrayNode = [DWTreeNode nodeWithName:propertyName];
				arrayNode.type = kDWTreeNodeArrayKey;
				for (id arrayElement in (NSArray *)nativeValue) {
					DWTreeNode *subnode = [[DWTreeNode alloc] init];
					if ([subnode importObject:arrayElement]) {
						[arrayNode addNode:subnode];
					}
				}
				[self addNode:arrayNode];
			} else if ([nativeValue isKindOfClass:[NSSet class]]) {
				DWTreeNode *arrayNode = [DWTreeNode nodeWithName:propertyName];
				arrayNode.type = kDWTreeNodeSetKey;
				for (id arrayElement in (NSSet *)nativeValue) {
					DWTreeNode *subnode = [[DWTreeNode alloc] init];
					if ([subnode importObject:arrayElement]) {
						[arrayNode addNode:subnode];
					}
				}
				[self addNode:arrayNode];
			}  else if ([nativeValue isKindOfClass:[NSOrderedSet class]]) {
				DWTreeNode *arrayNode = [DWTreeNode nodeWithName:propertyName];
				arrayNode.type = kDWTreeNodeOrderedSetKey;
				for (id arrayElement in (NSOrderedSet *)nativeValue) {
					DWTreeNode *subnode = [[DWTreeNode alloc] init];
					if ([subnode importObject:arrayElement]) {
						[arrayNode addNode:subnode];
					}
				}
				[self addNode:arrayNode];
			}  else if ([nativeValue isKindOfClass:[NSCountedSet class]]) {
				DWTreeNode *arrayNode = [DWTreeNode nodeWithName:propertyName];
				arrayNode.type = kDWTreeNodeBagKey;
				for (id arrayElement in (NSCountedSet *)nativeValue) {
					DWTreeNode *subnode = [[DWTreeNode alloc] init];
					if ([subnode importObject:arrayElement]) {
						[arrayNode addNode:subnode];
					}
				}
				[self addNode:arrayNode];
			}  else if ([nativeValue isKindOfClass:[NSDictionary class]]) {
				DWTreeNode *arrayNode = [DWTreeNode nodeWithName:propertyName];
				arrayNode.type = kDWTreeNodeDictKey;
				for (NSString *nodeKey in (NSDictionary *)nativeValue) {
					id dictElement = [((NSDictionary *)nativeValue) objectForKey:nodeKey];
					DWTreeNode *subnode = [DWTreeNode nodeWithName:nodeKey];
					if ([subnode importObject:dictElement]) {
						[arrayNode addNode:subnode];
					}
				}
				[self addNode:arrayNode];
			} else {
				DWTreeNode *subnode = [DWTreeNode nodeWithName:propertyName];
				if ([subnode importObject:nativeValue]) {
					[self addNode:subnode];
				}
			}
		}
	}
	
	if (self.nodes.count == 0) {
		NSString *objectsValue = nil;
		
		NSString *encoding = [self.type copy];
		objectsValue = [self.class stringValueFromObject:object encoding:&encoding];
		
		if (objectsValue && encoding) {
			self.type = encoding;
			[self setValue:objectsValue];
		}
	}
	
	return (self.name != nil);
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

#pragma mark - Creating objects

- (id)object {
	
	id object = nil;
	
	// create an instance
	Class rootClass = [self classForTreeNode:self];
	if (rootClass) {
		
		// allocating
		object = [rootClass alloc];
		BOOL didInitializeObject = NO;
		
		// initialising
		if ([rootClass conformsToProtocol:@protocol(DWTreeCoding)]) {
			if ([object respondsToSelector:@selector(initWithTreeNode:)]) {
				object = [((id <DWTreeCoding>)object) initWithTreeNode:self];
				didInitializeObject = YES;
			}
		}
		if (didInitializeObject == NO) {
			object = [[rootClass alloc] init];
			// apply properties
			
			NSArray *objectsProperties = [((NSObject *)object) properties];
			
			NSMutableArray *failedPropertyNames = [NSMutableArray array];
			
		}
	}
	
	return object;
}


- (Class)classForTreeNode:(DWTreeNode *)node {
	
	Class class = nil;
	
	if ([self.treeCoder.delegate respondsToSelector:@selector(treeCoder:classForTypeString:)]) {
		class = [self.treeCoder.delegate treeCoder:self.treeCoder classForTypeString:node.type];
	}
	
	if (class == nil) {
		class = NSClassFromString(node.type);
	}
	
	return class;
}

#pragma mark - String/Object/Value conversion

+ (ISO8601DateFormatter *)iso8601DateFormatter {
	static ISO8601DateFormatter *isoDateFormatter = nil;
	if (isoDateFormatter == nil) {
		isoDateFormatter = [[ISO8601DateFormatter alloc] init];
		isoDateFormatter.includeTime = YES;
	}
	return isoDateFormatter;
}

+ (NSString *)stringValueFromObject:(NSObject *)object encoding:(NSString **)encoding {
	
	NSString *stringValue = nil;
	
	if ([object isKindOfClass:[NSString class]]) {
		// String
		stringValue = [object copy];
		if (encoding != NULL) {
			*encoding = @"NSString";
		}
	}
	else if ([object isKindOfClass:[NSURL class]]) {
		// URL
		stringValue = [((NSURL *)object) absoluteString];
		if (encoding != NULL) {
			*encoding = @"NSURL";
		}
	}
	else if ([object isKindOfClass:[UIColor class]]) {
		// Color
		stringValue = [NSString stringWithFormat:@"#%@",[((UIColor *)object) hexStringFromColorAndAlpha]];
		if (encoding != NULL) {
			*encoding = @"UIColor";
		}
	}
	else if ([object isKindOfClass:[NSNumber class]]) {
		// Number
		stringValue = [((NSNumber *)object) stringValue];
		if (encoding != NULL) {
			*encoding = @"NSNumber";
		}
	}
	else if ([object isKindOfClass:[NSDate class]]) {
		// Date
		stringValue = [[self iso8601DateFormatter] stringFromDate:(NSDate *)object];
		if (encoding != NULL) {
			*encoding = @"NSDate";
		}
	} else if ([object isKindOfClass:[NSValue class]]) {
		// NSValue
		NSValue *value = (NSValue *)object;
		NSMutableArray *components = [NSMutableArray array];
		if ([*encoding isEqualToString:@"CGSize"]) {
			CGSize size = [value CGSizeValue];
			[components addObject:[NSNumber numberWithFloat:size.width]];
			[components addObject:[NSNumber numberWithFloat:size.height]];
		} else if ([*encoding isEqualToString:@"CGRect"]) {
			CGRect rect = [value CGRectValue];
			[components addObject:[NSNumber numberWithFloat:rect.origin.x]];
			[components addObject:[NSNumber numberWithFloat:rect.origin.y]];
			[components addObject:[NSNumber numberWithFloat:rect.size.width]];
			[components addObject:[NSNumber numberWithFloat:rect.size.height]];
		}  else if ([*encoding isEqualToString:@"CGPoint"]) {
			CGPoint point = [value CGPointValue];
			[components addObject:[NSNumber numberWithFloat:point.x]];
			[components addObject:[NSNumber numberWithFloat:point.y]];
		}
		
		if (stringValue == nil) {
			stringValue = [components componentsJoinedByString:@" "];
		}
		
	} else if ([object isKindOfClass:[CLLocation class]]) {
		// CLLocation
		CLLocation *location = (CLLocation *)object;
		NSArray *components = [NSArray arrayWithObjects:
							   [NSNumber numberWithDouble:location.coordinate.latitude],
							   [NSNumber numberWithDouble:location.coordinate.longitude],
							   [NSNumber numberWithDouble:location.altitude],
							   [NSNumber numberWithDouble:[location.timestamp timeIntervalSince1970]],
							   nil];
		
		stringValue = [components componentsJoinedByString:@" "];
		if (*encoding != NULL) {
			*encoding = @"CLLocation";
		}
		
	}
	
	return stringValue;
}

+ (id)objectWithClass:(Class)class fromString:(NSString *)string {
	id packedValue = nil;
	
	if ([class isSubclassOfClass:[NSString class]]) {
		//String
		packedValue = [string copy];
		
	} else if ([class isSubclassOfClass:[NSURL class]]) {
		// URL
		packedValue = [NSURL URLWithString:string];
		
	} else if ([class isSubclassOfClass:[UIColor class]]) {
		// Color
		if ([string hasPrefix:@"#"]) {
			string = [string substringFromIndex:1];
		}
		packedValue = [UIColor colorAndAlphaWithHexString:string];
		
	} else if ([class isSubclassOfClass:[NSNumber class]]) {
		// Number
		packedValue = [NSNumber numberWithLongLong:[string longLongValue]];
		
	} else if ([class isSubclassOfClass:[NSDate class]]) {
		// Date
		packedValue = [[self iso8601DateFormatter] dateFromString:string];
		
	}
	
	return packedValue;
}

@end