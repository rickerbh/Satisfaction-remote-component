//
//  GSReplyController.m
//  satsat
//
//  Created by David on 2/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GSReplyController.h"

@implementation GSReplyController

@synthesize topicId;

- (NSString *)URLString {
	if (self.topicId > 0) {
		return [NSString stringWithFormat:@"html://api.getsatisfaction.com/topics/%d/replies.json", self.topicId];
	}
	return @"";
}

@end
