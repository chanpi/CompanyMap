//
//  SBJSON.h
//  CompanyMap
//
//  Created by happy . on 11/11/14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "SBJsonBase.h"
#import "SBJsonParser.h"
#import "SBJsonWriter.h"

/**
 @brief Facade(表層) for SBJsonWriter/SBJsonParser.
 
 Requests are forwarded to instances of SBJsonWriter and SBJsonParser.
 */
@interface SBJSON : SBJsonBase <SBJsonParser, SBJsonWriter> {
@private
    SBJsonParser* jsonParser_;
    SBJsonWriter* jsonWriter_;
}

/// Return the fragment represented by the given string
- (id)fragmentWithString:(NSString*)jsonrepr
                   error:(NSError**)error;

/// Return the object represented by the given string
- (id)objectWithString:(NSString*)jsonrepr
                 error:(NSError**)error;

/// Parse the string and return the represented object (or scalar)
- (id)objectWithString:(id)value
           allowScalar:(BOOL)allowScalar
                 error:(NSError**)error;

/// Return JSON representation of an array  or dictionary
- (NSString*)stringWithObject:(id)value
                        error:(NSError**)error;

/// Return JSON representation of any legal JSON value
- (NSString*)stringWithFragment:(id)value
                          error:(NSError**)error;

/// Return JSON representation (or fragment) for the given object
- (NSString*)stringWithObject:(id)value
                  allowScalar:(BOOL)allowScalar
                        error:(NSError**)error;

@end
