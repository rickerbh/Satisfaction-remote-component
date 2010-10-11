//
//  DCImageUploader.m
//  satsat
//
//  Created by David on 2/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DCImageUploader.h"

@implementation DCImageUploader

- (void)uploadImage:(UIImage *)theImage delegate:(id)theDelegate {
	delegate = theDelegate;

	NSURL *url = [NSURL URLWithString:@"http://getsatisfaction.com/inline_images/create"];
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url
		cachePolicy:NSURLRequestReloadIgnoringCacheData
		timeoutInterval:10.0
	];

 	NSData *imageData = UIImageJPEGRepresentation(theImage, 0.75);
	[theRequest setHTTPMethod:@"POST"];

	//Add the header info
	NSString *stringBoundary = [NSString stringWithString:@"0xUhfyTfsFNjqOpaM"];
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",stringBoundary];
	[theRequest addValue:contentType forHTTPHeaderField:@"Content-Type"];

	//create the body
	NSMutableData *postBody = [NSMutableData data];
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];

	//add data field and file data
	[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"image[uploaded_data]\"; filename=\"image.png\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Type: image/png\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[NSData dataWithData:imageData]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[theRequest setHTTPBody:postBody];

	theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (theConnection) {
		receivedData = [[NSMutableData data] retain];
	} else {
		NSLog(@"Error: The download could not be started.");
		[self callbackToDelegateWithString:@"error"];
	}
}

- (void)cancel {
	if (theConnection != nil) {
		[theConnection cancel];
	}
}

- (void)callbackToDelegateWithString:(NSString *)theString {
	if ([delegate respondsToSelector:@selector(imageUploadDidFinishWithResponseString:)] == YES) {
		[delegate performSelector:@selector(imageUploadDidFinishWithResponseString:) withObject:theString];
	}
}


#pragma mark NSURLConnection Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	expectedContentLength = [response expectedContentLength];
	// this method is called when the server has determined that it
	// has enough information to create the NSURLResponse
	// it can be called multiple times, for example in the case of a
	// redirect, so each time we reset the data.
	// receivedData is declared as a method instance elsewhere
	[receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[receivedData appendData:data];
	if ([delegate respondsToSelector:@selector(imageUploadDidUpdateProgress:)] == YES) {
		float progress = [receivedData length] / expectedContentLength;
		[delegate performSelector:@selector(imageUploadDidUpdateProgress:) withObject:[NSNumber numberWithFloat:progress]];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	//[connection release];
	[receivedData release];
	NSLog(@"Connection failed! Error - %@ %@",
		[error localizedDescription],
		[[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
	[self callbackToDelegateWithString:@"error"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if (receivedData != nil) {
		[self callbackToDelegateWithString:[[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding]];
	} else {
		NSLog(@"error downloading data from url");
		[self callbackToDelegateWithString:@"error"];
	}
	//[connection release];
	[receivedData release];
}


@end
