//
//  NumbersService.m
//  LetMeGuess
//
//  Created by Nitin Karki on 10/14/15.
//  Copyright © 2015 appPond. All rights reserved.
//

#import "NumbersService.h"

@implementation NumbersService

+ (void)getFact:(NSNumber *)number
       success: (void(^)(NSString *fact))success
       failure: (void(^)(NSError* error))failure {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://numbersapi.com/%d", number.intValue]];
    NSLog(@"URL: %@\n\n", url);
    NSURLSession * session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask * dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSString *fact = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            success([NumbersService parseFact:fact]);
        } else {
            failure(error);
        }
    }];
    
    [dataTask resume];
}

+ (NSString *)parseFact:(NSString *)fact {
    
    
    
    return @"";
}

@end
