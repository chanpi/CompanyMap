//
//  HRFormatJSON.m
//  CompanyMap
//
//  Created by  on 11/11/12.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HRFormatJSON.h"

@implementation HRFormatJSON

+ (NSString*)extension
{
    return @"json";
}

+ (NSString*)mimeType
{
    return @"application/json";
}

+ (id)decode:(NSData*)data error:(NSError*)error
{
    NSString* rawString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    // UTF8でのデコードに失敗したらASCIIでデコードする
    if (rawString == nil && [data length] > 0) {
        rawString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    }
    
    NSError* parseError = nil;
    SBJSON* parser = [[SBJSON alloc] init];
}

+ (NSString*)encode:(id)object error:(NSError*)error
{
}

@end
