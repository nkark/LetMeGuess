//
//  GameViewController.h
//  LetMeGuess
//
//  Created by Nitin Karki on 10/6/15.
//  Copyright © 2015 appPond. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property (weak, nonatomic) IBOutlet UIView *hintView;
@property (weak, nonatomic) IBOutlet UITextView *hintTextView;
@property (weak, nonatomic) IBOutlet UIButton *startStopButton;
@property (weak, nonatomic) IBOutlet UIButton *nextHintButton;

@end
