//
//  DCTopicsViewController.h
//  satsat
//
//  Created by David on 2/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SatisfactionRemoteComponentConstants.h"
#import "DCSearchableListViewController.h"
#import "GSTopicController.h"

@interface DCTopicsViewController : DCSearchableListViewController {
	UIImage *ideaImage;
	UIImage *questionImage;
	UIImage *problemImage;
	UIImage *praiseImage;
	UIImage *talkImage;
	UIImage *updateImage;
	UIImage *selectedIdeaImage;
	UIImage *selectedQuestionImage;
	UIImage *selectedProblemImage;
	UIImage *selectedPraiseImage;
	UIImage *selectedTalkImage;
	UIImage *selectedUpdateImage;
	NSString *companyKey;
	int productId;
	NSMutableArray *cachedFancyDatesCreated;
	NSMutableArray *cachedFancyDatesActivity;
}

@property (nonatomic, retain) NSString *companyKey;
@property (nonatomic) int productId;

@end
