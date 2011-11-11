//
//  NSObject+InvocationUtils.h
//  CompanyMap
//
//  Created by  on 11/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (InvocationUtils)
- (void)performSelectorOnMainThread:(SEL)aSelector withObject:(id)arg1, ...;
- (void)performSelectorOnMainThread:(SEL)aSelector withObjectArray:(NSArray*)objects;
@end
