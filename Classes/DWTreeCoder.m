//
//  DWTreeCoder.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 13.12.12.
//
//

#import "DWTreeCoder.h"
#import "DWTreeNode_Private.h"

#import "RXMLElement.h"

@interface DWTreeCoder()

@property (nonatomic, strong) NSMutableDictionary *classMappings;

@end

@implementation DWTreeCoder

- (id)init {
	if ((self = [super init])) {
		self.classMappings = [[NSMutableDictionary alloc] init];
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
			
			Class rootClass = [self classForTreeNode:self];
			if (rootClass) {
				rootObject = [[rootClass alloc] init];
			}
		}
		
		if (completion) {
			dispatch_async(dispatch_get_main_queue(), ^{
				completion(success,rootObject);
			});
		}
	});
}

- (BOOL)writeToURL:(NSURL *)URL format:(DWTreeNodeFormat)format {
	
	NSData *data = nil;
	
	if (format == DWTreeNodeFormatXML) {
		
		RXMLElement *element = [self XMLElement];
		if (element) {
			data = [element dataWithOptions:RXMLWritingOptionIndent];
		}
		
	} else if (format == DWTreeNodeFormatJSON) {
		
		NSDictionary *JSONDictionary = [NSDictionary dictionaryWithObject:[self JSONDictionary] forKey:self.name];
		data = [NSJSONSerialization dataWithJSONObject:JSONDictionary
											   options:NSJSONWritingPrettyPrinted
												 error:NULL];
	}
	
	if (data) {
		return [data writeToURL:URL atomically:NO];
	}
	
	return NO;
}

#pragma mark - Creation

- (void)mapTreeNodePath:(NSString *)path toClass:(Class)class {
	if (path.length > 0 && class) {
		[self.classMappings setObject:class forKey:path];
	}
}

- (Class)classForTreeNode:(DWTreeNode *)node {
	
	BOOL shouldCreate = YES;
	if ([self.objectCreationDelegate respondsToSelector:@selector(treeCoder:shouldCreateObjectForTreeNode:)]) {
		shouldCreate = [self.objectCreationDelegate treeCoder:self shouldCreateObjectForTreeNode:node];
	}
	
	if (shouldCreate) {
		
		NSString *nodePath = node.path;
		Class class = [self.classMappings objectForKey:nodePath];
		
		if ([self.objectCreationDelegate respondsToSelector:@selector(treeCoder:classForTreeNode:proposedClass:)]) {
			class = [self.objectCreationDelegate treeCoder:self classForTreeNode:node proposedClass:class];
		}
		return class;
	}
	
	return nil;
}

@end
