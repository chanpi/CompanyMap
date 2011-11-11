//
//  HRRequestOperation.h
//  CompanyMap
//
//  Created by  on 11/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HRGlobal.h"
#import "HRResponseDelegate.h"

// ユーザはHRRestModelクラスを使用してください。
// HRRestModelクラスは本クラスのラッパーです。
@interface HRRequestOperation : NSOperation {
    /// HRResponse Delegate
    NSObject<HRResponseDelegate> *delegate_;

    /// Connection object
    NSURLConnection* connection_;
    
    /// Data received from response
    NSMutableData* responseData_;
    
    /// The path or URL to use in REST methods
    NSString* path_;
    
    /// Contains all options used by the request
    NSDictionary* options_;
    
    /// How long before the request will timeout
    NSTimeInterval timeout_;    // NSTimeInterval == double
    
    /// The request method to use
    HRRequestMethod requestMethod_;
    
    /// The HRFormatter object
    id formatter_;
    
    /// The object passed to all delegate methods
    id object_;
    
    /// Determines whether the operation is finished
    BOOL isFinished_;
    
    /// Determines whether the operation is executing
    BOOL isExecuting_;
    
    // Determines whether the connection is cancelled
    BOOL isCancelled_;
}

/// The HRResponseDelegate
/**
 * The HRResponseDelegate responsible for handling the success and failure of 
 * a request.
 */
@property (nonatomic, readonly, assign) NSObject <HRResponseDelegate>*delegate;

/// The lenght of time in seconds before the request times out.
/**
 * Sets the length of time in seconds before a request will timeout.
 * This defaults to <tt>30.0</tt>.
 */
@property (nonatomic, assign) NSTimeInterval timeout;

/// The REST method to use when performing a request
/**
 * This defaults to HRRequestMethodGet.  Valid options are ::HRRequestMethod.
 */
@property (nonatomic, assign) HRRequestMethod requestMethod;

/// The relative path or url string used in a request
/**
 If you provide a relative path here, you must set the baseURL option.
 If given a full url this will overide the baseURL option.
 */
@property (nonatomic, copy) NSString *path;

/// An NSDictionary containing all the options for a request.
/**
 This needs documented
 */
@property (nonatomic, retain) NSDictionary *options;

/// The formatter used to decode the response body.
/**
 Currently, only JSON is supported.
 */
@property (nonatomic, readonly, retain) id formatter;

/**
 * Returns an HRRequestOperation
 */
+ (HRRequestOperation *)requestWithMethod:(HRRequestMethod)method path:(NSString*)urlPath options:(NSDictionary*)requestOptions object:(id)obj;

@end
