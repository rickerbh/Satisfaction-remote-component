//
//  DCComposeCommentViewController.h
//  satsat
//
//  Created by David on 2/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SatisfactionRemoteComponentConstants.h"
#import "DCTopicViewController.h"

@interface DCComposeCommentViewController : UIViewController <UITextViewDelegate, UIActionSheetDelegate> {
	IBOutlet UITextView *bodyTextView;
	IBOutlet UIView *uploadingView;

	int topicId;
	int replyId;
	DCTopicViewController *underneathTopicViewController;

	OADataFetcher *fetcher;
}

@property (nonatomic) int topicId;
@property (nonatomic) int replyId;
@property (nonatomic, retain) DCTopicViewController *underneathTopicViewController;

- (IBAction)post;
- (IBAction)cancel;
- (void)checkInputAndPost;
- (void)cancelAfterAlert;

@end
