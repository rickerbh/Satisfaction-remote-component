//
//  DCComposeReplyViewController.h
//  satsat
//
//  Created by David on 2/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SatisfactionRemoteComponentConstants.h"
#import "DCImageUploader.h"
#import "DCTopicViewController.h"

@interface DCComposeReplyViewController : UIViewController <UITextViewDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate> {
	IBOutlet UIImageView *tabImageView;
	IBOutlet UITextView *bodyTextView;
	IBOutlet UIImageView *photoImageView;
	IBOutlet UIImagePickerController *imagePickerController;
	IBOutlet UIView *uploadingView;
	IBOutlet UIButton *removePhotoButton;
	IBOutlet UIButton *takePhotoButton;

	// tab buttons
	IBOutlet UIButton *bodyTabButton;
	IBOutlet UIButton *photoTabButton;

	// tab images
	UIImage *bodyTabImage;
	UIImage *photoTabImage;

	DCImageUploader *uploader;
	int topicId;
	DCTopicViewController *underneathTopicViewController;

	OADataFetcher *fetcher;
}

@property (nonatomic) int topicId;
@property (nonatomic, retain) DCTopicViewController *underneathTopicViewController;

// tab actions
- (IBAction)bodyTabAction;
- (IBAction)photoTabAction;

// photo methods
- (IBAction)choosePhoto;
- (IBAction)takePhoto;
- (IBAction)removePhoto;
- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
        editingInfo:(NSDictionary *)editingInfo;
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;

- (IBAction)post;
- (IBAction)cancel;
- (void)checkInputAndPost;
- (void)cancelAfterAlert;

@end
