//
//  DCImageUploader.h
//  satsat
//
//  Created by David on 2/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCImageUploader : NSObject {
	id delegate;

	// for NSURLConnection methods
	NSMutableData *receivedData;
	float expectedContentLength;
	NSURLConnection *theConnection;
}

- (void)uploadImage:(UIImage *)theImage delegate:(id)theDelegate;
- (void)callbackToDelegateWithString:(NSString *)theString;
- (void)cancel;

@end
