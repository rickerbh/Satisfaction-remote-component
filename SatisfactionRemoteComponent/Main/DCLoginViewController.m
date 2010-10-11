//
//  DCLoginViewController.m
//  satsat
//
//  Created by David on 2/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DCLoginViewController.h"
#import "GSModelController.h"
#import "DCOAuthParams.h"
#import "DCSatisfactionRemoteViewController.h"

@implementation DCLoginViewController

@synthesize personDictionary;
@synthesize personId;
@synthesize didReturnFromSafari;

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if ([self.personDictionary objectForKey:@"id"] != [[[NSUserDefaults standardUserDefaults] objectForKey:@"SRC_ME_ACCOUNT"] objectForKey:@"id"]) {
		// the personDictionary isn't set to be the 
		self.personDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"SRC_ME_ACCOUNT"];
	}
}

- (IBAction)cancelAction {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];

	noteLabel.font = [UIFont systemFontOfSize:13];
	noteLabel.text = @"After signing in, you\nwill automatically return here.";

	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"SRC_ME_ACCOUNT"] objectForKey:@"id"] == nil) {
		// user is not logged in
		self.navigationItem.title = @"";



		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"OAUTH_GetSatisfaction_requestToken_KEY"] != nil) {
			// we have the unauthorized request token, so get the access token
			if (didReturnFromSafari == YES) {
				didReturnFromSafari = NO;
				[self accessTokenTicket];
			} else {
				button.hidden = NO;
				noteLabel.hidden = NO;
				instructionsImageView.hidden = NO;
			}
		} else {
			// clear any old access token that might exist
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"OAUTH_GetSatisfaction_requestToken_KEY"];
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"OAUTH_GetSatisfaction_requestToken_SECRET"];
			// we don't have the request token yet, so do that
			[self requestUnauthorizedRequestToken];
		}
	} else {
		// logged in already
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	[personDictionary release];
	[spinner release];
	[button release];
	[noteLabel release];
	[instructionsImageView release];
	[requestToken release];
    [super dealloc];
}


#pragma mark Login Methods

- (void)requestUnauthorizedRequestToken {
	[spinner startAnimating];
	button.hidden = YES;
	noteLabel.hidden = YES;
	instructionsImageView.hidden = YES;
	OAConsumer *consumer = [[OAConsumer alloc] initWithKey:[[DCOAuthParams sharedParams] key] secret:[[DCOAuthParams sharedParams] secret]];
	NSURL *url = [NSURL URLWithString:GET_SATISFACTION_OAUTH_REQUEST_TOKEN_URL];
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
		consumer:consumer
		token:nil // we don't have a Token yet
		realm:nil // our service provider doesn't specify a realm
		signatureProvider:nil]; // use the default method, HMAC-SHA1
	[request setHTTPMethod:@"POST"];

	
	
	requestFetcher = [[OADataFetcher alloc]init];
	[requestFetcher fetchDataWithRequest:request 
							   delegate:self 
					  didFinishSelector:@selector(requestTokenTicket:didFinishWithData:) 
						didFailSelector:@selector(requestTokenTicket:didFailWithError:)];

	[consumer release];
	[request release];
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	[requestFetcher release];
	requestFetcher = nil;
	if (ticket.didSucceed) {
		NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		requestToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
		[responseBody release];
		[requestToken storeInUserDefaultsWithServiceProviderName:@"GetSatisfaction" prefix:@"requestToken"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		button.hidden = NO;
		noteLabel.hidden = NO;
		instructionsImageView.hidden = NO;
	}
	[spinner stopAnimating];
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
	NSLog(@"Error getting OAuth request token.");
	[requestFetcher release];
	requestFetcher = nil;
}

- (IBAction)loginAction:(id)sender {
	// send the user to Mobile Safari
	[[NSUserDefaults standardUserDefaults] synchronize];
	NSString* s = [[NSUserDefaults standardUserDefaults] objectForKey:@"OAUTH_GetSatisfaction_requestToken_KEY"] ;

	
	[[NSNotificationCenter defaultCenter] postNotificationName:kGO_TO_SAFARI_NOTIFICATION_NAME
														object:nil];
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"OAUTH_GetSatisfaction_requestToken_KEY"] != nil) {
		NSURL *url = [NSURL URLWithString:[GET_SATISFACTION_OAUTH_AUTHORIZE_URL stringByReplacingOccurrencesOfString:@"::token::" withString:[[NSUserDefaults standardUserDefaults] objectForKey:@"OAUTH_GetSatisfaction_requestToken_KEY"]]];
		[[UIApplication sharedApplication] openURL:url];
	}
}

