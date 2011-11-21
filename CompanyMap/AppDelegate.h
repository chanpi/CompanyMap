//
//  AppDelegate.h
//  CompanyMap
//
//  Created by  on 11/11/09.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Foursquare2.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    UIViewController* viewController_;
}

@property (strong, nonatomic) UIWindow *window;

- (void)authorizeWithController:(UIViewController*)controller
                       callback:(Foursquare2Callback)callback;
- (void)setCode:(NSString*)code;
- (void)testMethod;

@end
