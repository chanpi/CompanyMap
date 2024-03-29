//
//  NSString+SBJSON.h
//  CompanyMap
//
//  Created by happy . on 11/11/15.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @brief Adds JSON parsing methods to NSString
 
 This is a category on NSString that adds methods for parsing the target string.
 */
@interface NSString (SBJSON)

/**
 @brief Returns the object represented in the receiver, or nil on error. 
 
 Returns a a scalar object represented by the string's JSON fragment representation.
 
 @deprecated Given we bill ourselves as a "strict" JSON library, this method should be removed.
 */
- (id)JSONFragmentValue;

/**
 @brief Returns the NSDictionary or NSArray represented by the current string's JSON representation.
 
 Returns the dictionary or array represented in the receiver, or nil on error.
 
 Returns the NSDictionary or NSArray represented by the current string's JSON representation.
 */
- (id)JSONValue;

@end
