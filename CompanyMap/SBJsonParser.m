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
        [self addErrorWithCode:EFRAGMENT description:@"Valid fragment, but not JSON"];
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

- (BOOL)scanRestOfTrue:(NSNumber**)o
{
    if (strncmp(c_, "rue", 3) == 0) {
        c_ += 3;
        *o = [NSNumber numberWithBool:YES];
        return YES;
    }
    [self addErrorWithCode:EPARSE description:@"Expected 'true'"];
    return NO;
}

- (BOOL)scanRestOfFalse:(NSNumber *__autoreleasing *)o
{
    if (strncmp(c_, "alse", 4) == 0) {
        c_ += 4;
        *o = [NSNumber numberWithBool:NO];
        return YES;
    }
    [self addErrorWithCode:EPARSE description:@"Expected 'false'"];
    return NO;
}

- (BOOL)scanRestOfNull:(NSNull**)o
{
    if (strncmp(c_, "ull", 3) == 0) {
        c_ += 3;
        *o = [NSNull null];
        return YES;
    }
    [self addErrorWithCode:EPARSE description:@"Expected 'null'"];
    return NO;
}

- (BOOL)scanRestOfArray:(NSMutableArray**)o
{
    if (maxDepth_ && ++depth_ > maxDepth_) {
        [self addErrorWithCode:EDEPTH description:@"Nested too deep"];
        return NO;
    }
    
    *o = [NSMutableArray arrayWithCapacity:8];
    
    for (; *c_ ;) {
        id v;
        
        skipWhitespace(c_);
        if (*c_ == ']' && c_++) {
            depth_--;
            return YES;
        }
        
        if (![self scanValue:&v]) {
            [self addErrorWithCode:EPARSE description:@"Expected value while parsing array"];
            return NO;
        }
        
        [*o addObject:v];
        
        skipWhitespace(c_);
        if (*c_ == ',' && c_++) {
            skipWhitespace(c_);
            if (*c_ == ']') {
                [self addErrorWithCode:ETRAILCOMMA description:@"Trailing comma disallowed in array"];
                return NO;
            }
        }
    }
    
    [self addErrorWithCode:EEOF description:@"End of input while parsing array"];
    return NO;
}

- (BOOL)scanRestOfDictionary:(NSMutableDictionary**)o
{
    if (maxDepth_ && ++depth_ > maxDepth_) {
        [self addErrorWithCode:EDEPTH description:@"Nested too deep"];
        return NO;
    }
    
    *o = [NSMutableDictionary dictionaryWithCapacity:7];
    
    for (; *c_;) {
        id k, v;
        
        skipWhitespace(c_);
        if (*c_ == '}' && c_++) {
            depth_--;
            return YES;
        }
        
        if (!(*c_ == '\"' && c_++ && [self scanRestOfString:&k])) {
            [self addErrorWithCode:EPARSE description:@"Object key string expected"];
            return NO;
        }
        
        skipWhitespace(c_);
        if (*c_ != ':') {
            [self addErrorWithCode:EPARSE description:@"Expected ':' separating key and value"];
            return NO;
        }
        
        c_++;
        if (![self scanValue:&v]) {
            NSString* string = [NSString stringWithFormat:@"Object value expected for key; %@", k];
            [self addErrorWithCode:EPARSE description:string];
            return NO;
        }
        
        [*o setObject:v forKey:k];
        
        skipWhitespace(c_);
        if (*c_ == ',' && c_++) {
            skipWhitespace(c_);
            if (*c_ == '}') {
                [self addErrorWithCode:ETRAILCOMMA description:@"Trailing comma disallowed in object"];
                return NO;
            }
        }
    }
    
    [self addErrorWithCode:EEOF description:@"End of input while parsing object"];
    return NO;
}

- (BOOL)scanRestOfString:(NSMutableString**)o
{
    *o = [NSMutableString stringWithCapacity:16];
    do {
        size_t length = strcspn(c_, ctrl);
        if (length) {
            id t = [[NSString alloc] initWithBytesNoCopy:(char*)c_
                                                  length:length
                                                encoding:NSUTF8StringEncoding
                                            freeWhenDone:NO];
            if (t) {
                [*o appendString:t];
                //[t release];
                c_ += length;
            }
        }
        
        if (*c_ == '"') {
            c_++;
            return YES;
        } else if (*c_ == '\\') {
            unichar uc = *++c_;
            switch (uc) {
                case '\\':
                case '/':
                case '"':
                    break;
                    
                case 'b':   uc = '\b'; break;
                case 'n':   uc = '\n'; break;
                case 'r':   uc = '\r'; break;
                case 't':   uc = '\t'; break;
                case 'f':   uc = '\f'; break;
                    
                case 'u':
                    c_++;
                    if (![self scanUnicodeChar:&uc]) {
                        [self addErrorWithCode:EUNICODE description:@"Broken unicode character"];
                        return NO;
                    }
                    c_--;   // hack.
                    break;
                    
                default:
                    [self addErrorWithCode:EESCAPE description:[NSString stringWithFormat:@"Illegal escape sequence '0x%x'", uc]];
                    return NO;
                    break;
            }
            CFStringAppendCharacters((__bridge CFMutableStringRef)*o, &uc, 1);
            c_++;
            
        } else if (*c_ < 0x20) {
            [self addErrorWithCode:ECTRL description:[NSString stringWithFormat:@"Unexpected control character '0x%x'", *c_]];
            return NO;
            
        } else {
            NSLog(@"should not be able to get here");
            
        }
    } while (*c_);
    
    [self addErrorWithCode:EEOF description:@"Unexpected EOF while parsing string"];
    return NO;
}

