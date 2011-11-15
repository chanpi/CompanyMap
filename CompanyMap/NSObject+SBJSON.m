//
//  NSObject+SBJSON.m
//  CompanyMap
//
//  Created by happy . on 11/11/15.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "NSObject+SBJSON.h"
#import "SBJsonWriter.h"

@implementation NSObject (SBJSON)

- (NSString*)JSONFragment
{
    SBJsonWriter* jsonWriter = [SBJsonWriter new];
    NSString* json = [jsonWriter stringWithFragment:self];
    if (!json) {
        NSLog(@"-JSONFragment failed. Error trace is: %@", [jsonWriter errorTrace]);
    }
    //[jsonWriter release];
    return json;
}

- (NSString*)JSONRepresentation
{
    SBJsonWriter* jsonWriter = [SBJsonWriter new];
    NSString* json = [jsonWriter stringWithObject:self];
    if (!json) {
        NSLog(@"-JSONRepresentation failed. Error trace is: %@", [jsonWriter errorTrace]);
    }
    //[jsonWriter release];
    return json;
}

@end
