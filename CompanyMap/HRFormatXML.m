//
//  HRFormatXML.m
//  CompanyMap
//
//  Created by happy . on 11/11/15.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "HRFormatXML.h"
#import "AIXMLSerialization.h"

@implementation HRFormatXML

+ (NSString*)extension
{
    return @"xml";
}

+ (NSString*)mimeType
{
    return @"application/xml";
}

+ (id)decode:(NSData *)data error:(NSError *__autoreleasing *)error
{
    NSError* parseError = nil;
    NSXMLDocument* document = [[NSXMLDocument alloc] initWithData:data options:NSXMLDocumentTidyXML error:&parseError];
    
    if (parseError != nil) {
        if (error != nil) {
            *error = parseError;
            return nil;
        }
    }
    
    return [document toDictionary];
}

+ (NSString*)encode:(id)object error:(NSError *__autoreleasing *)error
{
    NSAssert(YES, @"XML Encoding is not supported. Currently accepting patches");
    return nil;
}

@end
