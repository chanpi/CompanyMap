//
//  CompanyMapDataManager.m
//  CompanyMap
//
//  Created by  on 11/11/09.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CompanyMapDataManager.h"

@implementation CompanyMapDataManager

- (NSManagedObjectContext*)managedObjectContext
{
    if (managedObjectContext_) {
        return managedObjectContext_;
    }
    
    // 管理対象オブジェクトモデルの作成
    NSManagedObjectModel* managedObjectModel;

    
    return managedObjectContext_;
}

@end
