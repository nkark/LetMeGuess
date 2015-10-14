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
#import "AccountViewController.h"

@interface GameViewController ()

@end

@implementation GameViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.inputTextField.isFirstResponder) {
        [self.inputTextField becomeFirstResponder];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self becomeFirstResponder];
    
    if (![PFUser currentUser]) {
        [self showLogin];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.inputTextField.isFirstResponder) {
        [self.inputTextField becomeFirstResponder];
    }
}
#pragma mark - Login

- (void)showLogin {
    [self performSegueWithIdentifier:@"loginSegue" sender:self];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *destination = segue.destinationViewController;
    destination.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
}

@end
