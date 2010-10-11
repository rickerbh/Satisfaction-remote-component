//
//  DCOAuthParams.m
//  SRCExample1
//
//  Created by David on 2/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DCOAuthParams.h"

@implementation DCOAuthParams

static DCOAuthParams *sharedOAuthParams = nil;

@synthesize key;
@synthesize secret;
 
+ (DCOAuthParams *)sharedParams {
    @synchronized(self) {
        if (sharedOAuthParams == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedOAuthParams;
}
 
+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedOAuthParams == nil) {
            sharedOAuthParams = [super allocWithZone:zone];
            return sharedOAuthParams;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}
 
- (id)copyWithZone:(NSZone *)zone {
    return self;
}
 
- (id)retain {
    return self;
}
 
- (unsigned)retainCount {
    return UINT_MAX;  //denotes an object that cannot be released
}
 
- (void)release {
    //do nothing
}
 
- (id)autorelease {
    return self;
}

@end
