//
//  DCComposeCommentViewController.m
//  satsat
//
//  Created by David on 2/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DCComposeCommentViewController.h"
#import "GSModelController.h"
#import "OAuthConsumer.h"
#import "DCTopicViewController.h"
#import "DCOAuthParams.h"

@implementation DCComposeCommentViewController

@synthesize topicId;
@synthesize replyId;
@synthesize underneathTopicViewController;


#pragma mark Post Methods

- (IBAction)post {
	[bodyTextView resignFirstResponder];
	uploadingView.hidden = NO;
	[self checkInputAndPost];
}

- (IBAction)cancel {
	if (uploadingView.hidden == NO) {
		uploadingView.hidden = YES;
	} else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"autosavedBody"] isEqualToString:@""]) {
		// all text fields are empty, so exit
		[self cancelAfterAlert];
	} else {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Do you want to save the text you've typed?" 
			delegate:self 
			cancelButtonTitle:@"Cancel" 
			destructiveButtonTitle:@"Don't Save" 
			otherButtonTitles:@"Save", nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
		[actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
		[actionSheet release];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		// don't save, so clear the autosaved text
		[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"autosavedTitle"];
		[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"autosavedBody"];
		[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"autosavedTags"];
		[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"autosavedStyle"];
		[self cancelAfterAlert];
	} else if (buttonIndex == 1) {
		// save, so dismiss the post
		[self cancelAfterAlert];
	} else if (buttonIndex == 2) {
		// cancel, so just dismiss action sheet
	}
}

- (void)cancelAfterAlert {
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)checkInputAndPost {

	// check the required input fields
	BOOL ok = YES;
	NSString *errorString = @"";
	if (topicId <= 0) {
		ok = NO;
		errorString = [errorString stringByAppendingString:@"Topic is not set.  "];
	}
	if (replyId <= 0) {
		ok = NO;
		errorString = [errorString stringByAppendingString:@"Reply is not set.  "];
	}
	if (bodyTextView.text == nil || [bodyTextView.text isEqualToString:@""]) {
		ok = NO;
		errorString = [errorString stringByAppendingString:@"Comment is blank.  "];
	}

	if (ok == NO) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Post is Incomplete" 
			message:errorString 
			delegate:self 
			cancelButtonTitle:@"Dismiss" 
			otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		uploadingView.hidden = YES;
		return;
	}

	// disable the cancel button
	self.navigationItem.leftBarButtonItem.enabled = NO;

	// set up the connection and launch it
	OAConsumer *consumer = [[OAConsumer alloc] initWithKey:[[DCOAuthParams sharedParams] key] secret:[[DCOAuthParams sharedParams] secret]];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.getsatisfaction.com/topics/%d/replies", topicId]];
	OAToken *token = [[OAToken alloc] initWithUserDefaultsUsingServiceProviderName:@"GetSatisfaction" prefix:@"accessToken"];
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
		consumer:consumer
		token:token
		realm:nil
		signatureProvider:[[[OAPlaintextSignatureProvider alloc] init] autorelease]];
	[request setValue:@"text/x-json" forHTTPHeaderField:@"Accept"];
	[request setHTTPMethod:@"POST"];
	[request setTimeoutInterval:15];

	OARequestParameter *bodyParam = [[OARequestParameter alloc] initWithName:@"reply[content]" value:bodyTextView.text];
	OARequestParameter *replyParam = [[OARequestParameter alloc] initWithName:@"reply[parent_id]" value:[NSString stringWithFormat:@"%d", replyId]];
	NSArray *params = [NSArray arrayWithObjects:bodyParam, replyParam, nil];
	[request setParameters:params];

	fetcher = [[OADataFetcher alloc]init];
	[fetcher fetchDataWithRequest:request 
						 delegate:self 
				didFinishSelector:@selector(postTicket:didFinishWithData:) 
				  didFailSelector:@selector(postTicket:didFailWithError:)];

	[bodyParam release];
	[replyParam release];
	[token release];
	[consumer release];
	[request release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	// return firstResponder so keyboard pops up
	[bodyTextView becomeFirstResponder];
}

- (void)postTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	[fetcher release];
	fetcher = nil;
	if (ticket.didSucceed) {
		// clear autosaved values
		[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"autosavedTitle"];
		[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"autosavedBody"];
		[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"autosavedTags"];
		[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"autosavedStyle"];

		// refresh the topic view so the reply shows up
		[underneathTopicViewController viewWillAppear:NO];

		// exit
		[self.navigationController dismissModalViewControllerAnimated:YES];
	}
}

- (void)postTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
	NSLog(@"Error posting reply.");
	[fetcher release];
	fetcher = nil;
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" 
		message:@"An error occurred while attempting to upload the post."
		delegate:self 
		cancelButtonTitle:@"Dismiss" 
		otherButtonTitles:nil];
	[alertView show];
	[alertView release];
	uploadingView.hidden = YES;
	self.navigationItem.leftBarButtonItem.enabled = YES;
	return;
}


#pragma mark UITextViewDelegate Methods

- (void)textViewDidChange:(UITextView *)textView {
	// autosave text
	if (textView == bodyTextView) {
		[[NSUserDefaults standardUserDefaults] setObject:textView.text forKey:@"autosavedBody"];
	}
}


#pragma mark UIViewController Methods

- (void)viewDidLoad {
    [super viewDidLoad];

	// setup text views
	bodyTextView.font = [UIFont systemFontOfSize:14];
	bodyTextView.autocapitalizationType = UITextAutocapitalizationTypeSentences;

	bodyTextView.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"autosavedBody"];

	[bodyTextView becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	[bodyTextView release];
	[uploadingView release];
	[underneathTopicViewController release];
    [super dealloc];
}

@end
