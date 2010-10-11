//
//  DCComposeViewController.m
//  satsat
//
//  Created by David on 2/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DCComposeViewController.h"
#import "GSModelController.h"
#import "DCTopicViewController.h"
#import "DCOAuthParams.h"

@implementation DCComposeViewController

@synthesize companyKey;
@synthesize productName;
@synthesize underneathNavigationController;

#pragma mark Tab Actions

- (IBAction)typeTabAction {
	// tab image
	tabImageView.image = typeTabImage;

	// types on first tab
	typeImageView.hidden = NO;
	questionTypeButton.hidden = NO;
	ideaTypeButton.hidden = NO;
	problemTypeButton.hidden = NO;
	praiseTypeButton.hidden = NO;

	// text views
	titleTextView.hidden = NO;
	bodyTextView.hidden = YES;
	photoImageView.hidden = YES;
	tagsTextView.hidden = YES;
	if ([titleTextView.text isEqualToString:@""] == YES) {
		titleLabel.hidden = NO;
	} else {
		titleLabel.hidden = YES;
	}
	bodyLabel.hidden = YES;
	tagsLabel.hidden = YES;

	[tagsTextView resignFirstResponder];
	[bodyTextView resignFirstResponder];
	[titleTextView becomeFirstResponder];
}

- (IBAction)bodyTabAction {
	// tab image
	tabImageView.image = bodyTabImage;

	// types on first tab
	typeImageView.hidden = YES;
	questionTypeButton.hidden = YES;
	ideaTypeButton.hidden = YES;
	problemTypeButton.hidden = YES;
	praiseTypeButton.hidden = YES;

	// text views
	titleTextView.hidden = YES;
	bodyTextView.hidden = NO;
	photoImageView.hidden = YES;
	tagsTextView.hidden = YES;
	titleLabel.hidden = YES;
	if ([bodyTextView.text isEqualToString:@""] == YES) {
		bodyLabel.hidden = NO;
	} else {
		bodyLabel.hidden = YES;
	}
	tagsLabel.hidden = YES;

	[titleTextView resignFirstResponder];
	[tagsTextView resignFirstResponder];
	[bodyTextView becomeFirstResponder];
}

- (IBAction)photoTabAction {
	// tab image
	tabImageView.image = photoTabImage;

	// types on first tab
	typeImageView.hidden = YES;
	questionTypeButton.hidden = YES;
	ideaTypeButton.hidden = YES;
	problemTypeButton.hidden = YES;
	praiseTypeButton.hidden = YES;

	// text views
	titleTextView.hidden = YES;
	bodyTextView.hidden = YES;
	photoImageView.hidden = NO;
	tagsTextView.hidden = YES;
	titleLabel.hidden = YES;
	bodyLabel.hidden = YES;
	tagsLabel.hidden = YES;

	[titleTextView resignFirstResponder];
	[bodyTextView resignFirstResponder];
	[tagsTextView resignFirstResponder];
}

- (IBAction)tagsTabAction {
	// tab image
	tabImageView.image = tagsTabImage;

	// types on first tab
	typeImageView.hidden = YES;
	questionTypeButton.hidden = YES;
	ideaTypeButton.hidden = YES;
	problemTypeButton.hidden = YES;
	praiseTypeButton.hidden = YES;

	// text views
	titleTextView.hidden = YES;
	bodyTextView.hidden = YES;
	photoImageView.hidden = YES;
	tagsTextView.hidden = NO;
	titleLabel.hidden = YES;
	bodyLabel.hidden = YES;
	if ([tagsTextView.text isEqualToString:@""] == YES) {
		tagsLabel.hidden = NO;
	} else {
		tagsLabel.hidden = YES;
	}

	[titleTextView resignFirstResponder];
	[bodyTextView resignFirstResponder];
	[tagsTextView becomeFirstResponder];
}


#pragma mark Type Actions

- (IBAction)questionTypeButton {
	typeImageView.image = questionTypeImage;
	style = @"question";
	[[NSUserDefaults standardUserDefaults] setObject:style forKey:@"autosavedStyle"];
}

