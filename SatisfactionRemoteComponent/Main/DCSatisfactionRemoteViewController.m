//
//  DCSatisfactionRemoteViewController.m
//  ModalTest
//
//  Created by David on 2/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DCSatisfactionRemoteViewController.h"
#import "DCComposeViewController.h"
#import "DCLoginViewController.h"
#import "DCOAuthParams.h"

@implementation DCSatisfactionRemoteViewController

@synthesize theNavigationController;
@synthesize companyKey;
@synthesize companyName;
@synthesize productId;
@synthesize productName;
@synthesize didReturnFromSafari;

- (id)initWithGetSatisfactionOAuthKey:(NSString *)OAuthKey getSatisfactionOAuthSecret:(NSString *)OAuthSecret companyKey:(NSString *)theCompanyKey {
	if (self = [super initWithNibName:@"DCSatisfactionRemoteView" bundle:nil]) {
		[[DCOAuthParams sharedParams] setKey:OAuthKey];
		[[DCOAuthParams sharedParams] setSecret:OAuthSecret];
		self.companyKey = theCompanyKey;
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	theNavigationController.view.frame = self.view.bounds;
	[self.view addSubview:[theNavigationController view]];

	// configure the topics view controller
	topicsViewController.companyKey = self.companyKey;
	topicsViewController.companyName = self.companyName;
	topicsViewController.productId = self.productId; // optional

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountLoginAction) name:@"SRC_ACCOUNT_LOGIN_ACTION" object:nil];

	lastStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
}

- (IBAction)composeAction {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"SRC_ME_ACCOUNT"] == nil) {
		// user is not logged in
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"SRC_ACCOUNT_LOGIN_ACTION" object:nil]];
	} else {
		// user is logged in
		DCComposeViewController *composeViewController = [[DCComposeViewController alloc] initWithNibName:@"DCComposeView" bundle:nil];
		composeViewController.companyKey = self.companyKey;
		composeViewController.productName = self.productName;
		composeViewController.underneathNavigationController = theNavigationController;
		UINavigationController *modalNavigationController = [[UINavigationController alloc] initWithRootViewController:composeViewController];
		[modalNavigationController setNavigationBarHidden:YES animated:NO];
		[theNavigationController presentModalViewController:modalNavigationController animated:YES];
		[modalNavigationController release];
		[composeViewController release];
	}
}

- (IBAction)accountLoginAction {
	DCLoginViewController *loginViewController = [[DCLoginViewController alloc] initWithNibName:@"DCLoginView" bundle:nil];
	[theNavigationController presentModalViewController:loginViewController animated:YES];
	[loginViewController release];
}

- (IBAction)doneAction {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
	if ([UIApplication sharedApplication].statusBarStyle != UIStatusBarStyleBlackOpaque) {
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:animated];
	}

	// TODO: figure out why the status bar doesn't return to black in viewWillAppear: after signing in and return in from Mobile Safari.  This is a workaround, but it's ugly.
	checkStatusBarStyleTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(checkStatusBarStyle) userInfo:nil repeats:NO];
}

- (void)viewDidAppear:(BOOL)animated {
	if (didReturnFromSafari == YES) {
		// TODO: figure out why we get a crash if we call launchLogin right away on iPhone OS 3.0
		[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(launchLogin) userInfo:nil repeats:NO];
	} else {
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"OAUTH_GetSatisfaction_requestToken_KEY"];
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"OAUTH_GetSatisfaction_requestToken_SECRET"];
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"SRC_ME_ACCOUNT"] objectForKey:@"id"] == nil) {
			// clear any old access token that might exist
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"OAUTH_GetSatisfaction_requestToken_KEY"];
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"OAUTH_GetSatisfaction_requestToken_SECRET"];
		}
		[[NSUserDefaults standardUserDefaults]synchronize];
	}
}

- (void)launchLogin {
	if (didReturnFromSafari == YES) {
		DCLoginViewController *loginViewController = [[DCLoginViewController alloc] initWithNibName:@"DCLoginView" bundle:nil];
		loginViewController.didReturnFromSafari = YES;
		[self presentModalViewController:loginViewController animated:YES];
		[loginViewController release];
		didReturnFromSafari = NO;
	}
}

- (void)checkStatusBarStyle {
	checkStatusBarStyleTimer = nil;
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	[viewController viewWillAppear:animated];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	[viewController viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	if ([checkStatusBarStyleTimer isValid]) {
		[checkStatusBarStyleTimer invalidate];
	}
	[[UIApplication sharedApplication] setStatusBarStyle:lastStatusBarStyle animated:YES];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[theNavigationController release];
	[topicsViewController release];
	[companyKey release];
	[companyName release];
	[productName release];
    [super dealloc];
}

@end
