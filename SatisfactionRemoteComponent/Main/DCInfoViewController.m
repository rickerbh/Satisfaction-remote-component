//
//  DCInfoViewController.m
//  SRCExample1
//
//  Created by David on 2/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DCInfoViewController.h"

@implementation DCInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)cancelAction {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)safariAction {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://getsatisfaction.com"]];;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	[safariButton release];
	[licenseTextView release];
    [super dealloc];
}

@end