- (BOOL)scanUnicodeChar:(unichar*)x
{
    unichar hi, lo;
    
    if (![self scanHexQuad:&hi]) {
        [self addErrorWithCode:EUNICODE description:@"Missing hex quad"];
        return NO;
    }
    
    if (hi >= 0xD800) {     // high surrogate char?
        if (hi < 0xDC00) {  // yes - expect a low char
            
            if (!(*c_ == '\\' && ++c_ && *c_ == 'u' && ++c_ && [self scanHexQuad:&lo])) {
                [self addErrorWithCode:EUNICODE description:@"Missing low character in surrogate pair"];
                return NO;
            }
            
            if (lo < 0xDC00 || lo >= 0xDFFF) {
                [self addErrorWithCode:EUNICODE description:@"Invalid low surrogate char"];
                return NO;
            }
            
            hi = (hi - 0xD800) * 0x400 + (lo - 0xDC00) + 0x10000;
            
        } else if (hi < 0xE000) {
            [self addErrorWithCode:EUNICODE description:@"Invalid high character in surrogate pair"];
            return NO;
        }
    }
    
    *x = hi;
    return YES;
}

- (BOOL)scanHexQuad:(unichar*)x
{
    *x = 0;
    for (int i = 0; i < 4; i++) {
        unichar uc = *c_;
        c_++;
        int d = (uc >= '0' && uc <= '9')
        ? uc - '0' : (uc >= 'a' && uc <= 'f')
        ? (uc - 'a' + 10) : (uc >= 'A' && uc <= 'F')
        ? (uc - 'A' + 10) : -1;
        if (d == -1) {
            [self addErrorWithCode:EUNICODE description:@"Missing hex digit in quad"];
            return NO;
        }
        *x *= 16;
        *x += d;
    }
    return YES;
}

- (BOOL)scanNumber:(NSNumber**)o
{
    const char* ns = c_;
    
    // The logic to test for validity of the number formatting is relicensed
    // from JSON::XS with permission from its author Marc Lehmann.
    // (Available at the CPAN: http://search.cpan.org/dist/JSON-XS/ .)
    
    if ('-' == *c_) {
        c_++;
    }
    
    if ('0' == *c_ && c_++) {
        if (isdigit(*c_)) {
            [self addErrorWithCode:EPARSENUM description:@"Leading 0 disallowed in number"];
            return NO;
        }
        
    } else if (!isdigit(*c_) && c_ != ns) {
        [self addErrorWithCode:EPARSENUM description:@"No digits after initial minus"];
        return NO;
        
    } else {
        skipDigits(c_);
    }
    
    // Fractional part
    if ('.' == *c_ && c_++) {
        if (!isdigit(*c_)) {
            [self addErrorWithCode:EPARSENUM description:@"No digits after decimal point"];
            return NO;
        }
        skipDigits(c_);
    }
    
    // Exponential part
    if ('e' == *c_ || 'E' == *c_) {
        c_++;
        
        if ('-' == *c_ || '+' == *c_) {
            c_++;
        }
        
        if (!isdigit(*c_)) {
            [self addErrorWithCode:EPARSENUM description:@"no digits after exponent"];
            return NO;
        }
        skipDigits(c_);
    }
    
    id string = [[NSString alloc] initWithBytesNoCopy:(char*)ns
                                               length:(c_ - ns)
                                             encoding:NSUTF8StringEncoding
                                         freeWhenDone:NO];      // TODO: YES???
    //[string autorelease];
    if (string && (*o = [NSDecimalNumber decimalNumberWithString:string])) {
        return YES;
    }
    
    [self addErrorWithCode:EPARSENUM description:@"Failed creating decimal instance"];
    return NO;
}

- (BOOL)scanIsAtEnd
{
    skipWhitespace(c_);
    return !*c_;
}

@end
