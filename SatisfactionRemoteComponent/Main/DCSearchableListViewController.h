//
//  DCSearchableListViewController.h
//  satsat
//
//  Created by David on 2/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SatisfactionRemoteComponentConstants.h"
#import "GSModelController.h"
#import "DCCustomSearchBar.h"

@interface DCSearchableListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIActionSheetDelegate> {
	IBOutlet UITableView *myTableView;
	IBOutlet DCCustomSearchBar *mySearchBar;
	GSModelController *modelController;
	NSArray *listContent;
	NSArray *fullListContent;
	BOOL isLoading;
	BOOL inSearchMode;
	IBOutlet UIView *loadingView;
	IBOutlet UIView *errorView;
	IBOutlet UIView *noResultsView;
	BOOL needsReloadDataAfterDisappear;
	BOOL needToReloadData;
	UINavigationController *parentNavigationController;
	NSTimer *typingTimer;
	BOOL isLoadingMore;
	NSString *companyName;

	IBOutlet UILabel *connectionErrorLabel;
	IBOutlet UILabel *toolbarLabel;
	IBOutlet UIBarButtonItem *loginButton;
}

@property (nonatomic, retain) UITableView *myTableView;
@property (nonatomic, retain) DCCustomSearchBar *mySearchBar;
@property (nonatomic, retain) GSModelController *modelController;
@property (nonatomic, retain) NSArray *listContent;
@property (nonatomic, retain) NSArray *fullListContent;
@property (nonatomic) BOOL isLoading;
@property (nonatomic, retain) IBOutlet UIView *loadingView;
@property (nonatomic, retain) IBOutlet UIView *errorView;
@property (nonatomic, retain) IBOutlet UIView *noResultsView;
@property (nonatomic, retain) UINavigationController *parentNavigationController;
@property (nonatomic, retain) NSString *companyName;

- (IBAction)loginButtonAction;
- (IBAction)infoAction;
- (void)didFinishDownloadingArray:(NSArray *)array;
- (void)calculateCachedFancyDatesWithArray:(NSArray *)array;
- (IBAction)tryAgain:(id)sender;
- (void)startLoading;
- (UINavigationController *)currentNavigationController;
- (BOOL)shouldContinueForTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)updateLoginText;

@end
