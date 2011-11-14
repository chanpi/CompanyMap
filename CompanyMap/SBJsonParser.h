//
//  SBJsonParser.h
//  CompanyMap
//
//  Created by  on 11/11/14.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBJsonBase.h"

@protocol SBJsonParser

/**
 @brief Return the object represented by the given string.
 
 Returns the object represented by the passed-in string or nil on error. The returned object can be
 a string, number, boolean, null, array or dictionary.
 
 @param repr the json string to parse
 */
- (id)objectWithString:(NSString*)repr;

@end

/**
 @brief The JSON parser class.
 
 JSON is mapped to Objective-C types in the following way:
 
 @li Null -> NSNull
 @li String -> NSMutableString
 @li Array -> NSMutableArray
 @li Object -> NSMutableDictionary
 @li Boolean -> NSNumber (initialised with -initWithBool:)
 @li Number -> NSDecimalNumber
 
 Since Objective-C doesn't have a dedicated class for boolean values, these turns into NSNumber
 instances. These are initialised with the -initWithBool: method, and 
 round-trip back to JSON properly. (They won't silently suddenly become 0 or 1; they'll be
 represented as 'true' and 'false' again.)
 
 JSON numbers turn into NSDecimalNumber instances,
 as we can thus avoid any loss of precision. (JSON allows ridiculously large numbers.)
 
 */
@interface SBJsonParser : SBJsonBase<SBJsonParser> {

@private
    const char* c_;
}

@end

// don't use - exists for backwards compatibility with 2.1.x only. Will be removed in 2.3.
@interface SBJsonParser (Private)
- (id)fragmentWithString:(id)repr;
@end