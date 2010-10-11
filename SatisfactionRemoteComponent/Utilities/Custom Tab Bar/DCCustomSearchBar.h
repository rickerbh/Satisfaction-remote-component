//
//  DCCustomSearchBar.h
//  satsat
//
//  Created by David on 2/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SatisfactionRemoteComponentConstants.h"


@interface DCCustomSearchBar : UISearchBar {
	UIImage *backgroundImage;
	UIImage *subBackgroundImage;
	BOOL useSubStyle;
	UIImageView *backgroundImageView;
}

@property (nonatomic, retain) UIImage *backgroundImage;
@property (nonatomic, retain) UIImage *subBackgroundImage;
@property (nonatomic) BOOL useSubStyle;

@end
