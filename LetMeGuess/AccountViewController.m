//
//  AccountViewController.m
//  LetMeGuess
//
//  Created by Nitin Karki on 10/7/15.
//  Copyright © 2015 appPond. All rights reserved.
//

#import "AccountViewController.h"
#import "RKDropdownAlert.h"
#import "MyConstants.h"
#import "CameraSessionView.h"

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - Utility

- (void)setupAccountScreen {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    [self setupProfilePicView];
    self.usernameTextField.text = [PFUser currentUser].username;
}

- (void)dismissKeyboard {
    [self.usernameTextField resignFirstResponder];
}

- (void)setupProfilePicView {
    UITapGestureRecognizer *pictureTap = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(profilePictureTapped)];
    [self.profilePicImageView addGestureRecognizer:pictureTap];
    
    self.profilePicImageView.layer.cornerRadius = 50;
    self.profilePicImageView.layer.masksToBounds = YES;
    self.profilePicImageView.layer.borderWidth = 1.75;
    self.profilePicImageView.layer.borderColor = [[UIColor grayColor] CGColor];
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
            [RKDropdownAlert title:@"Error" message:errMssg backgroundColor:ALERT_ERROR_COLOR textColor:[UIColor whiteColor]];
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

- (void)profilePictureTapped {
    [self showCamera];
}

- (void)showCamera {
    CGRect frame = self.view.frame;
    frame.origin.y = [UIApplication sharedApplication].statusBarFrame.size.height;
    self.cameraView = [[CameraSessionView alloc] initWithFrame:frame];
    self.cameraView.delegate = self;
    [self.cameraView setTopBarColor:[UIColor brownColor]];
    self.cameraView.alpha = 0;
    [self.view addSubview:self.cameraView];
    
    [UIView animateWithDuration:.35 delay:0
                        options:UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                         self.cameraView.alpha = 1;
                     }
                     completion:nil];
}

#pragma mark - Camera Delegate

-(void)didCaptureImage:(UIImage *)image {
    UIImageView *imagePreview = [[UIImageView alloc] initWithImage:image];
    imagePreview.frame = CGRectMake(0, 0, self.view.frame.size.width - 50, self.view.frame.size.height/2.2);
    imagePreview.center = self.view.center;
    CGRect frame = imagePreview.frame;
    frame.origin.y -= 50;
    imagePreview.frame = frame;
    imagePreview.contentMode = UIViewContentModeScaleAspectFill;
    imagePreview.alpha = 0;
    [self.cameraView addSubview:imagePreview];
    
    [UIView animateWithDuration:.4 delay:0
                        options:UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                         imagePreview.alpha = 1;
                     }
                     completion:nil];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Update Profile Picture" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.profilePicImageView.image = image;
        [UIView animateWithDuration:.1 delay:0
                            options:UIViewAnimationOptionTransitionCrossDissolve
                         animations:^{
                             imagePreview.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 [imagePreview removeFromSuperview];
                                 [self.cameraView onTapDismissButton];
                             }
                         }];
    }];
    [alert addAction:yesAction];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"Take Another" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [UIView animateWithDuration:.1 delay:0
                            options:UIViewAnimationOptionTransitionCrossDissolve
                         animations:^{
                             imagePreview.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 [imagePreview removeFromSuperview];
                             }
                         }];
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:noAction];

    
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Actions

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
            [RKDropdownAlert title:@"Wait!" message:@"Username cannot be empty." backgroundColor:ALERT_ERROR_COLOR textColor:[UIColor whiteColor]];
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
            [RKDropdownAlert title:@"Error" message:errMessage backgroundColor:ALERT_ERROR_COLOR textColor:[UIColor whiteColor]];
        }
    }];
}

@end
