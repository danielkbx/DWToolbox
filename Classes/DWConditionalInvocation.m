//
//  DWConditionalInvokation.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 22.11.12.
//
//

#import "DWConditionalInvocation.h"

@interface DWConditionalInvocation ()

@property (nonatomic, copy) void (^block)(void);
@property (nonatomic, strong) NSMutableArray *events;

@end

@implementation DWConditionalInvocation

- (id)initWithTarget:(id)target action:(SEL)sel {
	return [self initWithBlock:^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		[target performSelector:sel];
#pragma clang diagnostic pop
	}];
}

- (id)initWithBlock:(void (^)())block {
	if ((self = [super init])) {
		self.block = block;
		self.events = [[NSMutableArray alloc] init];
	}
 	return self;
}

# pragma mark - Conditions

- (void)addCondition:(NSString *)identifier {
	[self addConditions:identifier, nil];
}

- (void)addConditions:(NSString *)identifier, ... {
	va_list args;
    va_start(args, identifier);
	
	NSMutableDictionary *identifiers = [NSMutableDictionary dictionary];
    for (NSString *arg = identifier; arg != nil; arg = va_arg(args, NSString*))
    {
		[identifiers setObject:[NSNumber numberWithBool:NO] forKey:arg];
    }
    va_end(args);
	[self.events addObject:identifiers];
}

- (void)tick:(NSString *)tickedIdentifier {
	BOOL didTick = NO;
	@synchronized(self) {
		
		for (NSMutableDictionary *event in self.events) {
			for (NSString *identifier in event.allKeys) {
				if ([identifier isEqualToString:tickedIdentifier]) {
					[event setObject:[NSNumber numberWithBool:YES] forKey:identifier];
					didTick = YES;
				}
			}
		}
	}
	if (didTick) {
		[self invokeIfSufficient];
	}
}

#pragma mark - Invocation

- (void)invokeIfSufficient {
	
	BOOL isSufficient = YES;
	NSUInteger i = 0;
	while (isSufficient && i < self.events.count) {
		NSMutableDictionary *event = [self.events objectAtIndex:i++];
		isSufficient = isSufficient && [self isEventTicked:event];
	}
	
	if (isSufficient) {
		[self invoke];
		

	}
}

- (BOOL)isEventTicked:(NSMutableDictionary *)event {
	BOOL isTicked = NO;
	
	for (NSNumber *values in event.allValues) {
		if (values.boolValue == YES) {
			isTicked = YES;
			break;
		}
	}
	
	return isTicked;
}

- (void)invoke {
	@synchronized(self) {
		for (NSMutableDictionary *event in self.events) {
			for (NSString *identifier in event.allKeys) {
				[event setObject:[NSNumber numberWithBool:NO] forKey:identifier];
			}
		}
	}
	self.block();
}

@end
