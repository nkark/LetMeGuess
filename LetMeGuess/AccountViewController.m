//
//  AccountViewController.m
//  LetMeGuess
//
//  Created by Nitin Karki on 10/7/15.
//  Copyright © 2015 appPond. All rights reserved.
//

#import "AccountViewController.h"
#import "AlertUtil.h"

@interface AccountViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *changeUsernameSuccessView;

@end

@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (![PFUser currentUser]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self setupAccountScreen];
    }
}

#pragma mark - Utility

- (void)setupAccountScreen {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    [self setupProfilePicView];
}

- (void)dismissKeyboard {
    [self.usernameTextField resignFirstResponder];
}

- (void)setupProfilePicView {
    self.profilePicImageView.layer.cornerRadius = 50;
    self.profilePicImageView.layer.masksToBounds = YES;
    self.profilePicImageView.layer.borderWidth = 1.75;
    self.profilePicImageView.layer.borderColor = [[UIColor grayColor] CGColor];
    
    self.usernameTextField.text = [PFUser currentUser].username;
}

- (void)saveNewUsername:(NSString *)newUsername {
    [[PFUser currentUser] setUsername:newUsername];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL success, NSError *error) {
        if (success) {
            [self.editUsernameButton setTitle:@"Edit" forState:UIControlStateNormal];
            [self.editUsernameButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            
            [UIView animateWithDuration:1 delay:0
                                options:UIViewAnimationOptionTransitionCrossDissolve
                             animations:^{
                                 self.changeUsernameSuccessView.hidden = NO;
                                 self.changeUsernameSuccessView.alpha = 1;
                             }
                             completion:^(BOOL finished) {
                                if (finished) {
                                    [self performSelector:@selector(dismissChangeUsernameSuccess)
                                               withObject:nil afterDelay:1];
                                    [self.usernameTextField setUserInteractionEnabled:NO];
                                    [self.usernameTextField resignFirstResponder];
                                }
                             }];
        } else if (error) {
            NSString *errMssg = [error userInfo][@"error"];
            [AlertUtil showAlertControllerWithMessage:@"" title:errMssg sender:self];
        }
    }];
}

- (void)dismissChangeUsernameSuccess {
    [UIView animateWithDuration:1 delay:0
                        options:UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                         self.changeUsernameSuccessView.alpha = 0;
                         self.changeUsernameSuccessView.hidden = YES;
                     }
                     completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)editUsernamePressed:(id)sender {
    [self.usernameTextField resignFirstResponder];
    
    if ([self.editUsernameButton.titleLabel.text isEqualToString:@"Edit"]) {
        [self.usernameTextField setUserInteractionEnabled:YES];
        
        [UIView transitionWithView:self.usernameTextField duration:0.3
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^ {
                            [self.usernameTextField becomeFirstResponder];
                        }
                        completion:nil];
        
        [self.editUsernameButton setTitle:@"Save" forState:UIControlStateNormal];
        [self.editUsernameButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];

        return;
    }

    if ([self.editUsernameButton.titleLabel.text isEqualToString:@"Save"]) {
        if (self.usernameTextField.text.length > 0) {
            [self saveNewUsername:self.usernameTextField.text];
        } else {
            [AlertUtil showAlertControllerWithMessage:@"" title:@"Username cannot be empty." sender:self];
        }
    }
}

- (IBAction)editPasswordPressed:(id)sender {
//    [self.passwordTextField setUserInteractionEnabled:YES];
//    
//    UITextPosition *start = [self.passwordTextField positionFromPosition:[self.passwordTextField beginningOfDocument] offset:0];
//    [UIView transitionWithView:self.passwordTextField
//                      duration:0.3
//                       options:UIViewAnimationOptionTransitionFlipFromRight
//                    animations:^{
//                        [self.passwordTextField becomeFirstResponder];
//                        [self.passwordTextField setSelectedTextRange:[self.passwordTextField textRangeFromPosition:start toPosition:start]];
//                    }completion:nil];
}

- (IBAction)donePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)signOutPressed:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError *error) {
        if (!error) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            NSString *errMessage = [error userInfo][@"error"];
            [AlertUtil showAlertControllerWithMessage:@""
                                                title:errMessage
                                               sender:self];
        }
    }];
}

@end
