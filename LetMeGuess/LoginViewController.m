//
//  LoginViewController.m
//  LetMeGuess
//
//  Created by Nitin Karki on 10/6/15.
//  Copyright © 2015 appPond. All rights reserved.
//

#import "LoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MyConstants.h"
#import <Parse/Parse.h>
#import "JVFloatLabeledTextField.h"
#import "RKDropdownAlert.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *usernameTextField;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *passwordTextField;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *emailTextField;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoImageTopSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signInButtonTopSpaceConstraint;

@end

@implementation LoginViewController

BOOL isKeyboardShowing;

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupLoginScreen];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self registerKeyboard];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self deRegisterKeyboard];
}

- (void)setupLoginScreen {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    self.loginButton.layer.cornerRadius = 10;
    self.loginButton.clipsToBounds = YES;
    self.signUpButton.layer.cornerRadius = 10;
    self.signUpButton.clipsToBounds = YES;
}

#pragma mark - Login/Sign Up

- (void)dismissLogin {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)loginPressed:(id)sender {
    [self hideEmailField];
    if ([self validateInput]) {
        [self dismissKeyboard];
        
        [PFUser logInWithUsernameInBackground:self.usernameTextField.text
                                     password:self.passwordTextField.text
                                        block:^(PFUser *user, NSError *error) {
                                            if (user) {
                                                [PFUser becomeInBackground:user.sessionToken];
                                                [self hideAllAndShowSuccess:YES];
                                            } else if (error) {
                                                NSString *errorMessage = [error userInfo][@"error"];
                                                if ([errorMessage isEqualToString:@"invalid login parameters"]) {
                                                    [RKDropdownAlert title:@"Wait!" message:@"Invalid username and/or password. Please try again." backgroundColor:ALERT_ERROR_COLOR textColor:[UIColor whiteColor]];
                                                }
                                            }
        }];
    }
}

- (IBAction)signUpPressed:(id)sender {
    if (self.emailTextField.isHidden) {
        [self showEmailField];
    } else {
        [self signUp];
    }
}

- (void)signUp {
    if ([self validateInput]) {
        if ([self validateEmail:self.emailTextField.text]) {
            PFUser *newUser = [PFUser user];
            newUser.username = self.usernameTextField.text;
            newUser.password = self.passwordTextField.text;
            newUser.email = self.emailTextField.text;
            
            [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [self hideAllAndShowSuccess:NO];
                } else if (error) {
                    NSString *errorString = [error userInfo][@"error"];
                    [RKDropdownAlert title:@"Error" message:errorString backgroundColor:ALERT_ERROR_COLOR textColor:[UIColor whiteColor]];
                }
            }];
        }
    }
}

- (BOOL)validateEmail:(NSString *) emailString {
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
    
    if ([emailTest evaluateWithObject:emailString]) {
        return YES;
    } else {
        [RKDropdownAlert title:@"Wait!" message:@"Please enter a valid email address." backgroundColor:ALERT_ERROR_COLOR textColor:[UIColor whiteColor]];
        return NO;
    }
}

#pragma mark - Utiliy

- (void)showEmailField {
    self.signInButtonTopSpaceConstraint.constant += 60;
    self.emailTextField.frame = CGRectMake(self.emailTextField.frame.origin.x, self.emailTextField.frame.origin.y, self.emailTextField.frame.size.width, 0);
    self.emailTextField.hidden = NO;
    
    [UIView animateWithDuration:1
                     animations:^{
                         [self.view layoutIfNeeded];
                         self.emailTextField.frame = CGRectMake(self.emailTextField.frame.origin.x, self.emailTextField.frame.origin.y, self.emailTextField.frame.size.width, 42);
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (void)hideEmailField {
    self.signInButtonTopSpaceConstraint.constant -= 60;
    
    [UIView animateWithDuration:1
                     animations:^{
                         [self.view layoutIfNeeded];
                         self.emailTextField.frame = CGRectMake(self.emailTextField.frame.origin.x, self.emailTextField.frame.origin.y, self.emailTextField.frame.size.width, 0);
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             self.emailTextField.hidden = YES;
                         }
                     }];
    
}

- (BOOL)validateInput {
    NSString *message = @"Success";
    NSInteger inputErrors = 0;
    
    if (self.usernameTextField.text.length == 0) {
        message = @"Username cannot be empty.";
        inputErrors++;
    }
    
    if (self.passwordTextField.text.length == 0){
        message = @"Password cannot be empty.";
        inputErrors++;
    }
    
    if ([message isEqualToString:@"Success"]) {
        return YES;
    } else {
        [RKDropdownAlert title:@"Wait!" message:message backgroundColor:ALERT_ERROR_COLOR textColor:[UIColor whiteColor]];
        return NO;
    }
}

- (void)hideAllAndShowSuccess:(BOOL)isLoginCheck {
    [UIView transitionWithView:self.logoImageView
                      duration:1
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        self.logoImageView.hidden = YES;
                    }
                    completion:nil];
    [UIView transitionWithView:self.usernameTextField
                      duration:1
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        self.usernameTextField.hidden = YES;
                    }
                    completion:nil];
    [UIView transitionWithView:self.passwordTextField
                      duration:1
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        self.passwordTextField.hidden = YES;
                    }
                    completion:nil];
    if (!self.emailTextField.isHidden) {
        [UIView transitionWithView:self.emailTextField
                          duration:1
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{
                            self.emailTextField.hidden = YES;
                        }
                        completion:nil];
    }
    [UIView transitionWithView:self.loginButton
                      duration:1
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        self.loginButton.hidden = YES;
                    }
                    completion:nil];
    [UIView transitionWithView:self.signUpButton
                      duration:1
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        self.signUpButton.hidden = YES;
                    }
                    completion:^(BOOL finished) {
                        if (finished) {
                            [self showLoginSuccessCheck:isLoginCheck];
                        }
                    }];
}

- (void)showLoginSuccessCheck:(BOOL)isLoginCheck {
    UIImageView *successCheck;
    if (isLoginCheck) {
        successCheck = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginSuccessCheck"]];
        successCheck.frame = CGRectMake(0, 0, 250, 250);
    } else {
        successCheck = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"registrationSuccessCheck"]];
        successCheck.frame = CGRectMake(0, 0, 250, 300);
    }
    
    successCheck.center = self.view.center;
    successCheck.alpha = 0;
    [self.view addSubview:successCheck];
    
    [UIView transitionWithView:successCheck
                      duration:1
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^ {
                        successCheck.alpha = 1;
                    }
                    completion:^(BOOL finished) {
                        [self performSelector:@selector(dismissLogin) withObject:nil afterDelay:1];
                    }];
}

#pragma mark - Keyboard

- (void)dismissKeyboard {
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
}

- (void)keyboardWillShow {
    if (!isKeyboardShowing) {
        [self adjustViewForKeyboard];
        isKeyboardShowing = YES;
    }
}

- (void)keyboardWillHide {
    if (isKeyboardShowing) {
        [self adjustViewForKeyboard];
        isKeyboardShowing = NO;
    }
}

- (void)registerKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)deRegisterKeyboard {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)adjustViewForKeyboard {
    self.logoImageTopSpaceConstraint.constant = -self.logoImageTopSpaceConstraint.constant;
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:nil];
}

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event {
    [self dismissKeyboard];
    
}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
