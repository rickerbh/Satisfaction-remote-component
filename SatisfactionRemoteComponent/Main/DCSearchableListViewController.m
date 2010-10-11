//
//  DCSearchableListViewController.m
//  satsat
//
//  Created by David on 2/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DCSearchableListViewController.h"
#import "DCInfoViewController.h"

@implementation DCSearchableListViewController

#define kLoadingLabelTag 1

@synthesize myTableView;
@synthesize mySearchBar;
@synthesize modelController;
@synthesize listContent;
@synthesize fullListContent;
@synthesize isLoading;
@synthesize loadingView;
@synthesize errorView;
@synthesize noResultsView;
@synthesize parentNavigationController;
@synthesize companyName;

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [myTableView release];
	[mySearchBar release];
	[modelController release];
	[listContent release];
	[loadingView release];
	[errorView release];
	[noResultsView release];
	[connectionErrorLabel release];
	[toolbarLabel release];
	[loginButton release];
	[super dealloc];
}

- (IBAction)loginButtonAction {
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"SRC_ME_ACCOUNT"] objectForKey:@"id"] == nil) {
		// user is not logged in, so open login view
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"SRC_ACCOUNT_LOGIN_ACTION" object:nil]];
	} else {
		// user is logged in, so log out
		UIActionSheet *actionSheet;
		actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Sign Out" otherButtonTitles:nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
		[actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
		[actionSheet release];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		// Yes
		[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"SRC_ME_ACCOUNT"];
		[self updateLoginText];
	} else if (buttonIndex == 1) {
		// No
	}
}

- (IBAction)infoAction {
	DCInfoViewController *infoViewController = [[DCInfoViewController alloc] initWithNibName:@"DCInfoView" bundle:nil];
	[[self navigationController] presentModalViewController:infoViewController animated:YES];
	[infoViewController release];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)didFinishDownloadingArray:(NSArray *)array {
	if (modelController.lastPage > 1) {
		self.listContent = [self.listContent arrayByAddingObjectsFromArray:array];
	} else {
		self.listContent = array;
	}

	self.isLoading = NO;
	isLoadingMore = NO;
	[myTableView reloadData];

	if (array == nil) {
		// Connection Error
		float y = round((self.view.bounds.size.height / 2) - (errorView.frame.size.height / 2));
		if (mySearchBar.showsCancelButton == YES) {
			y -= 68;
		}
		errorView.frame = CGRectMake(errorView.frame.origin.x, y, errorView.frame.size.width, errorView.frame.size.height);
		errorView.hidden = NO;
		myTableView.hidden = YES;
	} else if ([array count] == 0) {
		// No Results
		float y = round((self.view.bounds.size.height / 2) - (noResultsView.frame.size.height / 2));
		if (mySearchBar.showsCancelButton == YES) {
			y -= 68;
		}
		noResultsView.frame = CGRectMake(noResultsView.frame.origin.x, y, noResultsView.frame.size.width, noResultsView.frame.size.height);
		noResultsView.hidden = NO;
		myTableView.hidden = YES;
	} else {
		// Good Results
		if ([mySearchBar.text isEqualToString:@""] == NO) {
			// we're in search mode
			if ([self tableView:myTableView numberOfRowsInSection:0] > 0 && modelController.lastPage <= 1) {
				[myTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
			}
		} else {
			[myTableView flashScrollIndicators];
		}
	}
}

- (void)calculateCachedFancyDatesWithArray:(NSArray *)array {
	
}

- (IBAction)tryAgain:(id)sender {
	if (self.modelController != nil) {
		if ([mySearchBar.text isEqualToString:@""] == NO) {
			// we're in search mode
			[self.modelController findByQuery:mySearchBar.text];
		} else {
			[self.modelController findAll];
		}
	}
}

- (void)setIsLoading:(BOOL)yesNo {
	isLoading = yesNo;
	if (isLoading == YES) {
		float y = round((self.view.frame.size.height / 2) - (loadingView.frame.size.height / 2));
		if (mySearchBar.showsCancelButton == YES) {
			y -= 90;
		}
		loadingView.frame = CGRectMake(loadingView.frame.origin.x, y, loadingView.frame.size.width, loadingView.frame.size.height);
		loadingView.hidden = NO;
		myTableView.hidden = YES;
	} else {
		loadingView.hidden = YES;
		myTableView.hidden = NO;
	}
	errorView.hidden = YES;
	noResultsView.hidden = YES;
}

- (void)startLoading {
	self.isLoading = YES;
}

- (UINavigationController *)currentNavigationController {
	return self.navigationController;
}

-(void)needToReloadData{
	needToReloadData = YES;
}


#pragma mark UIViewController

- (void)viewDidLoad {
	[[NSNotificationCenter defaultCenter]addObserver:self
											selector:@selector(needToReloadData)
												name:@"needToReloadData"
											  object:nil];
	
	self.listContent = [NSArray array];
	self.fullListContent = [NSArray array];
	needsReloadDataAfterDisappear = NO;
	typingTimer = nil;
	isLoadingMore = NO;
	
	// don't get in the way of user typing
	mySearchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	mySearchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	mySearchBar.showsCancelButton = NO;
	mySearchBar.tintColor = [UIColor colorWithRed:0.24 green:0.29 blue:0.32 alpha:0.0];
	mySearchBar.text = @"";

	connectionErrorLabel.font = [UIFont boldSystemFontOfSize:13];
	connectionErrorLabel.shadowOffset = CGSizeMake(0, 1);

	if ([mySearchBar.placeholder isEqualToString:@""] == YES || mySearchBar.placeholder == nil) {
		mySearchBar.placeholder = [NSString stringWithFormat:@"Search %@", self.companyName];
	}

	toolbarLabel.font = [UIFont systemFontOfSize:13];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLoginText) name:@"SRC_ACCOUNT_LOGIN_TEXT_REFRESH" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[myTableView reloadData];
	[self updateLoginText];
}

