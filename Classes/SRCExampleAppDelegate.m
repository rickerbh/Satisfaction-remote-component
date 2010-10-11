//
//  SRCExampleAppDelegate.m
//  SRCExample
//
//  Created by David on 2/27/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "SRCExampleAppDelegate.h"
#import "RootViewController.h"
#import "DCSatisfactionRemoteViewController.h"

@implementation SRCExampleAppDelegate

@synthesize window;
@synthesize navigationController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	// Configure and show the window
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
	[[NSNotificationCenter defaultCenter]addObserver:self 
											selector:@selector(dismiss)
												name:kGO_TO_SAFARI_NOTIFICATION_NAME
											  object:nil];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}

-(void)dismiss{
	[[self navigationController] dismissModalViewControllerAnimated:YES];
}

- (IBAction)launchSatisfactionRemoteComponent:(id)sender {
	/*
	// Get Satisfaction OAuth Key & Secret
	//   * Register your app at http://getsatisfaction.com/me/extensions
	// 
	// companyKey
	//   * Find it in your GSFN URL: http://getsatisfaction.com/[companyKey]
	// 
	// companyName
	//   * Optional, but recommended.  (displayed in the search bar)
	// 
	// productId
	//   * Optional, used for browsing only one product.
	//   * Find it by going here and view source: http://api.getsatisfaction.com/companies/[companyKey]/products
	// 
	// productName
	//   * Optional, but must match the product name on GSFN exactly (for posting topics to a product).
	*/


	DCSatisfactionRemoteViewController *remoteViewController = [[DCSatisfactionRemoteViewController alloc] 
																initWithGetSatisfactionOAuthKey:@"3y3g8kddtwgi"
																getSatisfactionOAuthSecret:@"utmgoq6sqk9mhstnm6pwhxmki2c5abg9"
																companyKey:@"xmens"];
	remoteViewController.companyName = @"xmens";
	remoteViewController.productId = 60479;
	remoteViewController.productName = @"Template";
	if ([sender isKindOfClass:[NSURL class]]) {
		remoteViewController.didReturnFromSafari = YES;
		//((DCSatisfactionRemoteViewController*)[[TTNavigator navigator].rootViewController modalViewController]).didReturnFromSafari = YES ;
		//return;
	}
	// see if we just returned from logging in via Safari
	
	[[self navigationController] presentModalViewController:remoteViewController animated:YES];
	[remoteViewController release];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	[self launchSatisfactionRemoteComponent:url];
	return YES;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[navigationController release];
	[window release];
	[super dealloc];
}

@end
