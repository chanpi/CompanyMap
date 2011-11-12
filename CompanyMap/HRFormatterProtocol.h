//
//  HRFormatterProtocol.h
//  CompanyMap
//
//  Created by  on 11/11/12.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HRFormatterProtocol

/**
 * The file extension.  Example: json, xml, plist, n3, etc.
 */
+ (NSString*)extension;

/**
 * The mime-type represented by this formatter
 */
+ (NSString*)mimeType;

/**
 * Takes the format and turns it into the appropriate Obj-C data type.
 *
 * @param data Raw data to be decoded.
 * @param error Returns any errors that happened while decoding.
 */
+ (id)decode:(NSData*)data error:(NSError*)error;

/**
 * Takes an Obj-C data type and turns it into the proper format.
 *
 * @param object The Obj-C object to be encoded by the formatter.
 * @param error Returns any errors that happened while encoding.
 */
+ (NSString*)encode:(id)object error:(NSError*)error;

@end
