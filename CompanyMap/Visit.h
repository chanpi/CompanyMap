//
//  Visit.h
//  CompanyMap
//
//  Created by  on 11/11/09.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Visit : NSManagedObject

@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSNumber * person;
@property (nonatomic, retain) NSNumber * purpose;
@property (nonatomic, retain) NSManagedObject *company;

@end
