//
//  SBJSON.m
//  CompanyMap
//
//  Created by happy . on 11/11/14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "SBJSON.h"

@implementation SBJSON

- (id)init
{
    self = [super init];
    if (self) {
        jsonParser_ = [SBJsonParser new];
        jsonWriter_ = [SBJsonWriter new];
        [self setMaxDepth:512];
    }
    return self;
}

- (void)dealloc
{
    //[jsonParser_ release];
    //[jsonWriter_ release];
    jsonParser_ = nil;
    jsonWriter_ = nil;
    //[super dealloc];
}

#pragma mark Writer

- (NSString*)stringWithObject:(id)value
{
    NSString* repr = [jsonWriter_ stringWithObject:value];
    if (repr) {
        return repr;
    }
    
    //[errorTrace_ release];
    errorTrace_ = [[jsonWriter_ errorTrace] mutableCopy];
    return nil;
}

/**
 Returns a string containing JSON representation of the passed in value, or nil on error.
 If nil is returned and @p error is not NULL, @p *error can be interrogated to find the cause of the error.
 
 @param value any instance that can be represented as a JSON fragment
 @param allowScalar wether to return json fragments for scalar objects
 @param error used to return an error by reference (pass NULL if this is not desired)
 
 @deprecated Given we bill ourselves as a "strict" JSON library, this method should be removed.
 */
- (NSString*)stringWithObject:(id)value
                  allowScalar:(BOOL)allowScalar
                        error:(NSError**)error
{
    NSString* json = allowScalar ? [jsonWriter_ stringWithFragment:value] : [jsonWriter_ stringWithObject:value];
    if (json) {
        return json;
    }
    
    //[errorTrace_ release];
    errorTrace_ = [[jsonWriter_ errorTrace] mutableCopy];
    
    if (error) {
        *error = [errorTrace_ lastObject];
    }
    return nil;
}

/**
 Returns a string containing JSON representation of the passed in value, or nil on error.
 If nil is returned and @p error is not NULL, @p error can be interrogated to find the cause of the error.
 
 @param value any instance that can be represented as a JSON fragment
 @param error used to return an error by reference (pass NULL if this is not desired)
 
 @deprecated Given we bill ourselves as a "strict" JSON library, this method should be removed.
 */
- (NSString*)stringWithFragment:(id)value
                          error:(NSError**)error
{
    return [self stringWithObject:value
                      allowScalar:YES
                            error:error];
}

/**
 Returns a string containing JSON representation of the passed in value, or nil on error.
 If nil is returned and @p error is not NULL, @p error can be interrogated to find the cause of the error.
 
 @param value a NSDictionary or NSArray instance
 @param error used to return an error by reference (pass NULL if this is not desired)
 */
- (NSString*)stringWithObject:(id)value
                        error:(NSError**)error
{
    return [self stringWithObject:value
                      allowScalar:NO
                            error:error];
}

#pragma mark Parsing

- (id)objectWithString:(NSString *)repr
{
    id object = [jsonParser_ objectWithString:repr];
    if (object) {
        return object;
    }
    
    //[errorTrace_ release];
    errorTrace_ = [[jsonParser_ errorTrace] mutableCopy];
    
    return nil;
}

/**
 Returns the object represented by the passed-in string or nil on error. The returned object can be
 a string, number, boolean, null, array or dictionary.
 
 @param value the json string to parse
 @param allowScalar whether to return objects for JSON fragments
 @param error used to return an error by reference (pass NULL if this is not desired)
 
 @deprecated Given we bill ourselves as a "strict" JSON library, this method should be removed.
 */
- (id)objectWithString:(id)value
           allowScalar:(BOOL)allowScalar
                 error:(NSError**)error
{
    id object = allowScalar ? [jsonParser_ fragmentWithString:value] : [jsonParser_ objectWithString:value];
    if (object) {
        return object;
    }
    
    //[errorTrace_ release];
    errorTrace_ = [[jsonParser_ errorTrace] mutableCopy];
    
    if (error) {
        *error = [errorTrace_ lastObject];
    }
    return nil;
}

/**
 Returns the object represented by the passed-in string or nil on error. The returned object can be
 a string, number, boolean, null, array or dictionary.
 
 @param jsonrepr the json string to parse
 @param error used to return an error by reference (pass NULL if this is not desired)
 
 @deprecated Given we bill ourselves as a "strict" JSON library, this method should be removed. 
 */
- (id)fragmentWithString:(NSString*)jsonrepr
                   error:(NSError**)error
{
    return [self objectWithString:jsonrepr
                      allowScalar:YES
                            error:error];
}

/**
 Returns the object represented by the passed-in string or nil on error. The returned object
 will be either a dictionary or an array.
 
 @param jsonrepr the json string to parse
 @param error used to return an error by reference (pass NULL if this is not desired)
 */
- (id)objectWithString:(NSString*)jsonrepr
                 error:(NSError**)error
{
    return [self objectWithString:jsonrepr
                      allowScalar:NO
                            error:error];
}

#pragma mark Properties - parsing

- (NSUInteger)maxDepth
{
    return jsonParser_.maxDepth;
}

- (void)setMaxDepth:(NSUInteger)maxDepth
{
    jsonWriter_.maxDepth = jsonParser_.maxDepth = maxDepth;
}

#pragma mark Properties - writing

- (BOOL)humanReadable
{
    return jsonWriter_.humanReadable;
}

- (void)setHumanReadable:(BOOL)humanReadable
{
    jsonWriter_.humanReadable = humanReadable;
}

- (BOOL)sortKeys
{
    return jsonWriter_.sortKeys;
}

- (void)setSortKeys:(BOOL)sortKeys
{
    jsonWriter_.sortKeys = sortKeys;
}

@end
