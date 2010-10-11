//
//  DCTopicViewController.m
//  satsat
//
//  Created by David on 2/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DCTopicViewController.h"
#import "DCFancyDate.h"
#import "DCComposeReplyViewController.h"
#import "DCComposeCommentViewController.h"
#import "DCOAuthParams.h"

@implementation DCTopicViewController

@synthesize topicDictionary;

- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(action)];
}

- (void)viewWillAppear:(BOOL)animated {
	NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DC_topic" ofType:@"html"]];
	NSMutableString *html = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSString *imagePath = [NSString stringWithFormat:@"file://%@/", [[NSBundle mainBundle] bundlePath]];
	NSString *style = [topicDictionary objectForKey:@"style"];
	NSString *meTooCount = [[topicDictionary objectForKey:@"me_too_count"] stringValue];

	if ([style isEqualToString:@"idea"]) {
		if ([meTooCount isEqualToString:@"1"]) {
			meTooCount = [meTooCount stringByAppendingString:@" person likes this idea"];
		} else {
			meTooCount = [meTooCount stringByAppendingString:@" people like this idea"];
		}
	} else if ([style isEqualToString:@"question"]) {
		if ([meTooCount isEqualToString:@"1"]) {
			meTooCount = [meTooCount stringByAppendingString:@" person has this question"];
		} else {
			meTooCount = [meTooCount stringByAppendingString:@" people have this question"];
		}
	} else if ([style isEqualToString:@"problem"]) {
		if ([meTooCount isEqualToString:@"1"]) {
			meTooCount = [meTooCount stringByAppendingString:@" person has this problem"];
		} else {
			meTooCount = [meTooCount stringByAppendingString:@" people have this problem"];
		}
	} else {
		meTooCount = @"";
	}

	[html replaceOccurrencesOfString:@"::imagePath::" withString:imagePath options:NSLiteralSearch range:NSMakeRange(0, [html length])];
	[html replaceOccurrencesOfString:@"::subject::" withString:[topicDictionary objectForKey:@"subject"] options:NSLiteralSearch range:NSMakeRange(0, [html length])];
	[html replaceOccurrencesOfString:@"::username::" withString:[[topicDictionary objectForKey:@"author"] objectForKey:@"name"] options:NSLiteralSearch range:NSMakeRange(0, [html length])];
	[html replaceOccurrencesOfString:@"::personId::" withString:[[[topicDictionary objectForKey:@"author"] objectForKey:@"id"] stringValue] options:NSLiteralSearch range:NSMakeRange(0, [html length])];
	[html replaceOccurrencesOfString:@"::style::" withString:style options:NSLiteralSearch range:NSMakeRange(0, [html length])];
	[html replaceOccurrencesOfString:@"::meTooCount::" withString:meTooCount options:NSLiteralSearch range:NSMakeRange(0, [html length])];
	[html replaceOccurrencesOfString:@"::content::" withString:[topicDictionary objectForKey:@"content"] options:NSLiteralSearch range:NSMakeRange(0, [html length])];
	[html replaceOccurrencesOfString:@"::dateCreated::" withString:[DCFancyDate relativeTextWithDate:[DCFancyDate dateFromString:[topicDictionary objectForKey:@"created_at"]] longVersion:NO] options:NSLiteralSearch range:NSMakeRange(0, [html length])];
	[html replaceOccurrencesOfString:@"::topicId::" withString:[[topicDictionary objectForKey:@"id"] stringValue] options:NSLiteralSearch range:NSMakeRange(0, [html length])];

	[webView loadHTMLString:html baseURL:[NSURL URLWithString:@"file:///"]];
	[html release];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (IBAction)action {
	UIActionSheet *actionSheet;
	actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Reply", @"Email Link", @"Open in Safari", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		// Reply Button Touched
		[self composeAction];
	} else if (buttonIndex == 1) {
		// Email Link Button Touched
		NSString *subject = [[[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count] - 2] navigationItem] title];
		NSString *stringURL = [NSString stringWithFormat:@"mailto:?subject=%@&body=%@\n\n%@\n\n", subject, [topicDictionary objectForKey:@"subject"], [topicDictionary objectForKey:@"at_sfn"]];
		stringURL = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)stringURL, NULL, NULL, kCFStringEncodingUTF8);
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringURL]];
	} else if (buttonIndex == 2) {
		// Open in Safari Button Touched
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[topicDictionary objectForKey:@"at_sfn"]]];
	}
}

