//
//  LoginViewController.m
//  LetMeGuess
//
//  Created by Nitin Karki on 10/6/15.
//  Copyright © 2015 appPond. All rights reserved.
//

#import "LoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import <Parse/Parse.h>
#import "JVFloatLabeledTextField.h"
#import "RKDropdownAlert.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *usernameTextField;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *passwordTextField;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoImageTopSpaceConstraint;

@end

@implementation LoginViewController

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
    if ([self validateInput]) {
        [self dismissKeyboard];
        
        PFUser *newUser = [PFUser user];
        newUser.username = self.usernameTextField.text;
        newUser.password = self.passwordTextField.text;
 
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

#pragma mark - Utiliy

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
    
    if (inputErrors == 2) {
        message = @"Username and Password cannot be empty.";
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
}

- (void)keyboardWillShow {
    [self adjustViewForKeyboard];
}

- (void)keyboardWillHide {
    [self adjustViewForKeyboard];
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
