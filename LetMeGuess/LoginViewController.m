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

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
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
                                                [self hideAllAndShowSuccess:YES];
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
                [self hideAllAndShowSuccess:NO];
            } else {
                NSString *errorString = [error userInfo][@"error"];
                [AlertUtil showAlertControllerWithMessage:errorString title:@"Registration Error" sender:self];
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

- (void)hideAllAndShowSuccess:(BOOL)isLoginCheck {
    [UIView transitionWithView:self.logoImageView
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:nil
                    completion:nil];
    [UIView transitionWithView:self.usernameTextField
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:nil
                    completion:nil];
    [UIView transitionWithView:self.passwordTextField
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:nil
                    completion:nil];
    [UIView transitionWithView:self.loginButton
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:nil
                    completion:nil];
    [UIView transitionWithView:self.signUpButton
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:nil
                    completion:^(BOOL finished) {
                        if (finished) {
                            [self showLoginSuccessCheck:isLoginCheck];
                        }
                    }];
    
    
    self.logoImageView.hidden = YES;
    self.usernameTextField.hidden = YES;
    self.passwordTextField.hidden = YES;
    self.loginButton.hidden = YES;
    self.signUpButton.hidden = YES;
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



#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if ([self validateInput]) {
        [self loginPressed:nil];
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
