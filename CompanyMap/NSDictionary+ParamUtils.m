//
//  NSDictionary+ParamUtils.m
//  CompanyMap
//
//  Created by  on 11/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NSDictionary+ParamUtils.h"
#import "NSString+EscapingUtils.h"

@implementation NSDictionary (ParamUtils)

- (NSString*)toQueryString
{
    NSMutableArray* pairs = [[NSMutableArray alloc] init];
    for (id key in [self allKeys]) {
        id value = [self objectForKey:key];
        if ([value isKindOfClass:[NSArray class]]) {
            for (id val in value) {
                [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [val stringByPreparingForURL]]];
            }
        } else {
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [value stringByPreparingForURL]]];
        }
    }
    return [pairs componentsJoinedByString:@"&"];
}

@end
