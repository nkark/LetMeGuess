//
//  GameViewController.m
//  LetMeGuess
//
//  Created by Nitin Karki on 10/6/15.
//  Copyright © 2015 appPond. All rights reserved.
//

#import "GameViewController.h"
#import <Parse/Parse.h>
#import "AlertUtil.h"

@interface GameViewController ()

@property (strong, nonatomic) PFUser *currentUser;

@end

@implementation GameViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentUser = [PFUser currentUser];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.currentUser) {
        [self showLogin];
    }
}

#pragma mark - Login

- (void)showLogin {
    [self performSegueWithIdentifier:@"loginSegue" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *destination = segue.destinationViewController;
    destination.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
}

#pragma mark - IBActions

- (IBAction)accountPressed:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError *error){
        if(!error) {
            if (![PFUser currentUser]) {
                [self showLogin];
            }
        } else {
            NSString *errorString = [error userInfo][@"error"];
            [AlertUtil showAlertControllerWithMessage:@"" title:errorString sender:self];
        }
    }];
}

@end
