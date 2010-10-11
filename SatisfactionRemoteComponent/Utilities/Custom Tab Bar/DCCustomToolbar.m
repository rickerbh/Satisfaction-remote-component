//
//  DCCustomToolbar.m
//  TabBarTest1
//
//  Created by David on 2/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DCCustomToolbar.h"

@implementation DCCustomToolbar

@synthesize backgroundImage;

- (void)awakeFromNib {
	backgroundImage = [UIImage imageNamed:@"DC_blue-tab-bar-background.png"];
}

- (void)drawRect:(CGRect)rect {
	[backgroundImage drawInRect:rect];
}

- (void)dealloc {
    [super dealloc];
}

@end
