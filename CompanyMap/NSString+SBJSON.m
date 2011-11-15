//
//  NSString+SBJSON.m
//  CompanyMap
//
//  Created by happy . on 11/11/15.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "NSString+SBJSON.h"
#import "SBJsonParser.h"

@implementation NSString (SBJSON)

- (id)JSONFragmentValue
{
    SBJsonParser* jsonParser = [SBJsonParser new];
    id repr = [jsonParser fragmentWithString:self];
    if (!repr) {
        NSLog(@"-JSONFragmentValue failed. Error trace is: %@", [jsonParser errorTrace]);
    }
    //[jsonParser release];
    return repr;
}

- (id)JSONValue
{
    SBJsonParser* jsonParser = [SBJsonParser new];
    id repr = [jsonParser objectWithString:self];
    if (!repr) {
        NSLog(@"-JSONValue failed. Error trace is: %@", [jsonParser errorTrace]);
    }
    //[jsonParser release];
    return repr;
}

@end
