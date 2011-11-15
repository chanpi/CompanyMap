//
//  HROperationQueue.m
//  CompanyMap
//
//  Created by happy . on 11/11/15.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "HROperationQueue.h"
#import "HRGlobal.h"

static HROperationQueue* sharedOperationQueue = nil;

@implementation HROperationQueue
+ (HROperationQueue*)sharedOperationQueue
{
    @synchronized(self) {
        if (sharedOperationQueue == nil) {
            sharedOperationQueue = [[HROperationQueue alloc] init];
            sharedOperationQueue.maxConcurrentOperationCount = 3;
        }
    }
    
    return sharedOperationQueue;
}
@end
