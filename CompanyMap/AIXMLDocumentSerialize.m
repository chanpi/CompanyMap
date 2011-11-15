//
//  AIXMLDocumentSerialize.m
//  CompanyMap
//
//  Created by happy . on 11/11/15.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "AIXMLDocumentSerialize.h"
#import "AIXMLElementSerialize.h"

@implementation NSXMLDocument (Serialize)

/**
 * Convert NSXMLDocument to an NSDictionary
 * @see NSXMLElement#toDictionary
 */
- (NSMutableDictionary*)toDictionary
{
    return [[self rootElement] toDictionary];
}

@end
