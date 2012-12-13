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

- (RXMLElement *)XMLElement {
	RXMLElement *element = [RXMLElement elementWithTag:self.name];
	
	if (self.attributes.count > 0) {
		for (NSString *attributeName in self.attributes) {
			NSString *attributeValue = [self.attributes objectForKey:attributeName];
			[element setAttribute:attributeName value:attributeValue];
		}
	}
	
	if (self.nodes.count > 0) {
		for (DWTreeNode *node in self.nodes) {
			RXMLElement *subElement = [node XMLElement];
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

- (NSDictionary *)JSONDictionary {
	
	NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:self.attributes];
	
	if (self.nodes.count > 0) {
		for (DWTreeNode *node in self.nodes) {
			NSDictionary *nodeDictionary = [node JSONDictionary];
			[data setObject:nodeDictionary forKey:node.name];
		}
	} else if (self.value != nil) {
		[data setObject:self.value forKey:@"value"];
	}
	
	return data;
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

@end