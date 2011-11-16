//
//  PhotoFormatter.m
//  CompanyMap
//
//  Created by  on 11/11/16.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PhotoFormatter.h"
#import "JSON.h"

@implementation PhotoFormatter
+ (NSString*)extension
{
    return @"*";
}

+ (NSString*)mimeType
{
    return @"multipart/form-data; boundary=0xKhTmLbOuNdArY";
}

+ (id)decode:(NSData *)data error:(NSError *__autoreleasing *)error
{
    NSString* rawString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (rawString == nil && ([data length] > 0)) {
        rawString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    }
    
    NSError* parseError = nil;
    SBJSON* parser = [[SBJSON alloc] init];
    id results = [parser objectWithString:rawString error:&parseError];
    //[parser release];
    //[rawString release];
    
    if (parseError && !results) {
        if (error != nil) {
            *error = parseError;
        }
        return nil;
    }
    return results;
}

+ (NSString*)encode:(id)object error:(NSError *__autoreleasing *)error
{
    return [object JSONRepresentation];
}

@end
