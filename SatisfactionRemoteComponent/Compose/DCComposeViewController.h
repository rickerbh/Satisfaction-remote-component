//
//  DCComposeViewController.h
//  satsat
//
//  Created by David on 2/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SatisfactionRemoteComponentConstants.h"
#import "DCImageUploader.h"
#import "OAuthConsumer.h"

@interface DCComposeViewController : UIViewController <UITextViewDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate> {
	IBOutlet UIImageView *tabImageView;
	IBOutlet UIImageView *typeImageView;
	IBOutlet UITextView *titleTextView;
	IBOutlet UITextView *bodyTextView;
	IBOutlet UIImageView *photoImageView;
	IBOutlet UITextView *tagsTextView;
	IBOutlet UILabel *titleLabel;
	IBOutlet UILabel *bodyLabel;
	IBOutlet UILabel *tagsLabel;
	IBOutlet UIImagePickerController *imagePickerController;
	IBOutlet UIView *uploadingView;
	IBOutlet UIButton *removePhotoButton;
	IBOutlet UIButton *takePhotoButton;

	// tab buttons
	IBOutlet UIButton *typeTabButton;
	IBOutlet UIButton *bodyTabButton;
	IBOutlet UIButton *photoTabButton;
	IBOutlet UIButton *tagsTabButton;

	// type buttons
	IBOutlet UIButton *questionTypeButton;
	IBOutlet UIButton *ideaTypeButton;
	IBOutlet UIButton *problemTypeButton;
	IBOutlet UIButton *praiseTypeButton;

	// tab images
	UIImage *typeTabImage;
	UIImage *bodyTabImage;
	UIImage *photoTabImage;
	UIImage *tagsTabImage;

	// type images
	UIImage *questionTypeImage;
	UIImage *ideaTypeImage;
	UIImage *problemTypeImage;
	UIImage *praiseTypeImage;

	DCImageUploader *uploader;
	NSString *companyKey;
	NSString *productName;
	NSString *style;
	UINavigationController *underneathNavigationController;

	OADataFetcher *fetcher;
}

@property (nonatomic, retain) NSString *companyKey;
@property (nonatomic, retain) NSString *productName;
@property (nonatomic, retain) UINavigationController *underneathNavigationController;

// tab actions
- (IBAction)typeTabAction;
- (IBAction)bodyTabAction;
- (IBAction)photoTabAction;
- (IBAction)tagsTabAction;

// type actions
- (IBAction)questionTypeButton;
- (IBAction)ideaTypeButton;
- (IBAction)problemTypeButton;
- (IBAction)praiseTypeButton;

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
