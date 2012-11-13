//
//  DWInputTableViewController.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 13.11.12.
//
//

#import <UIKit/UIKit.h>

typedef enum {
	DWInputTableViewControllerTypeText,
	DWInputTableViewControllerTypeTextField,
	DWInputTableViewControllerTypeEmail,
	DWInputTableViewControllerTypeURL,
	DWInputTableViewControllerTypeNumeric
} DWInputTableViewControllerType;

typedef void (^DWInputTableViewControllerReturnHandler)(NSString *input);

@interface DWInputTableViewController : UITableViewController

@property (nonatomic, readonly) DWInputTableViewControllerType type;

@property (nonatomic, copy) UIFont *font;
@property (nonatomic, copy) UIColor *textColor;

@property (nonatomic, strong) NSString *headerText;
@property (nonatomic, strong) NSString *footerText;
@property (nonatomic, strong) NSString *placeholder;	// not supported when the type is text field

@property (nonatomic, assign) UITextAutocapitalizationType autocapitalization;
@property (nonatomic, assign) UITextAutocorrectionType autocorrection;

@property (nonatomic, strong) NSString *inputText;

- (id)initWithType:(DWInputTableViewControllerType)type returnHandler:(DWInputTableViewControllerReturnHandler)handler;

@end
