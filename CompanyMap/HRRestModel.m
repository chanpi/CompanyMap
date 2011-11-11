//
//  HRRestModel.m
//  CompanyMap
//
//  Created by  on 11/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HRRestModel.h"

@interface HRRestModel (PrivateMethods)
+ (void)setAttributeValue:(id) o forKey:(NSString*)key;
+ (NSMutableDictionary*)classAttributes;
+ (NSMutableDictionary*)mergedOptions:(NSDictionary*)options;
+ (NSOperation*)requestWithMethod:(HRRequestMethod)method path:(NSString*)path options:(NSDictionary*)options object:(id)object;
@end

@implementation HRRestModel

static NSMutableDictionary* attributes;

+ (void)initialize {
    if (!attributes) {
        attributes = [[NSMutableDictionary alloc] init];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Class Attributes

+ (NSMutableDictionary*)classAttributes
{
    NSString* className = NSStringFromClass([self class]);
    
    NSMutableDictionary* newDictionary;
    NSMutableDictionary* dictionary = [attributes objectForKey:className];
    
    if (dictionary) {
        return  dictionary;
    } else {
        newDictionary = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:HRDataFormatJSON] forKey:@"format"];
        [attributes setObject:newDictionary forKey:className];
    }
    return newDictionary;
}

+ (void)setAttributeValue:(id)addribute forKey:(NSString*)key
{
    [[self classAttributes] setObject:attributes forKey:key];
}

+ (NSObject*)delegate
{
    return [[self classAttributes] objectForKey:kHRClassAttributesDelegateKey];
}

+ (void)setDelegate:(NSObject*)delegate
{
    [self setAttributeValue:[NSValue valueWithNonretainedObject:delegate] forKey:kHRClassAttributesDelegateKey];
}

+ (NSURL*)baseURL
{
    return [[self classAttributes] objectForKey:kHRClassAttributesBaseURLKey];
}

+ (void)setBaseURL:(NSURL*)url
{
    [self setAttributeValue:url forKey:kHRClassAttributesBaseURLKey];
}

+ (NSDictionary*)headers
{
    return [[self classAttributes] objectForKey:kHRClassAttributesHeadersKey];
}

+ (void)setHeaders:(NSDictionary*)headers
{
    [self setAttributeValue:headers forKey:kHRClassAttributesHeadersKey];
}

+ (NSDictionary*)basicAuth
{
    return [[self classAttributes] objectForKey:kHRClassAttributesBasicAuthKey];
}

+ (void)setBasicAuthWithUsername:(NSString*)username password:(NSString*)password
{
    NSDictionary* authDictionary = [NSDictionary dictionaryWithObjectsAndKeys:username, kHRClassAttributesUsernameKey, password, kHRClassAttributesPasswordKey, nil];
    [self setAttributeValue:authDictionary forKey:kHRClassAttributesBasicAuthKey];
}

+ (NSDictionary*)defaultParams
{
    return [[self classAttributes] objectForKey:kHRClassAttributesDefaultParamsKey];
}

+ (void)setDefaultParams:(NSDictionary*)params
{
    [self setAttributeValue:params forKey:kHRClassAttributesDefaultParamsKey];
}

+ (HRDataFormat)format
{
    return [[[self classAttributes] objectForKey:kHRClassAttributesFormatKey] intValue];
}

+ (void)setFormat:(HRDataFormat)format
{
    [[self classAttributes] setValue:[NSNumber numberWithInt:format] forKey:kHRClassAttributesFormatKey];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - REST Methods

+ (NSOperation *)getPath:(NSString *)path withOptions:(NSDictionary *)options object:(id)object
{
    return [self requestWithMethod:HRRequestMethodGet path:path options:options object:object];
}

+ (NSOperation *)postPath:(NSString *)path withOptions:(NSDictionary *)options object:(id)object
{
    return [self requestWithMethod:HRRequestMethodPost path:path options:options object:object];
}

+ (NSOperation *)putPath:(NSString *)path withOptions:(NSDictionary *)options object:(id)object
{
    return [self requestWithMethod:HRRequestMethodPut path:path options:options object:object];
}

+ (NSOperation *)deletePath:(NSString *)path withOptions:(NSDictionary *)options object:(id)object
{
    return [self requestWithMethod:HRRequestMethodDelete path:path options:options object:object];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

+ (NSOperation*)requestWithMethod:(HRRequestMethod)method path:(NSString*)path options:(NSDictionary*)options object:(id)object
{
    NSMutableDictionary* opts = [self mergedOptions:options];
    return [HRReq];
}

+ (NSMutableDictionary*)mergedOptions:(NSDictionary*)options
{
    NSMutableDictionary* defaultParams = [NSMutableDictionary dictionaryWithDictionary:[self defaultParams]];
    [defaultParams addEntriesFromDictionary:[options valueForKey:kHRClassAttributesParamsKey]];
    
    options = [NSMutableDictionary dictionaryWithDictionary:options];
    [(NSMutableDictionary*)options setObject:defaultParams forKey:kHRClassAttributesParamsKey];
    NSMutableDictionary* opts = [NSMutableDictionary dictionaryWithDictionary:[self classAttributes]];
    [opts addEntriesFromDictionary:options];
    [opts removeObjectForKey:kHRClassAttributesDefaultParamsKey];
    
    return opts;
}

@end