- (void)updateLoginText {
	// update the logged in text
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"SRC_ME_ACCOUNT"] objectForKey:@"id"] != nil) {
		loginButton.title = @"Sign Out";
		toolbarLabel.text = [NSString stringWithFormat:@"%@", [[[NSUserDefaults standardUserDefaults] objectForKey:@"SRC_ME_ACCOUNT"] objectForKey:@"name"]];
		toolbarLabel.textAlignment = UITextAlignmentRight;
	} else {
		loginButton.title = @"Sign In";
		toolbarLabel.text = @"Powered by Get Satisfaction";
		toolbarLabel.textAlignment = UITextAlignmentLeft;
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[myTableView deselectRowAtIndexPath:[myTableView indexPathForSelectedRow] animated:YES];
	if (self.modelController != nil && isLoading == NO) {
		self.modelController.lastPage = 0;
		[self.modelController findAll];
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	if (needsReloadDataAfterDisappear == YES) {
		[myTableView reloadData];
		needsReloadDataAfterDisappear = NO;
	}
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	int nextPageRow = 0;
	if (modelController.nextPageExists == YES && [listContent count] > 0) {
		nextPageRow = 1;
	}
	return [listContent count] + nextPageRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 25;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (modelController.nextPageExists == YES && indexPath.row >= [listContent count]) {
		// this is the nextPageExists row
		return 70;
	}
	return myTableView.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	UITableViewCell *cell;

	if (modelController.nextPageExists == YES && indexPath.row >= [listContent count]) {
		// this is the nextPageExists row
		cell = [tableView dequeueReusableCellWithIdentifier:@"NextPageCellIdentifier"];
		UILabel *loadingLabel;
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"NextPageCellIdentifier"] autorelease];
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.textAlignment = UITextAlignmentLeft;

			loadingLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 70)] autorelease];
		    loadingLabel.tag = kLoadingLabelTag;
		    loadingLabel.font = [UIFont boldSystemFontOfSize:14.0];
		    loadingLabel.textAlignment = UITextAlignmentCenter;
			loadingLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
		    loadingLabel.highlightedTextColor = [UIColor whiteColor];
		    [cell.contentView addSubview:loadingLabel];
		} else {
			loadingLabel = (UILabel *)[cell.contentView viewWithTag:kLoadingLabelTag];
		}
		if (isLoadingMore == YES) {
			loadingLabel.text = @"Loading...";
		} else {
			loadingLabel.text = @"Load 30 More...";
		}
		cell.accessoryType = UITableViewCellAccessoryNone;
	} else {
		// this is a regular row
		cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"cellID"] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}

		cell.text = [[listContent objectAtIndex:indexPath.row] objectForKey:@"name"];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// subclasses should handle this
}

- (BOOL)shouldContinueForTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (modelController.nextPageExists == YES && indexPath.row >= [listContent count]) {
		// this is the nextPageExists row
		if ([mySearchBar.text isEqualToString:@""] == NO) {
			// we're in search mode
			[self.modelController findByQueryNextPage:mySearchBar.text];
		} else {
			[self.modelController findAllNextPage];
		}
		isLoadingMore = YES;
		[myTableView reloadData];
		[myTableView deselectRowAtIndexPath:[myTableView indexPathForSelectedRow] animated:YES];

		return NO;
	}
	return YES;
}


#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	// only show the status bar's cancel button while in edit mode
	mySearchBar.showsCancelButton = YES;
	if ([mySearchBar.text isEqualToString:@""] == YES) {
		// NOT in search mode yet
		self.fullListContent = self.listContent;
	}
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	mySearchBar.showsCancelButton = NO;
	if ([mySearchBar.text isEqualToString:@""] == YES && self.listContent != self.fullListContent) {
		// NOT in search mode
		self.listContent = self.fullListContent;
		[self calculateCachedFancyDatesWithArray:self.listContent];
		[myTableView reloadData];
		if ([self tableView:myTableView numberOfRowsInSection:0] > 0) {
			[myTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
		}
		self.isLoading = NO;
	}
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	if ([typingTimer isValid] == YES) {
		[typingTimer invalidate];
	}
	typingTimer = [[NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(textDidChangeAfterDelay) userInfo:nil repeats:NO] retain];
}

- (void)textDidChangeAfterDelay {
	if ([mySearchBar.text isEqualToString:@""] == NO) {
		[modelController findByQuery:mySearchBar.text];
	}
}

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	mySearchBar.showsCancelButton = NO;
	mySearchBar.text = @"";
	[mySearchBar resignFirstResponder];
}

// called when Search (in our case "Done") button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
}


@end

