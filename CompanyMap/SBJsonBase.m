//
//  SBJsonBase.m
//  CompanyMap
//
//  Created by  on 11/11/14.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBJsonBase.h"

NSString* SBJSONErrorDomain = @"org.brautaset.JSON.ErrorDomain";
NSString* kSBErrorTrace = @"errorTrace";

@implementation SBJsonBase

@synthesize errorTrace = errorTrace_;
@synthesize maxDepth = maxDepth_;

- (id)init
{
    self = [super init];
    if (self) {
        self.maxDepth = 512;
    }
    return self;
}

/*
- (void)dealloc
{
    //[errorTrace_ release];
    //[super dealloc];
}
*/

- (void)addErrorWithCode:(NSInteger)code description:(NSString *)string
{
    NSDictionary* userInfo;
    if (!errorTrace_) {
        errorTrace_ = [NSMutableArray new];
        userInfo = [NSDictionary dictionaryWithObject:string forKey:NSLocalizedDescriptionKey];
        
    } else {
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                    string, NSLocalizedDescriptionKey,
                    [errorTrace_ lastObject], NSUnderlyingErrorKey,
                    nil];
    }
    
    NSError* error = [NSError errorWithDomain:SBJSONErrorDomain code:code userInfo:userInfo];
    
    [self willChangeValueForKey:kSBErrorTrace];
    [errorTrace_ addObject:error];
    [self didChangeValueForKey:kSBErrorTrace];
}

- (void)clearErrorTrace
{
    [self willChangeValueForKey:kSBErrorTrace];
    //[errorTrace_ release];
    errorTrace_ = nil;
    [self didChangeValueForKey:kSBErrorTrace];
}

@end
