//
//  DWActionSheet.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 15.11.12.
//
//

#import "DWActionSheet.h"

@interface DWActionSheetItem ()

@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, strong) DWActionSheetItemPressedHandler handler;

@property (nonatomic, assign) BOOL isCancelItem;

@end

@implementation DWActionSheetItem

- (id)initWithTitle:(NSString *)title handler:(DWActionSheetItemPressedHandler)handler {
	if ((self = [super init])) {
		self.title = title;
		self.handler = handler;
		self.isCancelItem = NO;
	}
	return self;
}

- (id)initCancelItemWithTitle:(NSString *)title handler:(DWActionSheetItemPressedHandler)handler {
	if ((self = [self initWithTitle:title handler:handler])) {
		self.isCancelItem = YES;
	}
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ (%@)", [super description], self.title];
}

@end

static NSMutableArray *instances;

@interface DWActionSheet () <UIActionSheetDelegate>

@property (nonatomic, copy, readwrite) NSString *title;

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) DWActionSheetItem *cancelItem;

@end

@implementation DWActionSheet

+ (NSMutableArray *)instances {
	if (instances == nil) {
		instances = [[NSMutableArray alloc] init];
	}
	return instances;
}

+ (void)registerActionSheet:(DWActionSheet *)sheet {
	if (sheet) {
		[[self instances] addObject:sheet];
	}
}

+ (void)deregisterActionSheet:(DWActionSheet *)sheet {
	if (sheet) {
		[[self instances] removeObject:sheet];
	}
}

- (id)initWithTitle:(NSString *)title {
	if ((self = [super init])) {
		self.title = title;
		self.items = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)addItem:(DWActionSheetItem *)item {
	assert(item);
	if (item.isCancelItem) {
		if (self.cancelItem != nil) {
			DWLog(@"Assing a cancel item (%@) to a action sheet which has already a cancel item (%@).",item.title, self.cancelItem.title);
		}
		self.cancelItem = item;
	} else {
		[self.items addObject:item];
	}
}

- (DWActionSheetItem *)addItemWithTitle:(NSString *)title handler:(DWActionSheetItemPressedHandler)handler {
	DWActionSheetItem *item = [[DWActionSheetItem alloc] initWithTitle:title handler:handler];
	[self addItem:item];
	return item;
}

- (DWActionSheetItem *)addCancelItemWithTitle:(NSString *)title handler:(DWActionSheetItemPressedHandler)handler {
	DWActionSheetItem *item = [[DWActionSheetItem alloc] initCancelItemWithTitle:title handler:handler];
	[self addItem:item];
	return item;
}

- (UIActionSheet *)_internalActionSheet {
	
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:self.title
													   delegate:self
											  cancelButtonTitle:self.cancelItem.title
										 destructiveButtonTitle:nil
											  otherButtonTitles:nil];

	for (DWActionSheetItem *item in self.items) {
		[sheet addButtonWithTitle:item.title];
	}
	
	return sheet;
}

- (void)showInView:(UIView *)view {
	[[self class] registerActionSheet:self];
	[[self _internalActionSheet] showInView:view];
}

- (void)showFromToolbar:(UIToolbar *)toolbar {
	[[self class] registerActionSheet:self];
	[[self _internalActionSheet] showFromToolbar:toolbar];
}

- (void)showFromTabbar:(UITabBar *)tabbar {
	[[self class] registerActionSheet:self];
	[[self _internalActionSheet] showFromTabBar:tabbar];
}

- (void)showFromBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated {
	[[self class] registerActionSheet:self];
	[[self _internalActionSheet] showFromBarButtonItem:item animated:animated];
}

- (void)showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated {
	[[self class] registerActionSheet:self];
	[[self _internalActionSheet] showFromRect:rect inView:view animated:animated];
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {

	NSString *pressedTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
	
	if ([pressedTitle isEqualToString:self.cancelItem.title]) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[[self class] deregisterActionSheet:self];
			self.cancelItem.handler();
		});
	}
	
	for (DWActionSheetItem *item in self.items) {
		if ([pressedTitle isEqualToString:item.title]) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[[self class] deregisterActionSheet:self];
				item.handler();
			});
		}
	}
}

@end
