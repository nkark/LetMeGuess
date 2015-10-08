//
//  AccountViewController.m
//  LetMeGuess
//
//  Created by Nitin Karki on 10/7/15.
//  Copyright © 2015 appPond. All rights reserved.
//

#import "AccountViewController.h"

@interface AccountViewController ()

@end

@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupProfilePicView];
}

#pragma mark - Utility

- (void)setupProfilePicView {
    self.profilePicImageView.layer.cornerRadius = 50;
    self.profilePicImageView.layer.masksToBounds = YES;
    self.profilePicImageView.layer.borderWidth = 1.75;
    self.profilePicImageView.layer.borderColor = [[UIColor grayColor] CGColor];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)donePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
