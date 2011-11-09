//
//  CompanyMapDataManager.h
//  CompanyMap
//
//  Created by  on 11/11/09.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CompanyMapDataManager : NSObject {
    NSManagedObjectContext* managedObjectContext_;
}

@property (nonatomic, readonly) NSManagedObjectContext* managedObjectContext;

@end
