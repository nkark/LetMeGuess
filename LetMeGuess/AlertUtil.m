//
//  AlertUtil.m
//  LetMeGuess
//
//  Created by Nitin Karki on 10/6/15.
//  Copyright © 2015 appPond. All rights reserved.
//

#import "AlertUtil.h"
#import "Constants.h"

static BOOL isShowing;
static UIAlertController *mostRecentAlert;

@implementation AlertUtil

+ (void)showAlertControllerWithMessage:(NSString *)message title:(NSString *)title sender:(UIViewController *)senderVC {
    NSDictionary *titleAttrs = @{ NSForegroundColorAttributeName : ALERT_TITLE_COLOR };
    NSDictionary *messageAttrs = @{ NSForegroundColorAttributeName : ALERT_MESSAGE_COLOR };
    NSMutableAttributedString *alertTitle = [[NSMutableAttributedString alloc] initWithString:title attributes:titleAttrs];
    NSMutableAttributedString *alertMessage = [[NSMutableAttributedString alloc] initWithString:message attributes:messageAttrs];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    [alert setValue:alertTitle forKey:@"attributedTitle"];
    [alert setValue:alertMessage forKey:@"attributedMessage"];
    
    if (isShowing) {
        [AlertUtil dismissAlertController:mostRecentAlert completionHandler:^{
            [senderVC presentViewController:alert animated:YES completion:nil];
            [self performSelector:@selector(dismissAlertController:completionHandler:) withObject:alert afterDelay:2.5];
        }];
    } else {
        [senderVC presentViewController:alert animated:YES completion:nil];
        [self performSelector:@selector(dismissAlertController:completionHandler:) withObject:alert afterDelay:2.5];
    }
    
    isShowing = YES;
    mostRecentAlert = alert;
}

+ (void)dismissAlertController:(UIAlertController *)alertController completionHandler:(void (^)(void))handler {
    [alertController dismissViewControllerAnimated:YES completion:handler];
    isShowing = NO;
}

@end
