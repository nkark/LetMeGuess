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
#import "AlertUtil.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;

@end

@implementation LoginViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupLoginButtons];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)setupLoginButtons {
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
        self.username = self.usernameTextField.text;
        self.password = self.passwordTextField.text;
        
        [PFUser logInWithUsernameInBackground:self.username
                                     password:self.password
                                        block:^(PFUser *user, NSError *error) {
                                            if (user) {
                                                [PFUser becomeInBackground:user.sessionToken];
                                                [self dismissViewControllerAnimated:YES completion:nil];
                                            } else {
                                                if ([[error userInfo][@"error"] isEqualToString:@"invalid login parameters"]) {
                                                    [AlertUtil showAlertControllerWithMessage:@"Invalid username and/or password. Please try again."
                                                                                        title:@"Invalid login."
                                                                                       sender:self];
                                                }
                                            }
        }];
    }
}

- (IBAction)signUpPressed:(id)sender {
    if ([self validateInput]) {
        self.username = self.usernameTextField.text;
        self.password = self.passwordTextField.text;
        
        PFUser *newUser = [PFUser user];
        newUser.username = self.username;
        newUser.password = self.password;
 
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                NSString *errorString = [error userInfo][@"error"];
                [AlertUtil showAlertControllerWithMessage:errorString title:@"Sign Up Error" sender:self];
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
        [AlertUtil showAlertControllerWithMessage:message title:@"Wait!" sender:self];
        return NO;
    }
}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if ([self validateInput]) {
        [AlertUtil showAlertControllerWithMessage:@"Good to go" title:@"Success" sender:self];
        return NO;
    }

    return YES;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
