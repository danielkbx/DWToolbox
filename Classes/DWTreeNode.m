//
//  DWTreeNode.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 13.12.12.
//
//

#import "DWTreeNode.h"
#import "DWTreeNode_Private.h"

#import "RXMLElement.h"

@interface DWTreeNode () {
	
	NSMutableDictionary *_nodes;
	NSMutableDictionary *_attributes;
	
}

- (id)initWithXMLElement:(RXMLElement *)element;

@property (nonatomic, assign) DWTreeNodeFormat format;

@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSDictionary *attributes;
@property (nonatomic, strong, readwrite) NSDictionary *nodes;

@end

@implementation DWTreeNode

@synthesize nodes = _nodes;
@synthesize attributes = _attributes;

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ %@='%@', Attributes:%u",[super description], self.name, self.value, self.attributes.count];
}

+ (DWTreeNode *)nodeWithName:(NSString *)name {
	DWTreeNode *node = [[DWTreeNode alloc] init];
	node.name = name;
	return node;
}

- (id)init {
	if ((self = [super init])) {
		self->_nodes = [[NSMutableDictionary alloc] init];
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

			self.format = DWTreeNodeStorageTypeXML;
			
			RXMLElement *fileElement = [RXMLElement elementFromXMLData:content];
			if (fileElement) {
				success = [self readXMLElement:fileElement];
			}
		}
		
	}

	return success;
}

#pragma mark - XML

- (BOOL)readXMLElement:(RXMLElement *)element {
	BOOL success = NO;
	
	if (element) {
		success = YES;
		self.name = element.tag;
		
		[self->_attributes addEntriesFromDictionary:element.attributes];
		
		[element iterate:@"*" usingBlock:^(RXMLElement *subelement) {
			DWTreeNode *node = [[DWTreeNode alloc] initWithXMLElement:subelement];
			if (node) {
				node.parent = self;
				if (node.value.length == 0) node.value = nil;
				[self->_nodes setObject:node forKey:node.name];
			}
		}];
		if (self->_nodes.count == 0) {
			self.value = [element text];
		}
	}
	
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
		for (DWTreeNode *node in self.nodes.allValues) {
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

#pragma mark - Value

- (void)setValue:(NSString *)value {
	if (![value isEqualToString:self.value]) {
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
		[self->_attributes setObject:value forKey:name];
	}
}

- (void)removeAttribute:(NSString *)name {
	if (name != nil) {
		[self->_attributes removeObjectForKey:name];
	}
}

#pragma mark - Nodes

- (DWTreeNode *)nodeWithName:(NSString *)name {
	return [self.nodes objectForKey:name];
}

- (void)addNode:(DWTreeNode *)node {
	if (node.name) {
		[self->_nodes setObject:node forKey:node.name];
		self.value = nil;
	}
}

- (void)removeNode:(DWTreeNode *)node {
	if (node.name) {
		[self->_nodes removeObjectForKey:node.name];
	}
}

@end