//
//  NSString+EscapingUtils.m
//  CompanyMap
//
//  Created by  on 11/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NSString+EscapingUtils.h"

@implementation NSString (EscapingUtils)

- (NSString*)stringByPreparingForURL
{
    NSString* escapedString = (__bridge_transfer NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                          (__bridge_retained CFStringRef)self,
                                                                                          NULL,
                                                                                          (CFStringRef)@":/?=,!$&'()*+;[]@#",
                                                                                          CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    //return [escapedString autorelease];
    return escapedString;
}

@end
