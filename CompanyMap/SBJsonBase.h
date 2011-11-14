//
//  SBJsonBase.h
//  CompanyMap
//
//  Created by  on 11/11/14.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* SBJSONErrorDomain;

enum {
    ENUMSUPPORTED = 1,
    EPARSENUM,
    EPARSE,
    EFLAGMENT,
    ECTRL,
    EUNICODE,
    EDEPTH,
    EESCAPE,
    ETRAILCOMMA,
    ETRAILGARBAGE,
    EEOF,
    EINPUT,
};

// Parser/Writerクラスの共通のエラーハンドリングクラスです。
@interface SBJsonBase : NSObject {
    NSMutableArray* errorTrace_;
    
@protected
    NSUInteger depth_;
    NSUInteger maxDepth_;
}

/**
 @brief The maximum recursing depth.
 
 Defaults to 512. If the input is nested deeper than this the input will be deemed to be
 malicious and the parser returns nil, signalling an error. ("Nested too deep".) You can
 turn off this security feature by setting the maxDepth value to 0.
 */
@property NSUInteger maxDepth;

/**
 @brief Return an error trace, or nil if there was no errors.
 
 Note that this method returns the trace of the last method that failed.
 You need to check the return value of the call you're making to figure out
 if the call actually failed, before you know call this method.
 */
@property (copy, readonly) NSArray* errorTrace;

/// @internal for use in subclasses to add errors to the stack trace
- (void)addErrorWithCode:(NSInteger)code description:(NSString*)string;

/// @internal for use in subclasess to clear the error before a new parsing attempt
- (void)clearErrorTrace;

@end
