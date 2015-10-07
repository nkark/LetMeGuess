//
//  AlertUtil.h
//  LetMeGuess
//
//  Created by Nitin Karki on 10/6/15.
//  Copyright © 2015 appPond. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AlertUtil : NSObject



+ (void)showAlertControllerWithMessage:(NSString *)message title:(NSString *)title sender:(UIViewController *)senderVC;

@end
