//
//  HROperationQueue.h
//  CompanyMap
//
//  Created by happy . on 11/11/15.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Gives you access to the shared operation queue used to manage all connections.
 */
@interface HROperationQueue : NSOperationQueue

/**
 * Shared operation queue.
 */
+ (HROperationQueue*)sharedOperationQueue;

@end
