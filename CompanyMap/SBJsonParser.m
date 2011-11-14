//
//  SBJsonParser.m
//  CompanyMap
//
//  Created by  on 11/11/14.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBJsonParser.h"

@interface SBJsonParser (PrivateMethod)

- (BOOL)scanValue:(NSObject**)o;

- (BOOL)scanRestOfArray:(NSMutableArray**)o;
- (BOOL)scanRestOfDictionary:(NSMutableDictionary**)o;
- (BOOL)scanRestOfNull:(NSNull**)o;
- (BOOL)scanRestOfFalse:(NSNumber**)o;
- (BOOL)scanRestOfTrue:(NSNumber**)o;
- (BOOL)scanRestOfString:(NSMutableString**)o;

- (BOOL)scanNumber:(NSNumber**)o;

- (BOOL)scanHexQuad:(unichar*)x;
- (BOOL)scanUnicodeChar:(unichar*)x;

- (BOOL)scanIsAtEnd;

@end

#define skipWhitespace(c) while (isspace(*c)) { c++; }
#define skipDigits(c) while (isdigit(*c)) { c++; }


@implementation SBJsonParser

static char ctrl[0x22];

+ (void)initialize
{
    ctrl[0] = '\"';
    ctrl[1] = '\\';
    for (int i = 1; i < 0x20; i++) {
        ctrl[i+1] = i;
    }
    ctrl[0x21] = 0;
}

/**
 @deprecated This exists in order to provide fragment support in older APIs in one more version.
 It should be removed in the next major version.
 */
- (id)fragmentWithString:(id)repr {
    [self clearErrorTrace];
    
    if (!repr) {
        [self addErrorWithCode:EINPUT description:@"Input was 'nil'"];
        return nil;
    }
    
    depth_ = 0;
    c_ = [repr UTF8String];
    
    id o;
    if (![self scanValue:&o]) {
        return nil;
    }
    
    if (![self scanIsAtEnd]) {
        [self addErrorWithCode:ETRAILGARBAGE description:@"Garbage after JSON"];
        return nil;
    }
    
    NSAssert1(o, @"Should have a valid object from %@", repr);
    return o;
}

- (id)objectWithString:(NSString *)repr
{
    id o = [self fragmentWithString:repr];
    if (!o) {
        return nil;
    }
    
    if (![o isKindOfClass:[NSDictionary class]] && ![o isKindOfClass:[NSArray class]]) {
        [self addErrorWithCode:EFLAGMENT description:@"Valid fragment, but not JSON"];
        return nil;
    }
    return o;
}

/*
 In contrast to the public methods, it is an error to omit the error parameter here.
 */
- (BOOL)scanValue:(NSObject *__autoreleasing *)o
{
    skipWhitespace(c_);
    
    switch (*c_++) {
        case '{':
            return [self scanRestOfDictionary:(NSMutableDictionary**)o];
        case '[':
            return [self scanRestOfArray:(NSMutableArray**)o];
        case '"':
            return [self scanRestOfString:(NSMutableString**)o];
        case 'f':
            return [self scanRestOfFalse:(NSNumber**)o];
        case 't':
            return [self scanRestOfTrue:(NSNumber**)o];
        case 'n':
            return [self scanRestOfNull:(NSNull**)o];
        case '-':
        case '0'...'9':
            c_--;   // cannot verify number correctly without the first character
            return [self scanNumber:(NSNumber**)o];
            break;
        case '+':
            [self addErrorWithCode:EPARSENUM description:@"Leading + disallowed in number"];
            return NO;
        case 0x0:
            [self addErrorWithCode:EEOF description:@"Unexpected end of string"];
            return NO;
        default:
            [self addErrorWithCode:EPARSE description:@"Unrecognised leading character"];
            return NO;
    }
    
    NSAssert(0, @"Should never get here");
    return NO;
}

- (BOOL)scanRestOfFalse:(NSNumber *__autoreleasing *)o
{
}


















@end
