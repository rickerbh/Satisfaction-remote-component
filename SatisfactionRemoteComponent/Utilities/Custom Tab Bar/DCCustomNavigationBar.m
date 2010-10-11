//
//  DCCustomNavigationBar.m
//  NavBarTest1
//
//  Created by David on 2/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DCCustomNavigationBar.h"


@implementation DCCustomNavigationBar


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];

	self.tintColor = [UIColor colorWithRed:0.24 green:0.29 blue:0.32 alpha:0.0];

	UIImageView *topLeftCornerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DC_blue-nav-corner-top-left.png"]];
	topLeftCornerImageView.frame = CGRectMake(0, 0, topLeftCornerImageView.frame.size.width, topLeftCornerImageView.frame.size.height);
	[self addSubview:topLeftCornerImageView];

	UIImageView *topRightCornerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DC_blue-nav-corner-top-right.png"]];
	topRightCornerImageView.frame = CGRectMake(self.frame.size.width - topRightCornerImageView.frame.size.width, 0, topLeftCornerImageView.frame.size.width, topLeftCornerImageView.frame.size.height);
	[self addSubview:topRightCornerImageView];

	backgroundImage = [UIImage imageNamed:@"DC_blue-nav-background.png"];
}

- (void)layoutSubviews {
	[super layoutSubviews];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
	[backgroundImage drawInRect:rect];
}

- (void)dealloc {
    [super dealloc];
}

@end