- (void)composeAction {
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"SRC_ME_ACCOUNT"] objectForKey:@"id"] == nil) {
		// user is not logged in
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"SRC_ACCOUNT_LOGIN_ACTION" object:nil]];
	} else {
		// user is logged in
		DCComposeReplyViewController *composeViewController = [[DCComposeReplyViewController alloc] initWithNibName:@"DCComposeReplyView" bundle:nil];
		composeViewController.topicId = [[topicDictionary objectForKey:@"id"] intValue];
		composeViewController.underneathTopicViewController = self;
		UINavigationController *modalNavigationController = [[UINavigationController alloc] initWithRootViewController:composeViewController];
		[modalNavigationController setNavigationBarHidden:YES animated:NO];
		[[self navigationController] presentModalViewController:modalNavigationController animated:YES];
		[composeViewController release];
		[modalNavigationController release];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	[webView release];
	[topicDictionary release];
    [super dealloc];
}


#pragma mark UIWebViewDelegate Methods

- (BOOL)webView:(UIWebView *)theWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if ([[[request URL] absoluteString] rangeOfString:@"commentOn://"].location != NSNotFound) {
		// post a comment

		NSString *commentOnReplyId = [[[request URL] absoluteString] stringByReplacingOccurrencesOfString:@"commentOn://" withString:@""];

		// open the compose comment view
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"SRC_ME_ACCOUNT"] objectForKey:@"id"] == nil) {
			// user is not logged in
			[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"SRC_ACCOUNT_LOGIN_ACTION" object:nil]];
		} else {
			// user is logged in
			DCComposeCommentViewController *composeViewController = [[DCComposeCommentViewController alloc] initWithNibName:@"DCComposeCommentView" bundle:nil];
			composeViewController.topicId = [[topicDictionary objectForKey:@"id"] intValue];
			composeViewController.replyId = [commentOnReplyId intValue];
			composeViewController.underneathTopicViewController = self;
			UINavigationController *modalNavigationController = [[UINavigationController alloc] initWithRootViewController:composeViewController];
			[modalNavigationController setNavigationBarHidden:YES animated:NO];
			[[self navigationController] presentModalViewController:modalNavigationController animated:YES];
			[composeViewController release];
			[modalNavigationController release];
		}

	} else if ([[[request URL] absoluteString] rangeOfString:@"meToo://"].location != NSNotFound) {
		// me too
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"SRC_ME_ACCOUNT"] objectForKey:@"id"] == nil) {
			// user is not logged in
			[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"SRC_ACCOUNT_LOGIN_ACTION" object:nil]];
		} else {
			// user is logged in
			// set up the connection and launch it
			OAConsumer *consumer = [[OAConsumer alloc] initWithKey:[[DCOAuthParams sharedParams] key] secret:[[DCOAuthParams sharedParams] secret]];
			NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.getsatisfaction.com/topics/%d/me_toos", [[topicDictionary objectForKey:@"id"] intValue]]];
			OAToken *token = [[OAToken alloc] initWithUserDefaultsUsingServiceProviderName:@"GetSatisfaction" prefix:@"accessToken"];
			OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
				consumer:consumer
				token:token
				realm:nil
				signatureProvider:[[[OAPlaintextSignatureProvider alloc] init] autorelease]];
			[request setValue:@"text/x-json" forHTTPHeaderField:@"Accept"];
			[request setHTTPMethod:@"POST"];
			[request setTimeoutInterval:15];

			OADataFetcher *fetcher = [[OADataFetcher alloc] init];
		    [fetcher fetchDataWithRequest:request
				delegate:self
				didFinishSelector:@selector(postTicket:didFinishWithData:)
				didFailSelector:@selector(postTicket:didFailWithError:)];

			[token release];
			[consumer release];
			[request release];
		}

	} else if ([[[request URL] absoluteString] rangeOfString:@"http://api.getsatisfaction.com"].location == NSNotFound &&
		[[[request URL] absoluteString] rangeOfString:@"file:///"].location == NSNotFound) {
			// it's not an ajax call to the api, so send it out to Safari
			NSLog(@"NSNotFound in %@", [[request URL] absoluteString]);
			if ([[NSUserDefaults standardUserDefaults] objectForKey:@"showWarningBeforeJumpToSafari"] != nil
			&& [[[NSUserDefaults standardUserDefaults] objectForKey:@"showWarningBeforeJumpToSafari"] boolValue] == NO) {
				[[UIApplication sharedApplication] openURL:[request URL]];
			} else {
				lastURL = [[request URL] retain];
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?" 
					message:@"This link will open in Safari.\nYou can disable this alert in the Settings app." 
					delegate:self 
					cancelButtonTitle:@"Cancel" 
					otherButtonTitles:@"Go to Safari", nil];
				[alertView show];
				[alertView release];
			}
			return NO;
	}
	return YES;
}

- (void)postTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('meTooButton').innerHTML='Done!';"];
}

- (void)postTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
	NSLog(@"Error posting me too.");
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" 
		message:@"An error occurred while attempting to set Me Too."
		delegate:nil 
		cancelButtonTitle:@"Dismiss" 
		otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}


#pragma mark UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		[[UIApplication sharedApplication] openURL:lastURL];
	}
}

@end
