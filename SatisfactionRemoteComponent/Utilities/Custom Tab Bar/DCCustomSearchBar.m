//
//  DCCustomSearchBar.m
//  satsat
//
//  Created by David on 2/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DCCustomSearchBar.h"

@implementation DCCustomSearchBar

@synthesize backgroundImage;
@synthesize subBackgroundImage;
@synthesize useSubStyle;

- (void)awakeFromNib {
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 39);
	backgroundImage = [UIImage imageNamed:@"DC_search-bar-background.png"];
	subBackgroundImage = [UIImage imageNamed:@"DC_sub-search-bar-background.png"];
	useSubStyle = NO;

	backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
	backgroundImageView.image = backgroundImage;
	backgroundImageView.contentMode = UIViewContentModeScaleToFill;
	if ([[self subviews] count] == 2) {
		[self insertSubview:backgroundImageView atIndex:1];
	} else {
		[self insertSubview:backgroundImageView atIndex:0];
	}
}

- (void)layoutSubviews {
	if (useSubStyle == YES) {
		backgroundImageView.image = subBackgroundImage;
	} else {
		backgroundImageView.image = backgroundImage;
	}
	[super layoutSubviews];
}

- (void)setUseSubStyle:(BOOL)yesNo {
	useSubStyle = yesNo;
	[self setNeedsDisplay];
}

- (void)dealloc {
    [super dealloc];
}

@end
