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
#import "NumbersService.h"
#include <stdlib.h>
#import "DKCircleButton.h"

@interface GameViewController ()

@property (strong, nonatomic) NSString *currentFact;
@property int currentNumber;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) DKCircleButton *startButton;

@end

@implementation GameViewController

int newFactAttempts;

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupGameScreen];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (!self.inputTextField.isFirstResponder) {
        [self.inputTextField becomeFirstResponder];
    }
    
    //self.currentNumber = arc4random_uniform(51);
    self.currentNumber = 3;
    NSLog(@"currentNumber: %d", self.currentNumber);
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

#pragma mark - Utility 

- (void)setHintViewText:(NSString *)fact {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:.25 delay:0
                            options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                                self.hintTextView.alpha = 0;
                            }
                         completion:^(BOOL finished){
                             if (finished) {
                                 [UIView animateWithDuration:.5 delay:0
                                                     options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                                                         self.hintTextView.text = fact;
                                                         self.hintTextView.alpha = 1;
                                                     }
                                                  completion:nil];
                             }
                         }];
    });
}

- (void)showSpinner {
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.frame = CGRectMake(0, 0, 24, 24);
    self.spinner.center = self.view.center;
    [self.view addSubview:self.spinner];
    [self.spinner startAnimating];
}

- (void)hideSpinner {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.spinner stopAnimating];
    });
}

- (void)setupGameScreen {
    self.nextHintButton.layer.cornerRadius = 10;
    self.hintView.layer.cornerRadius = 10;
    self.timerView.layer.cornerRadius = 10;
    [self.timerLabel setCountDownTime:120];
    self.timerLabel.textColor = [UIColor brownColor];
    self.timerLabel.timeFormat = @"mm:ss";
    [self.timerLabel setTimerType:MZTimerLabelTypeTimer];
    
    self.startButton = [[DKCircleButton alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
    self.startButton.center = CGPointMake(self.view.center.x, self.startStopButton.center.y);
    [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
    [self.startButton setBackgroundColor:[UIColor colorWithRed:0 green:0.5 blue:0 alpha:1]];
    [self.startButton addTarget:self action:@selector(startStopPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.startButton];
    
}

- (void)startStopPressed {
    if ([self.startButton.titleLabel.text isEqualToString:@"Start"]) {
        [self.timerLabel startWithEndingBlock:^(NSTimeInterval countTime){
            [self handleTimerExpired];
        }];
        [self.startButton setTitle:@"Stop" forState:UIControlStateNormal];
        [self.startButton setBackgroundColor:[UIColor redColor]];
    } else {
        [self.timerLabel reset];
        [self.timerLabel pause];
        [self.timerLabel setCountDownTime:120];
        [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
        [self.startButton setBackgroundColor:[UIColor colorWithRed:0 green:0.5 blue:0 alpha:1]];
    }
}

- (void)handleTimerExpired {
    NSLog(@"timer expired!");
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

#pragma mark - Action Methods

- (IBAction)generateFactPressed:(id)sender {
    [self showSpinner];
    newFactAttempts = 1;
    [self getFact:self.currentNumber];
}

#pragma mark - Number Service

- (void)getFact:(int)number {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://numbersapi.com/%d", number]];

    NSURLSessionDataTask * dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            if (self.currentFact.length == 0) {
                self.currentFact = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                [self parseFact:self.currentFact];
            } else {
                NSString *newFact = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if ([self.currentFact isEqualToString:newFact]) {
                    NSLog(@"Same fact   attempts: %d", newFactAttempts);
                    if (newFactAttempts > 2) {
                        [self hideSpinner];
                        return;
                    } else {
                        [self getFact:number];
                        newFactAttempts++;
                    }
                } else {
                    [self parseFact:newFact];
                }
            }
        } else {
            NSLog(@"ERROR: %@", error.localizedDescription);
        }
        
    }];
    
    [dataTask resume];
}

- (void)parseFact:(NSString *)fact {
    NSString *prefix = @"is th";
    NSString *suffix = @".";
    NSRange subStringRange = NSMakeRange(prefix.length, fact.length - prefix.length - suffix.length);
    
    NSString *parsedFact = [fact substringWithRange:subStringRange];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showFact:parsedFact];
    });
}

- (void)showFact:(NSString *)fact {
    [self hideSpinner];
    [UIView animateWithDuration:.25 delay:0
                        options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                            self.hintTextView.alpha = 0;
                        }
                     completion:^(BOOL finished){
                         self.hintTextView.text = fact;
                             [UIView animateWithDuration:.5 delay:0
                                                 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                                                     self.hintTextView.alpha = 1;
                                                 }
                                              completion:nil];
                     }];
}

@end
