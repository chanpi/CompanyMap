//
//  NSObject+InvocationUtils.m
//  CompanyMap
//
//  Created by  on 11/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NSObject+InvocationUtils.h"

@implementation NSObject (InvocationUtils)

- (void)performSelectorOnMainThread:(SEL)aSelector withObject:(id)arg1, ...
{
    id argitem;
    va_list args;
    NSMutableArray* objects = [[NSMutableArray alloc] init];
    if (arg1 != nil) {
        [objects addObject:arg1];
        va_start(args, arg1);
        
        while ((argitem = va_arg(args, id)) != nil) {
            [objects addObject:argitem];
        }
        
        va_end(args);
    }
    
    [self performSelectorOnMainThread:aSelector withObjectArray:objects];
    //[objects release];
}

- (void)performSelectorOnMainThread:(SEL)aSelector withObjectArray:(NSArray*)objects
{
    NSMethodSignature* signature = [self methodSignatureForSelector:aSelector];
    if (signature) {
        NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:self];
        [invocation setSelector:aSelector];
        
        for (size_t i = 0; i < objects.count; i++) {
            id object = [objects objectAtIndex:i] ;
            [invocation setArgument:&object atIndex:(i+2)]; // セットする引数のインデックス値（隠し引数が2つあるので、通常は2から始まる
            // TODO: i+って必要？？？？？？
        }
        
        [invocation performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:YES];
    }
}

@end
