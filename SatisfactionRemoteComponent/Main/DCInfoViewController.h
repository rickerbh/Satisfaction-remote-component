//
//  DCInfoViewController.h
//  SRCExample1
//
//  Created by David on 2/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCInfoViewController : UIViewController {
	IBOutlet UIButton *safariButton;
	IBOutlet UITextView *licenseTextView;
}

- (IBAction)cancelAction;
- (IBAction)safariAction;

@end
