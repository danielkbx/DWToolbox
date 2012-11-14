//
//  DWInputTableViewController.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 13.11.12.
//
//

#import "DWInputTableViewController.h"

#define kDWInputTableViewControllerTextfieldVerticalPadding 10.0f
#define kDWInputTableViewControllerHorizontalPadding 5.0f
#define kDWInputTableViewControllerTextViewNumberOfLines 7.0f

@interface DWInputTableViewController () <UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, readwrite) DWInputTableViewControllerType type;
@property (nonatomic, strong) DWInputTableViewControllerReturnHandler handler;

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, assign) UIKeyboardType keyboardType;
@property (nonatomic, assign) UITextFieldViewMode clearButtonMode;

@end

@implementation DWInputTableViewController

- (id)initWithType:(DWInputTableViewControllerType)type returnHandler:(DWInputTableViewControllerReturnHandler)handler {
	if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
		self.type = type;
		self.handler = handler;
		
		self.font = [UIFont systemFontOfSize:16.0f];
		self.textColor = [UIColor blackColor];
		
		switch (self.type) {
			case DWInputTableViewControllerTypeText:
				self.autocapitalization = UITextAutocapitalizationTypeSentences;
				self.autocorrection = UITextAutocorrectionTypeDefault;
				self.keyboardType = UIKeyboardTypeAlphabet;
				self.clearButtonMode = UITextFieldViewModeNever;
				
				break;
			case DWInputTableViewControllerTypeTextField:
				self.autocapitalization = UITextAutocapitalizationTypeSentences;
				self.autocorrection = UITextAutocorrectionTypeDefault;
				self.keyboardType = UIKeyboardTypeAlphabet;
				self.clearButtonMode = UITextFieldViewModeWhileEditing;

				break;
			case DWInputTableViewControllerTypeEmail:
				self.autocapitalization = UITextAutocapitalizationTypeNone;
				self.autocorrection = UITextAutocorrectionTypeNo;
				self.keyboardType = UIKeyboardTypeEmailAddress;
				self.clearButtonMode = UITextFieldViewModeWhileEditing;
				
				break;
			case DWInputTableViewControllerTypeNumeric:
				self.autocapitalization = UITextAutocapitalizationTypeNone;
				self.autocorrection = UITextAutocorrectionTypeNo;
				self.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
				self.clearButtonMode = UITextFieldViewModeWhileEditing;
				
				break;
			case DWInputTableViewControllerTypeURL:
				self.autocapitalization = UITextAutocapitalizationTypeNone;
				self.autocorrection = UITextAutocorrectionTypeNo;
				self.keyboardType = UIKeyboardTypeURL;
				self.clearButtonMode = UITextFieldViewModeWhileEditing;
				
				break;
		}		
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (self.type == DWInputTableViewControllerTypeTextField) {
		self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 30.0f)];
		self.textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		self.textView.backgroundColor = [UIColor clearColor];
		self.textView.font = self.font;
		self.textView.textColor = self.textColor;
		self.textView.text = self.inputText;
		self.textView.delegate = self;
		self.textView.contentInset = UIEdgeInsetsMake(-10.0f, -7.0f, 0.0f, 0.0f);
		self.textView.autocapitalizationType = self.autocapitalization;
		self.textView.autocorrectionType = self.autocorrection;
		self.textView.keyboardType = self.keyboardType;

	} else {
		self.textField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 30.0f)];
		self.textField.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		self.textField.backgroundColor = [UIColor clearColor];
		self.textField.font = self.font;
		self.textField.textColor = self.textColor;
		self.textField.placeholder = self.placeholder;
		self.textField.text = self.inputText;
		self.textField.delegate = self;
		self.textField.autocapitalizationType = self.autocapitalization;
		self.textField.autocorrectionType = self.autocorrection;
		self.textField.keyboardType = self.keyboardType;
		self.textField.clearButtonMode = self.clearButtonMode;
		
	}
	
	UIBarButtonItem *returnButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(returnButtonPressed)];
	self.navigationItem.rightBarButtonItem = returnButton;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if (self.type == DWInputTableViewControllerTypeTextField) {
		[self.textView becomeFirstResponder];
	} else {
		[self.textField becomeFirstResponder];
	}
	
}

#pragma mark - Setters

- (void)setHeaderText:(NSString *)headerText {
	if (![self->_headerText isEqualToString:headerText]) {
		self->_headerText = headerText;
		if (self.isViewLoaded) {
			[self.tableView reloadData];
		}
	}
}

- (void)setFooterText:(NSString *)footerText {
	if (![self->_footerText isEqualToString:footerText]) {
		self->_footerText = footerText;
		if (self.isViewLoaded) {
			[self.tableView reloadData];
		}
	}
}

- (void)setPlaceholder:(NSString *)placeholder {
	if (![self->_placeholder isEqualToString:placeholder]) {
		self->_placeholder = placeholder;
		self.textField.placeholder = placeholder;
	}
}

- (void)setInputText:(NSString *)inputText {
	if (![self->_inputText isEqualToString:inputText]) {
		self->_inputText = [inputText copy];
		self.textField.text = inputText;
		self.textView.text = inputText;
	}
}

- (void)setFont:(UIFont *)font {
	if (font != self->_font) {
		self->_font = [font copy];
		self.textField.font = font;
		self.textView.font = font;
	}
}

- (void)setTextColor:(UIColor *)textColor {
	if (self->_textColor != textColor) {
		self->_textColor = [textColor copy];
		self.textField.textColor = textColor;
		self.textView.textColor = textColor;
	}
}

- (void)setAutocapitalization:(UITextAutocapitalizationType)autocapitalization {
	self->_autocapitalization = autocapitalization;
	self.textField.autocapitalizationType = autocapitalization;
	self.textView.autocapitalizationType = autocapitalization;
}

- (void)setAutocorrection:(UITextAutocorrectionType)autocorrection {
	self->_autocorrection = autocorrection;
	self.textField.autocorrectionType = autocorrection;
	self.textView.autocorrectionType = autocorrection;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
	UIView *textControl = (self.type == DWInputTableViewControllerTypeTextField) ? self.textView : self.textField;
	textControl.frame = CGRectInset(cell.contentView.frame, kDWInputTableViewControllerHorizontalPadding, kDWInputTableViewControllerTextfieldVerticalPadding);
	[cell.contentView addSubview:textControl];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return self.headerText;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return self.footerText;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat lineHeight = [self.font lineHeight];
	CGFloat factor = (self.type == DWInputTableViewControllerTypeTextField) ? kDWInputTableViewControllerTextViewNumberOfLines : 1;
	return (factor * lineHeight) + (2*kDWInputTableViewControllerTextfieldVerticalPadding);
}

#pragma mark - Textfield delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	self->_inputText = [[textField.text stringByReplacingCharactersInRange:range withString:string] copy];
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	self.handler(self.inputText);
	return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
	self.inputText = nil;
	return YES;
}

#pragma mark - TextView Delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	self->_inputText = [[textView.text stringByReplacingCharactersInRange:range withString:text] copy];
	return YES;
}

#pragma mark - BarButton

- (void)returnButtonPressed {
	self.handler(self.inputText);
}

@end