//
//  DCFancyDate.h
//  satsat
//
//  Created by David on 2/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCFancyDate : NSObject {

}

+ (NSDate *)dateFromString:(NSString *)string;
+ (NSString *)relativeTextWithDate:(NSDate *)date longVersion:(BOOL)longVersion;

@end
