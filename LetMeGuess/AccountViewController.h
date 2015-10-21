//
//  AccountViewController.h
//  LetMeGuess
//
//  Created by Nitin Karki on 10/7/15.
//  Copyright © 2015 appPond. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "CameraSessionView.h"

@interface AccountViewController : UIViewController <CACameraSessionDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profilePicImageView;

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *editPasswordButton;
@property (weak, nonatomic) IBOutlet UIButton *editUsernameButton;

@property (nonatomic, strong) CameraSessionView *cameraView;


@end