- (IBAction)ideaTypeButton {
	typeImageView.image = ideaTypeImage;
	style = @"idea";
	[[NSUserDefaults standardUserDefaults] setObject:style forKey:@"autosavedStyle"];
}

- (IBAction)problemTypeButton {
	typeImageView.image = problemTypeImage;
	style = @"problem";
	[[NSUserDefaults standardUserDefaults] setObject:style forKey:@"autosavedStyle"];
}

- (IBAction)praiseTypeButton {
	typeImageView.image = praiseTypeImage;
	style = @"praise";
	[[NSUserDefaults standardUserDefaults] setObject:style forKey:@"autosavedStyle"];
}


#pragma mark Photo Methods

- (IBAction)choosePhoto {
	imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	imagePickerController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	[[self navigationController] presentModalViewController:imagePickerController animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
	photoImageView.image = image;
	removePhotoButton.hidden = NO;
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

- (IBAction)takePhoto {
	imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	[[self navigationController] presentModalViewController:imagePickerController animated:YES];
}

- (IBAction)removePhoto {
	photoImageView.image = nil;
	removePhotoButton.hidden = YES;
}


#pragma mark Post Methods

- (IBAction)post {
	[tagsTextView resignFirstResponder];
	[bodyTextView resignFirstResponder];
	[titleTextView resignFirstResponder];
	uploadingView.hidden = NO;

	if (photoImageView.image != nil) {
		uploader = [[DCImageUploader alloc] init];
		[uploader uploadImage:photoImageView.image delegate:self];
	} else {
		[self checkInputAndPost];
	}
}

- (IBAction)cancel {
	if (uploadingView.hidden == NO) {
		if (uploader != nil) {
			[uploader cancel];
		}
		uploadingView.hidden = YES;
	} else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"autosavedTitle"] isEqualToString:@""] &&
		[[[NSUserDefaults standardUserDefaults] objectForKey:@"autosavedBody"] isEqualToString:@""] &&
		[[[NSUserDefaults standardUserDefaults] objectForKey:@"autosavedTags"] isEqualToString:@""]) {
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

- (void)imageUploadDidFinishWithResponseString:(NSString *)theString {
	NSDictionary *dictionary = [GSModelController dictionaryFromJSON:theString];
	if ([dictionary objectForKey:@"image_url"] != nil) {
		NSString *inlineImageURL = [dictionary objectForKey:@"image_url"];
		NSString *fullImageURL = [dictionary objectForKey:@"full_image_url"];
		NSString *imageHTML = [NSString stringWithFormat:@"<a href=\"%@\"><img src=\"%@\" alt=\"\" /></a>", fullImageURL, inlineImageURL];
		bodyTextView.text = [NSString stringWithFormat:@"%@<br><br>%@", bodyTextView.text, imageHTML];
		NSLog(@"uploaded photo, now post");
		[self checkInputAndPost];
	} else {
		NSLog(@"error uploading image");
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" 
			message:@"An error occurred while attempting to upload the photo."
			delegate:self
			cancelButtonTitle:@"Dismiss" 
			otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		uploadingView.hidden = YES;
		self.navigationItem.leftBarButtonItem.enabled = YES;
	}
}

- (void)checkInputAndPost {

	// check the required input fields
	BOOL ok = YES;
	NSString *errorString = @"";
	if (companyKey == nil || [companyKey isEqualToString:@""] == YES) {
		ok = NO;
		errorString = [errorString stringByAppendingString:@"Company is not set.  "];
	}
	if (style == nil || [style isEqualToString:@""] == YES) {
		ok = NO;
		errorString = [errorString stringByAppendingString:@"Style is not set.  "];
	}
	if (titleTextView.text == nil || [titleTextView.text isEqualToString:@""] == YES) {
		ok = NO;
		errorString = [errorString stringByAppendingString:@"Title is blank.  "];
	}
	if (bodyTextView.text == nil || [bodyTextView.text isEqualToString:@""] == YES) {
		ok = NO;
		errorString = [errorString stringByAppendingString:@"Description is blank.  "];
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
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.getsatisfaction.com/companies/%@/topics", companyKey]];
	OAToken *token = [[OAToken alloc] initWithUserDefaultsUsingServiceProviderName:@"GetSatisfaction" prefix:@"accessToken"];
	OAPlaintextSignatureProvider *provider = [[OAPlaintextSignatureProvider alloc] init];
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
		consumer:consumer
		token:token
		realm:nil
		signatureProvider:provider];
	[provider release];
	[request setValue:@"text/x-json" forHTTPHeaderField:@"Accept"];
	[request setHTTPMethod:@"POST"];
	[request setTimeoutInterval:15];

	OARequestParameter *companyParam = [[OARequestParameter alloc] initWithName:@"topic[company_domain]" value:companyKey];
	OARequestParameter *styleParam = [[OARequestParameter alloc] initWithName:@"topic[style]" value:style] ;
	OARequestParameter *titleParam = [[OARequestParameter alloc] initWithName:@"topic[subject]" value:titleTextView.text] ;
	OARequestParameter *bodyParam = [[OARequestParameter alloc] initWithName:@"topic[additional_detail]" value:bodyTextView.text] ;
	OARequestParameter *tagsParam = [[OARequestParameter alloc] initWithName:@"topic[keywords]" value:tagsTextView.text] ;
	NSArray *params;
	if (productName != nil) {
		OARequestParameter *productsParam = [[OARequestParameter alloc] initWithName:@"topic[products]" value:productName] ;
		params = [NSArray arrayWithObjects:companyParam, styleParam, titleParam, bodyParam, tagsParam, productsParam, nil];
		[productsParam release];
	} else {
		params = [NSArray arrayWithObjects:companyParam, styleParam, titleParam, bodyParam, tagsParam, nil];
	}
	[request setParameters:params];
	[companyParam release];
	[styleParam release];
	[titleParam release];
	[bodyParam release];
	[tagsParam release];

	fetcher = [[OADataFetcher alloc]init];
	[fetcher fetchDataWithRequest:request 
								delegate:self 
					   didFinishSelector:@selector(postTicket:didFinishWithData:) 
						 didFailSelector:@selector(postTicket:didFailWithError:)];
	
	[token release];
	[consumer release];
	[request release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	// return firstResponder so keyboard pops up
	if (tabImageView.image == typeTabImage) {
		[titleTextView becomeFirstResponder];
	} else if (tabImageView.image == bodyTabImage) {
		[bodyTextView becomeFirstResponder];
	} else if (tabImageView.image == tagsTabImage) {
		[tagsTextView becomeFirstResponder];
	}
}

- (void)postTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	[fetcher release];
	fetcher = nil;
	if (ticket.didSucceed) {
		NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSDictionary *dictionary = [GSModelController dictionaryFromJSON:string];

		// clear autosaved values
		[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"autosavedTitle"];
		[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"autosavedBody"];
		[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"autosavedTags"];
		[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"autosavedStyle"];

		DCTopicViewController *topicViewController = [[DCTopicViewController alloc] initWithNibName:@"DCTopicView" bundle:nil];
		topicViewController.navigationItem.title = [NSString stringWithFormat:@"%d Replies", [[dictionary objectForKey:@"reply_count"] intValue]];
		topicViewController.topicDictionary = dictionary;
		[self.underneathNavigationController pushViewController:topicViewController animated:NO];
		[topicViewController release];

		[string release];

		// exit
		[[NSNotificationCenter defaultCenter]postNotificationName:@"needToReloadData"
														   object:nil];
		[self.navigationController dismissModalViewControllerAnimated:YES];
	} else {
		NSLog(@"Error posting topic.");
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" 
			message:@"An error occurred while attempting to upload the post."
			delegate:self 
			cancelButtonTitle:@"Dismiss" 
			otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		uploadingView.hidden = YES;
		self.navigationItem.leftBarButtonItem.enabled = YES;
	}
}

- (void)postTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
	NSLog(@"Error posting topic.");
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
	if ([textView.text isEqualToString:@""] == YES) {
		if (textView == titleTextView) {
			titleLabel.hidden = NO;
		} else if (textView == bodyTextView) {
			bodyLabel.hidden = NO;
		} else if (textView == tagsTextView) {
			tagsLabel.hidden = NO;
		}
	} else {
		if (textView == titleTextView) {
			titleLabel.hidden = YES;
		} else if (textView == bodyTextView) {
			bodyLabel.hidden = YES;
		} else if (textView == tagsTextView) {
			tagsLabel.hidden = YES;
		}
	}

	// autosave text
	if (textView == titleTextView) {
		[[NSUserDefaults standardUserDefaults] setObject:textView.text forKey:@"autosavedTitle"];
	} else if (textView == bodyTextView) {
		[[NSUserDefaults standardUserDefaults] setObject:textView.text forKey:@"autosavedBody"];
	} else if (textView == tagsTextView) {
		[[NSUserDefaults standardUserDefaults] setObject:textView.text forKey:@"autosavedTags"];
	}
}


