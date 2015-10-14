//
//  NumbersService.h
//  LetMeGuess
//
//  Created by Nitin Karki on 10/14/15.
//  Copyright © 2015 appPond. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NumbersService : NSObject

+ (void)getFact:(NSNumber *)number
        success: (void(^)(NSString *fact))success
        failure: (void(^)(NSError* error))failure;

@end
