/*
 * JBoss, Home of Professional Open Source.
 * Copyright Red Hat, Inc., and individual contributors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "AGContactDetailsViewController.h"
#import "AGContact.h"
#import "AGValidationTextfield.h"

@interface AGContactDetailsViewController ()

@property (weak, nonatomic) IBOutlet AGValidationTextfield *firstnameTxtField;
@property (weak, nonatomic) IBOutlet AGValidationTextfield *lastnameTxtField;
@property (weak, nonatomic) IBOutlet AGValidationTextfield *phoneTxtField;
@property (weak, nonatomic) IBOutlet AGValidationTextfield *emailTxtField;
@property (weak, nonatomic) IBOutlet AGValidationTextfield *birthdateTxtField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) NSArray *textfields;

@property (strong, nonatomic) UITextField *activeTxtField;

@end

@implementation AGContactDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];

    // setup a UIDatePicker when clicked on the date field
    UIDatePicker *datePicker = [[UIDatePicker alloc]init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker addTarget:self action:@selector(updateDateTextField:) forControlEvents:UIControlEventValueChanged];
    
    // setup the min/max date on the date picker to comply with the server side
    datePicker.minimumDate = [self dateFromString:@"1900-01-01"];
    datePicker.maximumDate = [NSDate date];
    
    [self.birthdateTxtField setInputView:datePicker];

    // if set, edit existing one
    if (self.contact) {
        self.firstnameTxtField.text = self.contact.firstname;
        self.lastnameTxtField.text = self.contact.lastname;
        self.phoneTxtField.text = self.contact.phoneNumber;
        self.emailTxtField.text = self.contact.email;
        self.birthdateTxtField.text = self.contact.birthdate;
        [datePicker setDate:[self dateFromString:self.birthdateTxtField.text]];
    }
    
    self.textfields = @[self.firstnameTxtField, self.lastnameTxtField, self.phoneTxtField, self.emailTxtField, self.birthdateTxtField];
}

#pragma mark - Action methods

- (IBAction)cancel:(id)sender {
    [self.delegate contactDetailsViewControllerDidCancel:self];
}

- (IBAction)save:(id)sender {
    __block BOOL invalidForm = NO;
    
    // enumare all textfields and ask them to validate themselves
    [self.textfields enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![(AGValidationTextfield *)obj validate]) {
            invalidForm = YES;
        }
    }];
    
    // if invalid entries found, no need to continue
    if (invalidForm)
        return;
    
    // else time to create contact
    
    AGContact *contact = self.contact;
  
    if (!contact) {
        contact = [[AGContact alloc] init];
    }

    contact.firstname = self.firstnameTxtField.text;
    contact.lastname = self.lastnameTxtField.text;
    contact.phoneNumber = self.phoneTxtField.text;
    contact.email = self.emailTxtField.text;
    contact.birthdate = self.birthdateTxtField.text;
    
    // call delegate to add it
    [self.delegate contactDetailsViewController:self didSave:contact];
}

// Called when user chooses a new date from date picket to adjust to the correct format
- (void)updateDateTextField:(id)sender {
    UIDatePicker *picker = (UIDatePicker*)self.birthdateTxtField.inputView;
    
    self.birthdateTxtField.text = [self stringFromDate:picker.date];
}

#pragma mark - Date utility methods

- (NSDate*)dateFromString:(NSString *) date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];

    return [dateFormatter dateFromString:date];
}

- (NSString *)stringFromDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    return [dateFormatter stringFromDate:date];
}

#pragma mark - Keyboard utility methods

- (void)registerForKeyboardNotifications {
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tapRecognizer];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeTxtField = textField;
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.activeTxtField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:self.activeTxtField.frame animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)tap:(UIGestureRecognizer *)gesture {
    [self.view endEditing:YES];
}

@end
