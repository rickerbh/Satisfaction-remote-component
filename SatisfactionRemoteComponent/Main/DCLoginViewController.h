//
//  DCLoginViewController.h
//  satsat
//
//  Created by David on 2/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SatisfactionRemoteComponentConstants.h"
#import "OAuthConsumer.h"

@interface DCLoginViewController : UIViewController {
	NSDictionary *personDictionary;
	int personId;
	IBOutlet UIActivityIndicatorView *spinner;
	IBOutlet UIButton *button;
	IBOutlet UILabel *noteLabel;
	IBOutlet UIImageView *instructionsImageView;
	OAToken *requestToken;
	BOOL didReturnFromSafari;

	OADataFetcher *requestFetcher;
	OADataFetcher *accessFetcher;
	OADataFetcher *meDetailsFetcher;
}

@property (nonatomic, retain) NSDictionary *personDictionary;
@property (nonatomic) int personId;
@property (nonatomic) BOOL didReturnFromSafari;

- (IBAction)loginAction:(id)sender;
- (IBAction)cancelAction;
- (void)requestUnauthorizedRequestToken;
- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;
- (IBAction)loginAction:(id)sender;
- (void)accessTokenTicket;
- (void)accessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void)accessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;
- (void)downloadMeDetails;
- (void)meDetailsTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void)meDetailsTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;

@end
