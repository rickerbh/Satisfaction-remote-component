//
//  GSModelController.h
//  satsat
//
//  Created by David on 2/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SatisfactionRemoteComponentConstants.h"
#import "CJSONDeserializer.h"

@interface GSModelController : NSObject {
	id delegate;

	// for NSURLConnection methods
	NSMutableData *receivedData;
	float expectedContentLength;
	NSURLConnection *theConnection;
	BOOL isLoading;
	BOOL didLoad;
	NSString *URLString;

	int perPage;
	int lastPage;
	BOOL nextPageExists;
}

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) NSString *URLString;
@property (nonatomic) BOOL didLoad;
@property (nonatomic) int perPage;
@property (nonatomic) int lastPage;
@property (nonatomic) BOOL nextPageExists;

- (void)startConnectionWithURL:(NSURL *)url;
- (void)processData:(NSData *)data;
- (void)findAll;
- (void)findByQuery:(NSString *)q;
- (NSString *)URLStringWithQuery:(NSString *)q;
- (NSString *)pagedURLString:(NSString *)string;
- (void)cancel;
- (void)callBackToTarget;
- (void)callBackToTargetWithArray:(NSArray *)array;
- (void)callBackToTargetWithDictionary:(NSDictionary *)dictionary;
+ (NSDictionary *)dictionaryFromJSON:(NSString *)jsonString;
- (void)findAllNextPage;
- (void)findByQueryNextPage:(NSString *)q;

@end
