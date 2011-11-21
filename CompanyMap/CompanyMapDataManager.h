//
//  CompanyMapDataManager.h
//  CompanyMap
//
//  Created by  on 11/11/09.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

@class Company;
@class Visit;

#import <Foundation/Foundation.h>

@interface CompanyMapDataManager : NSObject {
    NSManagedObjectContext* managedObjectContext_;  // 他のクラスからアクセスされる
}

@property (nonatomic, readonly) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, readonly) NSArray* sortedCompanies;

+ (CompanyMapDataManager*)sharedManager;

- (Company*)insertNewCompany;
- (Visit*)insertNewVisit;
- (void)save;

@end
