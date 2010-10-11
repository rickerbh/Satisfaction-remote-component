//
//  DCFancyDate.m
//  satsat
//
//  Created by David on 2/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DCFancyDate.h"

@implementation DCFancyDate

+ (NSDate *)dateFromString:(NSString *)string {
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	[formatter setDateFormat:@"yyyy'/'MM'/'dd HH:mm:ss ZZ"];
	return [formatter dateFromString:string];
}

+ (NSString *)relativeTextWithDate:(NSDate *)date longVersion:(BOOL)longVersion {

	NSMutableString *dateString;

	if (date == nil || [date isEqualToDate:[NSDate distantPast]] || fabs([date timeIntervalSinceNow]) > 157680000 /* 5 years */) {
		return @"Never";
	}

	// get midnight date
	NSDateFormatter *dateFormatter_midnight = [[NSDateFormatter alloc] init];
	[dateFormatter_midnight setDateFormat:@"yyyy'-'MM'-'dd"];
	NSString *midnightString = [dateFormatter_midnight stringFromDate:date];
	NSString *todayString = [dateFormatter_midnight stringFromDate:[NSDate date]];
	NSString *yesterdayString = [dateFormatter_midnight stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-86400]];
	[dateFormatter_midnight release];

	if ([midnightString isEqualToString:todayString]) {
		// compare to today, set dateString
		if (longVersion == YES) {
			dateString = [NSMutableString stringWithString:@"Today"];
		} else {
			dateString = [NSMutableString stringWithString:@""];
			NSDateFormatter *dateFormatter_time = [[NSDateFormatter alloc] init];
			[dateFormatter_time setTimeStyle:NSDateFormatterShortStyle];
			[dateString appendString:[dateFormatter_time stringFromDate:date]];
			[dateFormatter_time release];
		}
	} else if ([midnightString isEqualToString:yesterdayString]) {
		// compare to yesterday, set dateString
		dateString = [NSMutableString stringWithString:@"Yesterday"];
	} else {
		// else, set dateString to Jan 18, 2008
		NSDateFormatter *dateFormatter_midnight = [[NSDateFormatter alloc] init];
		[dateFormatter_midnight setDateStyle:NSDateFormatterMediumStyle];
		dateString = [NSMutableString stringWithString:[dateFormatter_midnight stringFromDate:date]];
		[dateFormatter_midnight release];
	}

	if (longVersion == YES) {
		// add time
		[dateString appendString:@" at "];
		NSDateFormatter *dateFormatter_time = [[NSDateFormatter alloc] init];
		[dateFormatter_time setTimeStyle:NSDateFormatterShortStyle];
		[dateString appendString:[dateFormatter_time stringFromDate:date]];
		[dateFormatter_time release];
	}

	return (NSString *)dateString;
}

@end
