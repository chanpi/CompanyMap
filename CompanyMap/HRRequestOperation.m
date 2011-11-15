//
//  HRRequestOperation.m
//  CompanyMap
//
//  Created by  on 11/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HRRequestOperation.h"
#import "HRFormatJSON.h"
#import "HRFormatXML.h"
#import "NSObject+InvocationUtils.h"
#import "NSString+EscapingUtils.h"
#import "NSDictionary+ParamUtils.h"
#import "HRBase64.h"
#import "HROperationQueue.h"
//#import "PhotoFormatter.h"

NSString* kHRIsExecuting    = @"isExecuting";
NSString* kHRIsFinished     = @"isFinished";
NSString* kHRIsCancelled    = @"isCancelled";

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
    
    [self willChangeValueForKey:kHRIsExecuting];
    isExecuting_ = YES;
    [self didChangeValueForKey:kHRIsExecuting];
    
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
    
    [self willChangeValueForKey:kHRIsExecuting];
    [self willChangeValueForKey:kHRIsFinished];
    
    isExecuting_ = NO;
    isFinished_ = YES;
    
    [self didChangeValueForKey:kHRIsExecuting];
    [self didChangeValueForKey:kHRIsFinished];
}

- (void)cancel
{
    HRLOG(@"SHOULD CANCEL");
    [self willChangeValueForKey:kHRIsCancelled];
    
    [connection_ cancel];
    isCancelled_ = YES;
    
    [self didChangeValueForKey:kHRIsCancelled];
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

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
    HRLOG(@"Server responded whith:%i, %@", [response statusCode], [NSHTTPURLResponse localizedStringForStatusCode:[response statusCode]]);
    
    if ([delegate_ respondsToSelector:@selector(restConnection:didReceiveResponse:object:)]) {
        [delegate_ performSelectorOnMainThread:@selector(restConnection:didReceiveResponse:object:) withObjects:connection, response, object_, nil];
    }
    
    NSError* error = nil;
    [[self class] handleResponse:(NSHTTPURLResponse*)response error:&error];
    
    if (error) {
        if ([delegate_ respondsToSelector:@selector(restConnection:didReceiveError:response:object:)]) {
            [delegate_ performSelectorOnMainThread:@selector(restConnection:didReceiveError:response:object:) withObjects:connection, error, response, object_, nil];
            [connection cancel];
            [self finish];
        }
    }
    
    [responseData_ setLength:0];
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData *)data
{
    [responseData_ appendData:data];
    NSString* content = [[NSString alloc] initWithBytes:[data bytes]
                                                 length:[data length]
                                               encoding:NSUTF8StringEncoding];
    NSLog(@"%@", content);
    //[content release];
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError *)error
{
    HRLOG(@"Connection failed: %@", [error localizedDescription]);
    if ([delegate_ respondsToSelector:@selector(restConnection:didFailWithError:object:)]) {
        [delegate_ performSelectorOnMainThread:@selector(restConnection:didFailWithError:object:) withObjects:connection, error, object_, nil];
    }
    [self finish];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    id results = [NSNull null];
    NSError* parseError = nil;
    if ([responseData_ length] > 0) {
        results = [[self formatter] decode:responseData_ error:&parseError];
        
        if (parseError) {
            NSString* rawString = [[NSString alloc] initWithData:responseData_ encoding:NSUTF8StringEncoding];
            if ([delegate_ respondsToSelector:@selector(restConnection:didReceiveParseError:responseBody:object:)]) {
                [delegate_ performSelectorOnMainThread:@selector(restConnection:didReceiveParseError:responseBody:object:) withObjects:connection, parseError, rawString, object_, nil];
            }
            
            //[rawString release];
            [self finish];
            
            return;
        }
    }
    
    if ([delegate_ respondsToSelector:@selector(restConnection:didReturnResource:object:)]) {
        [delegate_ performSelectorOnMainThread:@selector(restConnection:didReturnResource:object:) withObjects:connection, results, object_, nil];
    }
    
    [self finish];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Configuration

- (void)setDefaultHeadersForRequest:(NSMutableURLRequest *)request
{
    NSDictionary* headers = [[self options] valueForKey:kHRClassAttributesHeadersKey];
    [request setValue:[[self formatter] mimeType] forHTTPHeaderField:@"Content-Type"];
    [request addValue:[[self formatter] mimeType] forHTTPHeaderField:@"Accept"];
    if (headers) {
        for (NSString* header in headers) {
            NSString* value = [headers valueForKey:header];
            if ([header isEqualToString:@"Accept"]) {
                [request addValue:value forHTTPHeaderField:header];
            } else {
                [request setValue:value forHTTPHeaderField:header];
            }
        }
    }
}

- (void)setAuthHeadersForRequest:(NSMutableURLRequest *)request
{
    NSDictionary* authDictionary = [options_ valueForKey:kHRClassAttributesBasicAuthKey];
    NSString* username = [authDictionary valueForKey:kHRClassAttributesUsernameKey];
    NSString* password = [authDictionary valueForKey:kHRClassAttributesPasswordKey];
    
    if (username || password) {
        NSString* userPass = [NSString stringWithFormat:@"%@:%@", username, password];
        NSData* upData = [userPass dataUsingEncoding:NSUTF8StringEncoding];
        NSString* encodedUserPass = [HRBase64 encode:upData];
        NSString* basicHeader = [NSString stringWithFormat:@"Basic %@", encodedUserPass];
        [request setValue:basicHeader forHTTPHeaderField:@"Authorization"];
    }
}

- (NSMutableURLRequest*)configuredRequest
{
    //NSMutableURLRequest* request = [[[NSMutableURLRequest alloc] init] autorelease];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval:timeout_];
    [request setHTTPShouldHandleCookies:YES];
    [self setDefaultHeadersForRequest:request];
    [self setAuthHeadersForRequest:request];
    
    NSURL* composedURL = [self composedURL];
    NSDictionary* params = [[self options] valueForKey:kHRClassAttributesParamsKey];
    id body = [[self options] valueForKey:kHRClassAttributesBodyKey];
    NSString* queryString = [[self class] buildQueryStringFromParams:params];
    NSString* urlString = [[composedURL absoluteString] stringByAppendingString:queryString];   // FullURL + クエリ
    NSURL* url = [NSURL URLWithString:urlString];
    [request setURL:url];
    NSLog(@"url: %@", url);
    
    if (requestMethod_ == HRRequestMethodGet || requestMethod_ == HRRequestMethodDelete) {
        if (requestMethod_ == HRRequestMethodGet) {
            [request setHTTPMethod:@"GET"];
        } else {
            [request setHTTPMethod:@"DELETE"];
        }
    } else if (requestMethod_ == HRRequestMethodPost || requestMethod_ == HRRequestMethodPut) {
        NSData* bodyData = nil;
        if ([body isKindOfClass:[NSDictionary class]]) {
            bodyData = [[body toQueryString] dataUsingEncoding:NSUTF8StringEncoding];
        } else if ([body isKindOfClass:[NSString class]]) {
            bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
        } else if ([body isKindOfClass:[NSData class]]) {
            bodyData = body;
        } else {
            /*
            NSException* ex = [NSException exceptionWithName:@"InvalidBodyData"
                                                      reason:@"The body must be an NSDictionary, NSString or NSData"
                                                    userInfo:nil];
            return request;
            [ex raise];
             */
        }
        
        [request setHTTPBody:bodyData];
        //[request setURL:composedURL];
        
        if (requestMethod_ == HRRequestMethodPost) {
            [request setHTTPMethod:@"POST"];
        } else {
            [request setHTTPMethod:@"PUT"];
        }
    }
    return request;
}

- (NSURL*)composedURL
{
    NSURL* tmpURI = [NSURL URLWithString:path_];
    NSURL* baseURL = [options_ objectForKey:kHRClassAttributesBaseURLKey];
    
    if ([tmpURI host] == nil && [baseURL host] == nil) {
        [NSException raise:@"UnspecifiedHost" format:@"host wasn't provided in baseURL or path"];
    }
    
    if ([tmpURI host]) {
        return tmpURI;
    }
    
    return [NSURL URLWithString:[[baseURL absoluteString] stringByAppendingPathComponent:path_]];   // baseURL + pathのフルパス
}

- (id)formatterFromFormat
{
    NSNumber* format = [[self options] objectForKey:kHRClassAttributesFormatKey];
    id theFormatter = nil;
    switch ([format intValue]) {
        case HRDataFormatXML:
            theFormatter = [HRFormatXML class];
            break;
            
        case HRDataFormatJSON:
        default:
            theFormatter = [HRFormatJSON class];
            break;
    }
    
    NSString* errorMessage = [NSString stringWithFormat:@"Invalid Formatter %@", NSStringFromClass(theFormatter)];
    NSAssert([theFormatter conformsToProtocol:@protocol(HRFormatterProtocol)], errorMessage);
    
    return theFormatter;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Class Methods

+ (HRRequestOperation*)requestWithMethod:(HRRequestMethod)method path:(NSString *)urlPath options:(NSDictionary *)requestOptions object:(id)object
{
    id operation = [[self alloc] initWithMethod:method path:urlPath options:requestOptions object:object];
    [[HROperationQueue sharedOperationQueue] addOperation:operation];
    //return [operation autorelease];
    return operation;
}

+ (id)handleResponse:(NSHTTPURLResponse *)response error:(NSError *__autoreleasing *)error
{
    NSInteger code = [response statusCode];
    NSUInteger ucode = [[NSNumber numberWithInt:code] unsignedIntValue];
    NSRange okRange = NSMakeRange(200, 201);
    
    if (NSLocationInRange(ucode, okRange)) {
        return response;
    }
    
    if (error != nil) {
        NSDictionary* headers = [response allHeaderFields];
        NSString* errorReason = [NSString stringWithFormat:@"%d Error: ", code];
        NSString* errorDescription = [NSHTTPURLResponse localizedStringForStatusCode:code];
        /*
        NSDictionary* userInfo = [[[NSDictionary dictionaryWithObjectsAndKeys:
                                    errorReason, NSLocalizedFailureReasonErrorKey,
                                    errorDescription, NSLocalizedDescriptionKey,
                                    headers, kHRClassAttributesHeadersKey,
                                    [[response URL] absoluteString], @"url",
                                    nil] retain] autorelease];
         */
        NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                    errorReason, NSLocalizedFailureReasonErrorKey,
                                    errorDescription, NSLocalizedDescriptionKey,
                                    headers, kHRClassAttributesHeadersKey,
                                    [[response URL] absoluteString], @"url",
                                    nil];
        *error = [NSError errorWithDomain:HTTPRiotErrorDomain code:code userInfo:userInfo];
    }
    
    return nil;
}

+ (NSString*)buildQueryStringFromParams:(NSDictionary *)params
{
    if (params) {
        if ([params count] > 0) {
            return [NSString stringWithFormat:@"?%@", [params toQueryString]];
        }
    }
    
    return @"";
}

@end
