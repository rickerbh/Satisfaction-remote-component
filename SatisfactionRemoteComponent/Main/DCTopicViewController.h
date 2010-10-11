//
//  DCTopicViewController.h
//  satsat
//
//  Created by David on 2/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SatisfactionRemoteComponentConstants.h"
#import "OAuthConsumer.h"

@interface DCTopicViewController : UIViewController <UIActionSheetDelegate> {
	IBOutlet UIWebView *webView;
	NSDictionary *topicDictionary;
	NSURL *lastURL;
}

@property (nonatomic, retain) NSDictionary *topicDictionary;

- (IBAction)action;
- (void)composeAction;

- (void)postTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void)postTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;

@end
