//
//  DCTopicsViewController.m
//  satsat
//
//  Created by David on 2/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DCTopicsViewController.h"
#import "DCFancyDate.h"
#import "DCTopicViewController.h"

@implementation DCTopicsViewController

#define kSubjectLabelTag 1
#define kCountsLabelTag 2
#define kCreatedLabelTag 3
#define kActivityLabelTag 4
#define kIconImageViewTag 5
#define kLoadingLabelTag 1

@synthesize companyKey;
@synthesize productId;

- (void)dealloc {
	[ideaImage release];
	[questionImage release];
	[problemImage release];
	[praiseImage release];
	[talkImage release];
	[updateImage release];
	[selectedIdeaImage release];
	[selectedQuestionImage release];
	[selectedProblemImage release];
	[selectedPraiseImage release];
	[selectedTalkImage release];
	[selectedUpdateImage release];
	[companyKey release];
	[cachedFancyDatesCreated release];
	[cachedFancyDatesActivity release];
	[super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

-(void)needToReloadData{
	[self.modelController release];
	self.modelController = [[GSTopicController alloc] init];
	self.modelController.delegate = self;
	[(GSTopicController *)self.modelController setCompanyKey:self.companyKey];
	[(GSTopicController *)self.modelController setProductId:self.productId];
}


- (void)viewDidLoad {
	[super viewDidLoad];

	// create the master list
	self.modelController = [[GSTopicController alloc] init];
	self.modelController.delegate = self;
	[(GSTopicController *)self.modelController setCompanyKey:self.companyKey];
	[(GSTopicController *)self.modelController setProductId:self.productId];

	myTableView.rowHeight = 70.0;

	ideaImage = [UIImage imageNamed:@"DC_icon-idea.png"];
	questionImage = [UIImage imageNamed:@"DC_icon-question.png"];
	problemImage = [UIImage imageNamed:@"DC_icon-problem.png"];
	praiseImage = [UIImage imageNamed:@"DC_icon-praise.png"];
	talkImage = [UIImage imageNamed:@"DC_icon-talk.png"];
	updateImage = [UIImage imageNamed:@"DC_icon-update.png"];
	selectedIdeaImage = [UIImage imageNamed:@"DC_selected-icon-idea.png"];
	selectedQuestionImage = [UIImage imageNamed:@"DC_selected-icon-question.png"];
	selectedProblemImage = [UIImage imageNamed:@"DC_selected-icon-problem.png"];
	selectedPraiseImage = [UIImage imageNamed:@"DC_selected-icon-praise.png"];
	selectedTalkImage = [UIImage imageNamed:@"DC_selected-icon-talk.png"];
	selectedUpdateImage = [UIImage imageNamed:@"DC_selected-icon-update.png"];
}

- (void)didFinishDownloadingArray:(NSArray *)array {
	[super didFinishDownloadingArray:array];
	[self calculateCachedFancyDatesWithArray:array];
}

- (void)calculateCachedFancyDatesWithArray:(NSArray *)array {
	[super calculateCachedFancyDatesWithArray:array];
	if (modelController.lastPage <= 1 || cachedFancyDatesCreated == nil) {
		// we're on at least the second page, so erase the cached dates
		[cachedFancyDatesCreated release];
		[cachedFancyDatesActivity release];
		cachedFancyDatesCreated = [[NSMutableArray alloc] initWithCapacity:0];
		cachedFancyDatesActivity = [[NSMutableArray alloc] initWithCapacity:0];
	}
	int i = 0;
	for (NSDictionary *item in array) {
		[cachedFancyDatesCreated addObject:[DCFancyDate relativeTextWithDate:[DCFancyDate dateFromString:[[array objectAtIndex:i] objectForKey:@"created_at"]] longVersion:NO]];
		[cachedFancyDatesActivity addObject:[DCFancyDate relativeTextWithDate:[DCFancyDate dateFromString:[[array objectAtIndex:i] objectForKey:@"last_active_at"]] longVersion:NO]];
		i++;
	}
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
	} else {
		// this is a regular row
		cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
		UILabel *subjectLabel;
		UILabel *countsLabel;
		UILabel *createdLabel;
		UILabel *activityLabel;
		UIImageView *iconImageView;
		UIImageView *selectedIconImageView;
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"cellID"] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
			subjectLabel = [[[UILabel alloc] initWithFrame:CGRectMake(9.0, 8.0, 279.0, 18.0)] autorelease];
		    subjectLabel.tag = kSubjectLabelTag;
		    subjectLabel.font = [UIFont boldSystemFontOfSize:14.0];
		    subjectLabel.textAlignment = UITextAlignmentLeft;
		    subjectLabel.textColor = [UIColor blackColor];
		    subjectLabel.highlightedTextColor = [UIColor whiteColor];
		    [cell.contentView addSubview:subjectLabel];

			countsLabel = [[[UILabel alloc] initWithFrame:CGRectMake(39.0, 27.0, 116.0, 16.0)] autorelease];
		    countsLabel.tag = kCountsLabelTag;
		    countsLabel.font = [UIFont systemFontOfSize:13.0];
		    countsLabel.textAlignment = UITextAlignmentLeft;
		    countsLabel.textColor = [UIColor grayColor];
		    countsLabel.highlightedTextColor = [UIColor whiteColor];
		    [cell.contentView addSubview:countsLabel];

			createdLabel = [[[UILabel alloc] initWithFrame:CGRectMake(39.0, 46.0, 240.0, 15.0)] autorelease];
		    createdLabel.tag = kCreatedLabelTag;
		    createdLabel.font = [UIFont systemFontOfSize:13.0];
		    createdLabel.textAlignment = UITextAlignmentLeft;
		    createdLabel.textColor = [UIColor grayColor];
		    createdLabel.highlightedTextColor = [UIColor whiteColor];
		    [cell.contentView addSubview:createdLabel];

			activityLabel = [[[UILabel alloc] initWithFrame:CGRectMake(150.0, 27.0, 140.0, 16.0)] autorelease];
		    activityLabel.tag = kActivityLabelTag;
		    activityLabel.font = [UIFont systemFontOfSize:13.0];
		    activityLabel.textAlignment = UITextAlignmentRight;
		    activityLabel.textColor = [UIColor colorWithRed:0.14 green:0.43 blue:0.85 alpha:1.0];
		    activityLabel.highlightedTextColor = [UIColor whiteColor];
		    [cell.contentView addSubview:activityLabel];

			cell.backgroundView = [[[UIView alloc] initWithFrame:cell.frame] autorelease];

			iconImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(9.0, 33.0, 24.0, 22.0)] autorelease];
			iconImageView.tag = kIconImageViewTag;
			iconImageView.backgroundColor = [UIColor whiteColor];
			[cell.backgroundView addSubview:iconImageView];

			selectedIconImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(9.0, 33.0, 24.0, 22.0)] autorelease];
			selectedIconImageView.tag = kIconImageViewTag;
			selectedIconImageView.backgroundColor = [UIColor clearColor];
			[cell.selectedBackgroundView addSubview:selectedIconImageView];
		} else {
			subjectLabel = (UILabel *)[cell.contentView viewWithTag:kSubjectLabelTag];
			countsLabel = (UILabel *)[cell.contentView viewWithTag:kCountsLabelTag];
			createdLabel = (UILabel *)[cell.contentView viewWithTag:kCreatedLabelTag];
			activityLabel = (UILabel *)[cell.contentView viewWithTag:kActivityLabelTag];
			iconImageView = (UIImageView *)[cell.backgroundView viewWithTag:kIconImageViewTag];
			selectedIconImageView = (UIImageView *)[cell.selectedBackgroundView viewWithTag:kIconImageViewTag];
		}

		subjectLabel.text = [[listContent objectAtIndex:indexPath.row] objectForKey:@"subject"];
		NSString *style = [[listContent objectAtIndex:indexPath.row] objectForKey:@"style"];
		BOOL showMeToo = YES;
		if ([style isEqualToString:@"idea"]) {
			iconImageView.image = ideaImage;
			selectedIconImageView.image = selectedIdeaImage;
		} else if ([style isEqualToString:@"question"]) {
			iconImageView.image = questionImage;
			selectedIconImageView.image = selectedQuestionImage;
		} else if ([style isEqualToString:@"problem"]) {
			iconImageView.image = problemImage;
			selectedIconImageView.image = selectedProblemImage;
		} else if ([style isEqualToString:@"praise"]) {
			iconImageView.image = praiseImage;
			selectedIconImageView.image = selectedPraiseImage;
			showMeToo = NO;
		} else if ([style isEqualToString:@"talk"]) {
			iconImageView.image = talkImage;
			selectedIconImageView.image = selectedTalkImage;
			showMeToo = NO;
		} else if ([style isEqualToString:@"update"]) {
			iconImageView.image = updateImage;
			selectedIconImageView.image = selectedUpdateImage;
			showMeToo = NO;
		} else {
			iconImageView.image = nil;
			selectedIconImageView.image = nil;
			showMeToo = NO;
		}
		if (showMeToo == NO) {
			countsLabel.text = [NSString stringWithFormat:@"%@ fol, %@ re",
				[[listContent objectAtIndex:indexPath.row] objectForKey:@"follower_count"],
				[[listContent objectAtIndex:indexPath.row] objectForKey:@"reply_count"],
				nil];
		} else {
			countsLabel.text = [NSString stringWithFormat:@"%@ mt, %@ fol, %@ re",
				[[listContent objectAtIndex:indexPath.row] objectForKey:@"me_too_count"],
				[[listContent objectAtIndex:indexPath.row] objectForKey:@"follower_count"],
				[[listContent objectAtIndex:indexPath.row] objectForKey:@"reply_count"],
				nil];
		}
		createdLabel.text = [NSString stringWithFormat:@"%@ by %@",
			[cachedFancyDatesCreated objectAtIndex:indexPath.row],
			[[[listContent objectAtIndex:indexPath.row] objectForKey:@"author"] objectForKey:@"name"],
			nil];
		activityLabel.text = [cachedFancyDatesActivity objectAtIndex:indexPath.row];
	}

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([super shouldContinueForTableView:tableView didSelectRowAtIndexPath:indexPath] == NO) {
		return;
	}

	DCTopicViewController *topicViewController = [[DCTopicViewController alloc] initWithNibName:@"DCTopicView" bundle:nil];
	topicViewController.navigationItem.title = [NSString stringWithFormat:@"%d Replies", [[[self.listContent objectAtIndex:indexPath.row] objectForKey:@"reply_count"] intValue]];
	topicViewController.topicDictionary = [self.listContent objectAtIndex:indexPath.row];
	[[self currentNavigationController] pushViewController:topicViewController animated:YES];
	[topicViewController release];
}

@end

