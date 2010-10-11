//
//  DCOAuthParams.h
//  SRCExample1
//
//  Created by David on 2/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DCOAuthParams : NSObject {
	NSString *key;
	NSString *secret;
}

@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *secret;

+ (DCOAuthParams *)sharedParams;

@end
