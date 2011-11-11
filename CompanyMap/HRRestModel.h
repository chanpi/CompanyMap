//
//  HRRestModel.h
//  CompanyMap
//
//  Created by  on 11/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HRGlobal.h"

@interface HRRestModel : NSObject

/**
 * Returns the HRResponseDelegate
 */
+ (NSObject*)delegate;
/**
 * Set the HRResponseDelegate
 * @param delegate The HRResponseDelegate responsible for handling callbacks 
 */
+ (void)setDelegate:(NSObject*)delegate;

+ (NSURL*)baseURL;
+ (void)setBaseURL:(NSURL*)url;

/**
 * Default headers sent with every request
 */
+ (NSDictionary*)headers;
/**
 * Set the default headers sent with every request.
 * @param headers An NSDictionary of headers.  For example you can 
 * set this up.
 *
 * @code
 * NSDictionary *hdrs = [NSDictionary dictionaryWithObject:@"application/json" forKey:@"Accept"];
 * [self setHeaders:hdrs];
 * @endcode
 */
+ (void)setHeaders:(NSDictionary*)headers;

+ (NSDictionary*)basicAuth;
+ (void)setBasicAuthWithUsername:(NSString*)username password:(NSString*)password;

+ (NSDictionary*)defaultParams;
+ (void)setDefaultParams:(NSDictionary*)params;

/**
 * The format used to decode and encode request and responses.
 * Supported formats are JSON and XML.
 */
+ (HRDataFormat)format;
+ (void)setFormat:(HRDataFormat)format;


/** 
 * @name Sending Requests
 * These methods allow you to send GET, POST, PUT and DELETE requetsts.
 *
 * <h3>Request Options</h3>
 * All requests can take numerous types of options passed as the second argument.
 * @li @b headers <tt>NSDictionary</tt> - The headers to send with the request
 * @li @b params <tt>NSDictionary</tt> - The query or body parameters sent with the request.
 * @li @b body <tt>NSData</tt>, <tt>NSString</tt> or <tt>NSDictionary</tt> - This option is used only during POST and PUT
 *     requests.  This option is eventually transformed into an NSData object before it is sent.
 *     If you supply the body as an NSDictionary it's turned to a query string &foo=bar&baz=boo and 
 *     then it's encoded as an NSData object.  If you supply an NSString, it's encoded as an NSData 
 *     object and sent.  
 * @{
 */

/**
 * Send a GET request
 * @param path The path to get.  If you haven't setup the baseURL option you'll need to provide a 
 *        full url. 
 * @param options The options for this request.
 * @param object An object to be passed to the delegate methods
 *
 */
+ (NSOperation *)getPath:(NSString *)path withOptions:(NSDictionary *)options object:(id)object;

/**
 * Send a POST request
 * @param path The path to POST to.  If you haven't setup the baseURL option you'll need to provide a 
 *        full url. 
 * @param options The options for this request.
 * @param object An object to be passed to the delegate methods
 *
 * <strong>Note:</strong> If you'd like to post raw data like JSON or XML you'll need to set the <tt>body</tt> option.
 *
 */
+ (NSOperation *)postPath:(NSString *)path withOptions:(NSDictionary *)options object:(id)object;

/**
 * Send a PUT request
 * @param path The path to PUT to.  If you haven't setup the baseURL option you'll need to provide a 
 *        full url. 
 * @param options The options for this request.
 * @param object An object to be passed to the delegate methods
 *
 * @remarks <strong>Note:</strong>  All data found in the <tt>body</tt> option will be PUT.  Setting the <tt>body</tt>
 * option will cause the <tt>params</tt> option to be ignored.
 *
 */
+ (NSOperation *)putPath:(NSString *)path withOptions:(NSDictionary *)options object:(id)object;

/**
 * Send a DELETE request
 * @param path The path to DELETE.  If you haven't setup the baseURL option you'll need to provide a 
 *        full url. 
 * @param options The options for this request.
 * @param object An object to be passed to the delegate methods
 *
 */
+ (NSOperation *)deletePath:(NSString *)path withOptions:(NSDictionary *)options object:(id)object;
//@}

@end
