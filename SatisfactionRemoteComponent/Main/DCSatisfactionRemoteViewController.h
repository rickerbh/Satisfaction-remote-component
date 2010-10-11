//
//  DCSatisfactionRemoteViewController.h
//  ModalTest
//
//  Created by David on 2/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SatisfactionRemoteComponentConstants.h"
#import "DCTopicsViewController.h"

#define kGO_TO_SAFARI_NOTIFICATION_NAME @"goToSafari"

@interface DCSatisfactionRemoteViewController : UIViewController <UINavigationControllerDelegate> {
	IBOutlet UINavigationController *theNavigationController;

	UIStatusBarStyle lastStatusBarStyle;
	IBOutlet DCTopicsViewController *topicsViewController;
	NSString *companyKey;
	int productId;
	NSString *companyName;
	NSString *productName;
	BOOL didReturnFromSafari;

	NSTimer *checkStatusBarStyleTimer;
}

@property (nonatomic, retain) IBOutlet UINavigationController *theNavigationController;
@property (nonatomic, retain) NSString *companyKey;
@property (nonatomic) int productId;
@property (nonatomic, retain) NSString *companyName;
@property (nonatomic, retain) NSString *productName; // Must be exact for posting correctly
@property (nonatomic) BOOL didReturnFromSafari;

- (id)initWithGetSatisfactionOAuthKey:(NSString *)OAuthKey getSatisfactionOAuthSecret:(NSString *)OAuthSecret companyKey:(NSString *)theCompanyKey;
- (IBAction)doneAction;
- (IBAction)composeAction;
- (IBAction)accountLoginAction;
- (void)checkStatusBarStyle;

@end
