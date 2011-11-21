//
//  CompanyMapDataManager.m
//  CompanyMap
//
//  Created by  on 11/11/09.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "CompanyMapDataManager.h"
#import "Company.h"
#import "Visit.h"

@implementation CompanyMapDataManager

static CompanyMapDataManager* sharedInstance_ = nil;

+ (CompanyMapDataManager*)sharedManager
{
    if (!sharedInstance_) {
        sharedInstance_ = [[CompanyMapDataManager alloc] init];
    }
    return sharedInstance_;
}

- (NSManagedObjectContext*)managedObjectContext
{
    if (managedObjectContext_) {
        return managedObjectContext_;
    }
    
    // 管理対象オブジェクトモデルの作成
    NSManagedObjectModel* managedObjectModel;
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    // 永続ストアコーディネータの作成
    NSPersistentStoreCoordinator* persistentStoreCoordinator;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    //[persistentStoreCoordinator autorelease];
    
    // ストアURLの作成
    NSArray* paths;
    NSURL* url = nil;
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    if ([paths count] > 0) {
        NSString* path;
        path = [paths objectAtIndex:0];
        path = [path stringByAppendingPathComponent:@".companymap"];    // 不過視のフォルダ
        path = [path stringByAppendingPathComponent:@"companymap.db"];
        url = [NSURL fileURLWithPath:path];                             // ~/Documents/.companymap/companymap.db
    }
    
    // 永続ストアの追加
    NSPersistentStore* persistentStore;
    NSError* error = nil;
    persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType  // メモリ使用量小
                                                               configuration:nil
                                                                         URL:url
                                                                     options:nil error:&error];
    if (!persistentStore && error) {
        NSLog(@"Failed to create add persistent store, %@", [error localizedDescription]);
    }
    
    // 管理対象オブジェクトコンテキストの作成
    managedObjectContext_ = [[NSManagedObjectContext alloc] init];
    
    // 永続ストアコーディネータの設定
    [managedObjectContext_ setPersistentStoreCoordinator:persistentStoreCoordinator];
    
    return managedObjectContext_;
}

static int companyIndex_ = 0;

- (Company*)insertNewCompany
{
    // 管理対象オブジェクトコンテキストを取得する
    NSManagedObjectContext* context;
    context = self.managedObjectContext;
    
    // Companyを作成する
    Company* company;
    company = [NSEntityDescription insertNewObjectForEntityForName:@"Company"
                                            inManagedObjectContext:context];
    
    // 識別子を設定する
    CFUUIDRef uuid;
    NSString* identifier;
    uuid = CFUUIDCreate(NULL);
    identifier = (__bridge NSString*)CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    //[identifier autorelease];
    company.identifier = identifier;
    
    // インデックスを設定する
    company.index = [NSNumber numberWithInt:companyIndex_++];   // TODO: 必要？
    
    return company;
}

- (Visit*)insertNewVisit
{
    // 管理対象オブジェクトコンテキストを取得する
    NSManagedObjectContext* context;
    context = self.managedObjectContext;
    
    // Visitを作成する
    Visit* visit;
    visit = [NSEntityDescription insertNewObjectForEntityForName:@"Visit" inManagedObjectContext:context];
    
    // 識別子を設定する
    CFUUIDRef uuid;
    NSString* identifier;
    uuid = CFUUIDCreate(NULL);
    identifier = (__bridge NSString*)CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    //[identifier autorelease];
    visit.identifier = identifier;
    
    return visit;
}

- (NSArray*)sortedCompanies
{
    // 管理対象オブジェクトコンテキストを取得する
    NSManagedObjectContext* context;
    context = self.managedObjectContext;
    
    // 取得要求を作成する
    NSFetchRequest* request;
    NSEntityDescription* entity;
    NSSortDescriptor* sortDescriptor;
    request = [[NSFetchRequest alloc] init];
    //[request autorelease];
    entity = [NSEntityDescription entityForName:@"Company"
                         inManagedObjectContext:context];
    [request setEntity:entity];
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index"
                                                 ascending:YES];
    //[sortDescriptor autorelease];
    [request setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    // 管理対象オブジェクトを取得する
    NSArray* result;
    NSError* error = nil;
    result = [context executeFetchRequest:request error:&error];
    if (!result) {
        // Error
        NSLog(@"executeFetchRequest: failed, %@", [error localizedDescription]);
        return nil;
    }
    return result;
}

- (void)save
{
    // 保存
    NSError* error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"save: failed, %@", [error localizedDescription]);
    } else {
        NSLog(@"Data is saved.");
    }
}

@end