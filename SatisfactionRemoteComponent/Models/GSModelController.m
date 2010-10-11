//
//  GSModelController.m
//  satsat
//
//  Created by David on 2/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GSModelController.h"

@implementation GSModelController

@synthesize delegate;
@synthesize URLString;
@synthesize didLoad;
@synthesize perPage;
@synthesize lastPage;
@synthesize nextPageExists;

- (id)init {
	if (self = [super init]) {
		perPage = 30;
		lastPage = 0;
		nextPageExists = YES;
	}
	return self;
}

- (void)dealloc {
	[theConnection release];
	[super dealloc];
}

#pragma mark NSURLConnection Methods

- (void)startConnectionWithURL:(NSURL *)url {
	if (url == nil) {
		NSLog(@"Error: url was not set.");
		[self callBackToTarget];
		return;
	}
	self.didLoad = NO;
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url
		cachePolicy:NSURLRequestReloadIgnoringCacheData
		timeoutInterval:10.0
	];
	//[theRequest setValue:@"text/x-json" forHTTPHeaderField:@"Accept"];
	[theConnection release];
	theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	isLoading = YES;
	if (theConnection) {
		receivedData = [[NSMutableData data] retain];
	} else {
		NSLog(@"Error: The download could not be started.");
		[self callBackToTarget];
	}
}

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
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	//[connection release];
	isLoading = NO;
	[receivedData release];
	NSLog(@"Connection failed! Error - %@ %@",
		  [error localizedDescription],
		  [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
	[self callBackToTarget];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	if (receivedData != nil) {
		[self processData:receivedData];
	} else {
		NSLog(@"error downloading data from url");
		[self callBackToTarget];
	}
	//[connection release];
	isLoading = NO;
	self.didLoad = YES;
	[receivedData release];
}


#pragma mark Custom Methods

- (void)findAll {
	if (self.didLoad == YES) {
		return;
	}
	[self cancel];
	[self startConnectionWithURL:[NSURL URLWithString:[self pagedURLString:self.URLString]]];
	if ([self.delegate respondsToSelector:@selector(startLoading)] == YES) {
		[self.delegate performSelector:@selector(startLoading)];
	}
}

- (void)findAllNextPage {
	[self cancel];
	[self startConnectionWithURL:[NSURL URLWithString:[self pagedURLString:self.URLString]]];
}

- (void)findByQuery:(NSString *)q {
	self.lastPage = 0;
	[self cancel];
	NSString *qProcessed = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)q, NULL, NULL, kCFStringEncodingUTF8);
	if ([self URLStringWithQuery:qProcessed] == nil) {
		NSLog(@"no url set for findByQuery");
		[self callBackToTargetWithArray:[NSArray array]];
		return;
	}
	[self startConnectionWithURL:[NSURL URLWithString:[self pagedURLString:[self URLStringWithQuery:qProcessed]]]];
	if ([self.delegate respondsToSelector:@selector(startLoading)] == YES) {
		[self.delegate performSelector:@selector(startLoading)];
	}
}

- (void)findByQueryNextPage:(NSString *)q {
	[self cancel];
	NSString *qProcessed = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)q, NULL, NULL, kCFStringEncodingUTF8);
	[self startConnectionWithURL:[NSURL URLWithString:[self pagedURLString:[self URLStringWithQuery:qProcessed]]]];
}

- (NSString *)URLStringWithQuery:(NSString *)q {
	return [NSString stringWithFormat:@"%@&q=%@", self.URLString, q];
}

- (NSString *)pagedURLString:(NSString *)string {
	lastPage++;
	return [string stringByReplacingOccurrencesOfString:@"::paging::" withString:[NSString stringWithFormat:@"&page=%d&limit=%d", lastPage, perPage]];
}

- (void)processData:(NSData *)data {
	if (!data) {
		NSLog(@"Error retrieving xml.");
		[self callBackToTarget];
		return;
	}

	NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSDictionary *dictionary = [GSModelController dictionaryFromJSON:string];
	if ([dictionary objectForKey:@"data"] != nil) {
		NSArray *array = [dictionary objectForKey:@"data"];

		int total = [[dictionary objectForKey:@"total"] intValue];
		if (lastPage * perPage < total) {
			nextPageExists = YES;
		} else {
			nextPageExists = NO;
		}

		[self callBackToTargetWithArray:array];
	} else {
		[self callBackToTargetWithDictionary:dictionary];
	}
	[string release];
}

- (void)cancel {
	if (isLoading == YES) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		if ([theConnection respondsToSelector:@selector(cancel)] == YES) {
			[theConnection cancel];
			//[theConnection release];
		}
	}
}

- (void)callBackToTarget {
	[self callBackToTargetWithArray:nil];
}

- (void)callBackToTargetWithArray:(NSArray *)array {
	if (delegate != nil) {
		if ([delegate respondsToSelector:@selector(didFinishDownloadingArray:)] == YES) {
			[delegate performSelector:@selector(didFinishDownloadingArray:) withObject:array];
		}
	}
}

- (void)callBackToTargetWithDictionary:(NSDictionary *)dictionary {
	if (delegate != nil) {
		if ([delegate respondsToSelector:@selector(didFinishDownloadingDictionary:)] == YES) {
			[delegate performSelector:@selector(didFinishDownloadingDictionary:) withObject:dictionary];
		}
	}
}

+ (NSDictionary *)dictionaryFromJSON:(NSString *)jsonString {
	NSData *jsonData = [jsonString dataUsingEncoding:NSUTF32BigEndianStringEncoding];
	return [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:nil];
}

@end
