//
//  DWConditionalInvokation.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 22.11.12.
//
//

#import <Foundation/Foundation.h>

/**
 DWConditionInvocations performs the block (target/action) when ALL conditions are met.
 
 Conditions are simple identifiers which can be ticked. When all conditions are ticked the action is invoced and all
 conditions are reseted.
 
 A conditions can be single identifier (an AND condition) or a group of indentifiers (several OR conditions). A group of identifiers is considers as ticked when one identifier of the group is ticked.
 
 Whenever you tick an identifier by calling tick: the target/action (or the block) is invoked if the conditions are met.
 
 */
@interface DWConditionalInvocation : NSObject

- (id)initWithTarget:(id)target action:(SEL)sel;
- (id)initWithBlock:(void(^)())block;

/* Adds a new condition identifier (and AND condition). */
- (void)addCondition:(NSString *)identifier;
/* Add a group of condition identifiers (OR conditions). This group is met if ONE of the group is ticked. */
- (void)addConditions:(NSString *)identifier, ... NS_REQUIRES_NIL_TERMINATION;

/* Ticks the condifiton with the identifier.
 
 If all (AND) conditions are met, the target/action is invoked and all conditions are unticked.
 */
- (void)tick:(NSString *)identifier;

/* Invokes the action and resets all conditions. */
- (void)invoke;
@end