#pragma mark UIViewController Methods

- (void)viewDidLoad {
    [super viewDidLoad];

	// tab images
	typeTabImage = [UIImage imageNamed:@"DC_start-topic-tab-type.png"];
	bodyTabImage = [UIImage imageNamed:@"DC_start-topic-tab-body.png"];
	photoTabImage = [UIImage imageNamed:@"DC_start-topic-tab-photo.png"];
	tagsTabImage = [UIImage imageNamed:@"DC_start-topic-tab-tags.png"];

	// type images
	questionTypeImage = [UIImage imageNamed:@"DC_start-topic-type-question.png"];
	ideaTypeImage = [UIImage imageNamed:@"DC_start-topic-type-idea.png"];
	problemTypeImage = [UIImage imageNamed:@"DC_start-topic-type-problem.png"];
	praiseTypeImage = [UIImage imageNamed:@"DC_start-topic-type-praise.png"];

	// setup text views
	titleTextView.font = [UIFont systemFontOfSize:18];
	titleTextView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
	bodyTextView.font = [UIFont systemFontOfSize:14];
	bodyTextView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
	tagsTextView.font = [UIFont systemFontOfSize:14];
	tagsTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;
	titleLabel.font = [UIFont systemFontOfSize:18];
	bodyLabel.font = [UIFont systemFontOfSize:14];
	tagsLabel.font = [UIFont systemFontOfSize:14];

	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		takePhotoButton.hidden = YES;
	}

	[self typeTabAction];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	titleTextView.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"autosavedTitle"];
	bodyTextView.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"autosavedBody"];
	tagsTextView.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"autosavedTags"];

	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"autosavedStyle"] isEqualToString:@"idea"] == YES) {
		[self ideaTypeButton];
	} else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"autosavedStyle"] isEqualToString:@"problem"] == YES) {
		[self problemTypeButton];
	} else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"autosavedStyle"] isEqualToString:@"answer"] == YES) {
		[self praiseTypeButton];
	} else {
		[self questionTypeButton];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[tabImageView release];
	[typeImageView release];
	[titleTextView release];
	[bodyTextView release];
	[photoImageView release];
	[tagsTextView release];
	[titleLabel release];
	[bodyLabel release];
	[tagsLabel release];
	[imagePickerController release];
	[uploadingView release];
	[removePhotoButton release];
	[typeTabButton release];
	[bodyTabButton release];
	[photoTabButton release];
	[tagsTabButton release];
	[questionTypeButton release];
	[ideaTypeButton release];
	[problemTypeButton release];
	[praiseTypeButton release];
	//[typeTabImage release];
	//[bodyTabImage release];
	//[photoTabImage release];
	//[tagsTabImage release];
	//[questionTypeImage release];
	//[ideaTypeImage release];
	//[problemTypeImage release];
	//[praiseTypeImage release];
	[style release];
	[underneathNavigationController release];
    [super dealloc];
}

@end
