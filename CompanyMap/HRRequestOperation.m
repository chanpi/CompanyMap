//
//  HRRequestOperation.m
//  CompanyMap
//
//  Created by  on 11/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HRRequestOperation.h"

#define IS_EXECUTING    @"isExecuting"
#define IS_FINISHED     @"isFinished"
#define IS_CANCELLED    @"isCancelled"

@interface HRRequestOperation (PrivateMethods)
- (NSMutableURLRequest*)http;
- (NSArray*)formattedResults:(NSData*)data;
- (void)setDefaultHeadersForRequest:(NSMutableURLRequest*)request;
- (void)setAuthHeadersForRequest:(NSMutableURLRequest*)request;
- (NSMutableURLRequest*)configuredRequest;
- (id)formatterFromFormat;
- (NSURL*)composedURL;
+ (id)handleResponse:(NSHTTPURLResponse*)response error:(NSError**)error;
+ (NSString*)buildQueryStringFromParams:(NSDictionary*)params;
- (void)finish;
@end

@implementation HRRequestOperation
@synthesize timeout         = timeout_;
@synthesize requestMethod   = requestMethod_;
@synthesize path            = path_;
@synthesize options         = options_;
@synthesize formatter       = formatter_;
@synthesize delegate        = delegate_;

- (void)dealloc
{
    /*
    [path_ release];
    [options_ release];
    [formatter_ release];
    [object_ release];
    [super dealloc];
     */
}

- (id)initWithMethod:(HRRequestMethod)method path:(NSString*)urlPath options:(NSDictionary*)options object:(id)object
{
    self = [super init];
    if (self) {
        isExecuting_    = NO;
        isFinished_     = NO;
        isCancelled_    = NO;
        requestMethod_  = method;
        path_           = [urlPath copy];
        options_        = options_;//[options_ retain];
        object_         = object_;//[object_ retain];
        timeout_        = 30.0f;
        delegate_       = [[options_ valueForKey:kHRClassAttributesDelegateKey] nonretainedObjectValue];
        formatter_      = [self formatterFromFormat];//[[self formatterFromFormat] retain];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// NSOperationクラスの共通メソッド
#pragma mark - Concurrent NSOperation Methods

- (void)start
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
        return;
    }
    
    [self willChangeValueForKey:IS_EXECUTING];
    isExecuting_ = YES;
    [self didChangeValueForKey:IS_EXECUTING];
    
    NSURLRequest* request = [self configuredRequest];
    HRLOG(@"FETCHING:>%@<\nHEADERS:%@", [request URL], [request allHTTPHeaderFields]);
    connection_ = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
    if (connection_) {
        responseData_ = [[NSMutableData alloc] init];
    } else {
        [self finish];
    }
}

- (void)finish
{
    HRLOG(@"Operation Finished. Releasing...");
    //[connection_ release];
    connection_ = nil;
    
    //[responseData_ release];
    responseData_ = nil;
    
    [self willChangeValueForKey:IS_EXECUTING];
    [self willChangeValueForKey:IS_FINISHED];
    
    isExecuting_ = NO;
    isFinished_ = YES;
    
    [self didChangeValueForKey:IS_EXECUTING];
    [self didChangeValueForKey:IS_FINISHED];
}

- (void)cancel
{
    HRLOG(@"SHOULD CANCEL");
    [self willChangeValueForKey:IS_CANCELLED];
    
    [connection_ cancel];
    isCancelled_ = YES;
    
    [self didChangeValueForKey:IS_CANCELLED];
    [self finish];
}

- (BOOL)isExecuting
{
    return isExecuting_;
}

- (BOOL)isFinished
{
    return isFinished_;
}

- (BOOL)isCancelled
{
    return isCancelled_;
}

- (BOOL)isConcurrent
{
    return YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSURLConnection delegates





























@end
