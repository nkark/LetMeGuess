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

@interface GameViewController ()

@property (strong, nonatomic) NSString *currentFact;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
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
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.frame = CGRectMake(0, 0, 24, 24);
    self.spinner.center = self.view.center;
    [self.view addSubview:self.spinner];
    [self.spinner startAnimating];
    
    [self getFact:[NSNumber numberWithInt:2]];
}

#pragma mark - Number Service

- (void)getFact:(NSNumber *)number {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://numbersapi.com/%d", number.intValue]];

    NSURLSessionDataTask * dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSString *newFact;
            if (self.currentFact.length == 0) {
                self.currentFact = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                [self parseFact:self.currentFact];
            } else {
                newFact = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if ([self.currentFact isEqualToString:newFact]) {
                    [self getFact:number];
                } else {
                    [self parseFact:newFact];
                }
            }
        } else {
            NSLog(@"ERROR: %@", error.localizedDescription);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinner stopAnimating];
        });
    }];
    
    [dataTask resume];
}

- (void)parseFact:(NSString *)fact {
    NSString *prefix = @"is the";
    NSString *suffix = @".";
    NSRange subStringRange = NSMakeRange(prefix.length-1, fact.length - prefix.length - suffix.length);
    
    NSString *parsedFact = [fact substringWithRange:subStringRange];
    parsedFact = [parsedFact stringByAppendingString:@"."];
    NSString *firstCapChar = [[parsedFact substringToIndex:1] capitalizedString];
    parsedFact = [parsedFact stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:firstCapChar];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self showFact:parsedFact];
    });
}

- (void)showFact:(NSString *)fact {
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
