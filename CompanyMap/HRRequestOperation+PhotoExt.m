//
//  HRRequestOperation+PhotoExt.m
//  CompanyMap
//
//  Created by  on 11/11/16.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HRRequestOperation+PhotoExt.h"
#import "HRFormatJSON.h"
#import "HRFormatXML.h"
#import "PhotoFormatter.h"

@implementation HRRequestOperation (PhotoFormatter)

- (id)formatterFromFormat
{
    NSNumber* format = [[self options] objectForKey:kHRClassAttributesFormatKey];
    id theFormatter = nil;
    switch ([format intValue]) {
        case HRDataFormatJSON:
            theFormatter = [HRFormatJSON class];
            break;
        case HRDataFormatXML:
            theFormatter = [HRFormatXML class];
            break;
        default:
            theFormatter = [PhotoFormatter class];
            break;
    }
    
    NSString* errorMessage = [NSString stringWithFormat:@"Invalid Formatter %@", NSStringFromClass(theFormatter)];
    NSAssert([theFormatter conformsToProtocol:@protocol(HRFormatterProtocol)], errorMessage);
    
    return theFormatter;
}

@end