- (void)accessTokenTicket {
	OAConsumer *consumer = [[OAConsumer alloc] initWithKey:[[DCOAuthParams sharedParams] key] secret:[[DCOAuthParams sharedParams] secret]];
	NSURL *url = [NSURL URLWithString:GET_SATISFACTION_OAUTH_ACCESS_TOKEN_URL];
	OAToken *token = [[OAToken alloc] initWithUserDefaultsUsingServiceProviderName:@"GetSatisfaction" prefix:@"requestToken"];
	if (token != nil) {
		[spinner startAnimating];
		button.hidden = YES;
		noteLabel.hidden = YES;
		instructionsImageView.hidden = YES;
		OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
			consumer:consumer
			token:token
			realm:nil // our service provider doesn't specify a realm
			signatureProvider:nil]; // use the default method, HMAC-SHA1
		[request setHTTPMethod:@"POST"];

		
		
		accessFetcher = [[OADataFetcher alloc]init];
		[accessFetcher fetchDataWithRequest:request 
									  delegate:self 
							 didFinishSelector:@selector(accessTokenTicket:didFinishWithData:) 
							   didFailSelector:@selector(accessTokenTicket:didFailWithError:)];
		
		[request release];
	} else {
		NSLog(@"Error getting token from user defaults.");
	}
	[token release];
	[consumer release];
}

- (void)accessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	[accessFetcher release];
	accessFetcher = nil;
	if (ticket.didSucceed) {
		NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		OAToken *accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];

		// delete the request token because we don't need it anymore
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"OAUTH_GetSatisfaction_requestToken_KEY"];
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"OAUTH_GetSatisfaction_requestToken_SECRET"];

		// save the access token
		[accessToken storeInUserDefaultsWithServiceProviderName:@"GetSatisfaction" prefix:@"accessToken"];
		[self downloadMeDetails];

		[responseBody release];
		[accessToken release];
	}
}

- (void)accessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
	NSLog(@"Error getting OAuth access token.");
	[accessFetcher release];
	accessFetcher = nil;
}

- (void)downloadMeDetails {
	// we have login success, now grab the user's details
	OAConsumer *consumer = [[OAConsumer alloc] initWithKey:[[DCOAuthParams sharedParams] key] secret:[[DCOAuthParams sharedParams] secret]];
	NSURL *url = [NSURL URLWithString:@"http://api.getsatisfaction.com/me"];
	OAToken *token = [[OAToken alloc] initWithUserDefaultsUsingServiceProviderName:@"GetSatisfaction" prefix:@"accessToken"];
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
		consumer:consumer
		token:token
		realm:nil
		signatureProvider:[[[OAPlaintextSignatureProvider alloc] init] autorelease]];
	[request setValue:@"text/x-json" forHTTPHeaderField:@"Accept"];

	
	meDetailsFetcher = [[OADataFetcher alloc]init];
	[meDetailsFetcher fetchDataWithRequest:request 
						 delegate:self 
				didFinishSelector:@selector(meDetailsTicket:didFinishWithData:) 
				  didFailSelector:@selector(meDetailsTicket:didFailWithError:)];
	
	[token release];
	[consumer release];
	[request release];
}

- (void)meDetailsTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	if (ticket.didSucceed) {
		NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:[GSModelController dictionaryFromJSON:string]];
		for (id key in [dictionary allKeys]) {
			if ([dictionary objectForKey:key] == [NSNull null]) { // we can't store nulls in NSUserDefaults
				[dictionary setObject:@"" forKey:key];
			}
		}
		[[NSUserDefaults standardUserDefaults] setObject:dictionary forKey:@"SRC_ME_ACCOUNT"];
		[string release];
		[dictionary release];
		[spinner stopAnimating];

		[self dismissModalViewControllerAnimated:YES];
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"SRC_ACCOUNT_LOGIN_TEXT_REFRESH" object:nil]];
	}
	[meDetailsFetcher release];
	meDetailsFetcher = nil;
}

- (void)meDetailsTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
	NSLog(@"Error getting me details.");
	[meDetailsFetcher release];
	meDetailsFetcher = nil;
}

@end
