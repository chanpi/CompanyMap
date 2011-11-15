//
//  AIXMLDocumentSerialize.h
//  CompanyMap
//
//  Created by happy . on 11/11/15.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AIXMLSerialization.h"

@interface NSXMLDocument (Serialize)
- (NSMutableDictionary*)toDictionary;
@end
