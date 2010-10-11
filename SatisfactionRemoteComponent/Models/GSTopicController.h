//
//  GSTopicController.h
//  satsat
//
//  Created by David on 2/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSModelController.h"

@interface GSTopicController : GSModelController {
	NSString *companyKey;
	int productId;
	int createdByPersonId;
	int followedByPersonId;
}

@property (nonatomic, retain) NSString *companyKey;
@property (nonatomic) int productId;
@property (nonatomic) int createdByPersonId;
@property (nonatomic) int followedByPersonId;

@end
