//
//  GameViewController.m
//  LetMeGuess
//
//  Created by Nitin Karki on 10/6/15.
//  Copyright © 2015 appPond. All rights reserved.
//

#import "GameViewController.h"
#import <Parse/Parse.h>
#import "AccountViewController.h"
#import "NumbersService.h"
#include <stdlib.h>
#import "DKCircleButton.h"
#import "RKDropdownAlert.h"
#import "MyConstants.h"

@interface GameViewController ()

@property (strong, nonatomic) NSString *currentFact;
@property int currentNumber;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) DKCircleButton *startButton;
@property (assign, nonatomic) BOOL isPLaying;

@end

@implementation GameViewController

int newFactAttempts;
UIButton *goButton;
NSString *defaultHelpText;

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupGameScreen];
    [self updateScore];
    
    defaultHelpText = self.hintTextView.text;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.currentNumber = arc4random_uniform(21);
    NSLog(@"currentNumber: %d", self.currentNumber);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    if (self.inputTextField.isFirstResponder) {
        [self.inputTextField resignFirstResponder];
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
    [self.nextHintButton setTitleColor:[UIColor brownColor] forState:UIControlStateHighlighted];
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
        [self generateFactPressed:nil];
        self.isPLaying = YES;
        self.currentScore = 0;
        [self.timerLabel startWithEndingBlock:^(NSTimeInterval countTime){
            [self handleTimerExpired];
        }];
        [self.startButton setTitle:@"Stop" forState:UIControlStateNormal];
        [self.startButton setBackgroundColor:[UIColor redColor]];
    } else {
        self.isPLaying = NO;
        self.hintTextView.text = defaultHelpText;
        [self.timerLabel reset];
        [self.timerLabel pause];
        [self.timerLabel setCountDownTime:120];
        [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
        [self.startButton setBackgroundColor:[UIColor colorWithRed:0 green:0.5 blue:0 alpha:1]];
    }
}

- (void)handleTimerExpired {
    [RKDropdownAlert title:@"TIMES UP!" backgroundColor:ALERT_ERROR_COLOR textColor:[UIColor whiteColor]];
}

- (void)keyboardWillShow {
    [self addGoButton];
}

- (void)keyboardWillHide {
    [goButton removeFromSuperview];
}

- (void)goButtonPressed {
    if (self.isPLaying) {
        NSString *correctAnswer = [NSString stringWithFormat:@"%d", self.currentNumber];
        if ([self.inputTextField.text isEqualToString:correctAnswer]) {
            self.currentScore += 20;
            [RKDropdownAlert title:@"CORRECT" backgroundColor:ALERT_SUCCESS_COLOR textColor:[UIColor whiteColor]];
        } else {
            self.currentScore -= 10;
            [RKDropdownAlert title:@"WRONG" backgroundColor:ALERT_ERROR_COLOR textColor:[UIColor whiteColor]];
        }
    } else {
        [RKDropdownAlert title:@"Start the timer to begin playing!"];
    }
    
    [self updateScore];
}

- (void)updateScore {
    if (self.currentScore == 0) {
        self.currentScoreLabel.text = @"Current Score:  0";
        
        return;
    }
    
    if (self.currentScore > 0) {
        [self.currentScoreLabel setAttributedText:[self updateScoreLabel:[NSString stringWithFormat:@"Current Score:  %d", self.currentScore] color:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]]];
    } else if (self.currentScore < 0) {
        [self.currentScoreLabel setAttributedText:[self updateScoreLabel:[NSString stringWithFormat:@"Current Score:  %d", self.currentScore] color:[UIColor redColor]]];
    }
}

- (void)addGoButton {
    goButton = [UIButton buttonWithType:UIButtonTypeCustom];
    goButton.adjustsImageWhenHighlighted = NO;
    goButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:.5 alpha:1];
    [goButton setTitle:@"GO!" forState:UIControlStateNormal];
    [goButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [goButton setTitleColor:[UIColor colorWithRed:0 green:0 blue:.5 alpha:1] forState:UIControlStateHighlighted];
    [goButton addTarget:self action:@selector(goButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *keyboardView = [[[[[UIApplication sharedApplication] windows] lastObject] subviews] firstObject];
    [goButton setFrame:CGRectMake(0, keyboardView.frame.size.height - 53, 123, 53)];
    [keyboardView addSubview:goButton];
}

- (NSMutableAttributedString *)updateScoreLabel:(NSString *)labelText color:(UIColor *)color {
    NSMutableAttributedString *attributedTextForLabel = [[NSMutableAttributedString alloc] initWithString:labelText];
    NSRange start = NSMakeRange(14, 1);
    NSRange end = NSMakeRange(attributedTextForLabel.length, 1);
    NSRange location = NSMakeRange(start.location, end.location- start.location);
    [attributedTextForLabel addAttribute:NSForegroundColorAttributeName value:color range:location];
    [attributedTextForLabel addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:self.currentScoreLabel.font.pointSize] range:location];

    
    return attributedTextForLabel;
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
                        dispatch_async(dispatch_get_main_queue(), ^{
                           [RKDropdownAlert title:@"There are no new hints"];
                        });
                        [self hideSpinner];
                        return;
                    } else {
                        newFactAttempts++;
                        [self getFact:number];
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
