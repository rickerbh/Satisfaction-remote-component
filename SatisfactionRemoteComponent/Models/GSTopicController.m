//
//  GSTopicController.m
//  satsat
//
//  Created by David on 2/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GSTopicController.h"

@implementation GSTopicController

@synthesize companyKey;
@synthesize productId;
@synthesize createdByPersonId;
@synthesize followedByPersonId;

- (NSString *)URLString {
	if (self.createdByPersonId > 0) {
		return [NSString stringWithFormat:@"http://api.getsatisfaction.com/people/%d/topics.json?sort=recently_active::paging::", self.createdByPersonId];
	} else if (self.followedByPersonId > 0) {
		return [NSString stringWithFormat:@"http://api.getsatisfaction.com/people/%d/followed/topics.json?sort=recently_active::paging::", self.followedByPersonId];
	} else if (self.productId > 0) {
		return [NSString stringWithFormat:@"http://api.getsatisfaction.com/products/%d/topics.json?sort=recently_active::paging::", self.productId];
	} else if ([self.companyKey isEqualToString:@""] == NO && self.companyKey != nil) {
		return [NSString stringWithFormat:@"http://api.getsatisfaction.com/companies/%@/topics.json?sort=recently_active::paging::", self.companyKey];
	}
	return nil;
}

- (NSString *)URLStringWithQuery:(NSString *)q {
	NSString *string = @"";
	if (self.createdByPersonId > 0) {
		string = [NSString stringWithFormat:@"http://api.getsatisfaction.com/people/%d/topics.json?sort=recently_active::paging::", self.createdByPersonId];
	} else if (self.followedByPersonId > 0) {
		string = [NSString stringWithFormat:@"http://api.getsatisfaction.com/people/%d/followed/topics.json?sort=recently_active::paging::", self.followedByPersonId];
	/* DISABLED because the Get Satisfaction API doesn't support topic search by product
	} else if (self.productId > 0) {
		string = [NSString stringWithFormat:@"http://api.getsatisfaction.com/products/%d/topics.json?sort=recently_active::paging::", self.productId];
	*/
	} else if ([self.companyKey isEqualToString:@""] == NO && self.companyKey != nil) {
		string = [NSString stringWithFormat:@"http://api.getsatisfaction.com/companies/%@/topics.json?sort=recently_active::paging::", self.companyKey];
	}
	if ([string isEqualToString:@""] == NO) {
		return [NSString stringWithFormat:@"%@&q=%@", string, q];
	}
	return nil;
}

- (void)dealloc {
	[super dealloc];
}

@end
