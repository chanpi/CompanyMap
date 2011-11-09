//
//  Company.h
//  CompanyMap
//
//  Created by  on 11/11/09.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Visit;

@interface Company : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * category;
@property (nonatomic, retain) NSNumber * headcount;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *visits;
@end

@interface Company (CoreDataGeneratedAccessors)

- (void)addVisitsObject:(Visit *)value;
- (void)removeVisitsObject:(Visit *)value;
- (void)addVisits:(NSSet *)values;
- (void)removeVisits:(NSSet *)values;
@end
