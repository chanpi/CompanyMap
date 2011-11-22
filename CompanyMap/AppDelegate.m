//
//  AppDelegate.m
//  CompanyMap
//
//  Created by  on 11/11/09.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "FoursquareWebLogin.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // 追記
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    viewController_ = [[UIViewController alloc] init];
	viewController_.view.frame = CGRectMake(0, 0, 320, 480);
	viewController_.view.backgroundColor = [UIColor grayColor];
    [_window addSubview:viewController_.view];
	[viewController_ viewWillAppear:YES];
    [_window makeKeyAndVisible];
    
    //[Foursquare2 removeAccessToken];
    if ([Foursquare2 isNeedToAuthorize]) {
        NSLog(@"Hello1");
        [self authorizeWithController:viewController_ callback:^(BOOL success, id result) {
            if (success) {
                [Foursquare2 getDetailForUser:@"self"
                                     callback:^(BOOL success, id result) {
                                         if (success) {
                                             [self testMethod];
                                         } else {
                                             NSLog(@":(");
                                         }
                                     }];
            } else {
                NSLog(@":/");
            }
        }];
    } else {
        NSLog(@"Hello2");
        [Foursquare2 getDetailForUser:@"self"
                             callback:^(BOOL success, id result) {
                                 if (success) {
                                     [self testMethod];
                                 } else {
                                     NSLog(@":(");
                                 }
                             }];
        
        //		Example check-in 
        //		[Foursquare2  createCheckinAtVenue:@"6522771"
        //									 venue:nil
        //									 shout:@"Testing"
        //								 broadcast:broadcastPublic
        //								  latitude:nil
        //								 longitude:nil
        //								accuracyLL:nil
        //								  altitude:nil
        //							   accuracyAlt:nil
        //								  callback:^(BOOL success, id result){
        //								if (success) {
        //									NSLog(@"%@",result);
        //								}
        //							}];
        
    }
     
    
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

Foursquare2Callback authorizeCallbackDelegate;
- (void)authorizeWithController:(UIViewController*)controller
                       callback:(Foursquare2Callback)callback
{
    authorizeCallbackDelegate = [callback copy];
    NSString* url = [NSString stringWithFormat:@"https://foursquare.com/oauth2/authenticate?display=touch&client_id=%@&response_type=code&redirect_uri=%@", OAUTH_KEY,REDIRECT_URL];
    
    FoursquareWebLogin* loginController = [[FoursquareWebLogin alloc] initWithUrl:url];
    loginController.title = @"Login";
    loginController.delegate = self;
    loginController.selector = @selector(setCode:);
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:loginController];
    
    [controller presentModalViewController:navigationController animated:YES];
    //[navigationController release];
    //[loginController release];
}

- (void)setCode:(NSString*)code
{
    [Foursquare2 getAccessTokenForCode:code callback:^(BOOL success, id result) {
        if (success) {
            
            NSLog(@"!!!!! %@ !!!!!", result);
            
            [Foursquare2 setBaseURL:[NSURL URLWithString:@"https://api.foursquare.com/v2/"]];
            [Foursquare2 setAccessToken:[result objectForKey:@"access_token"]];
            authorizeCallbackDelegate(YES, result);
            //[authorizeCallbackDelegate release];
        } else {
            NSLog(@">>>> %@ <<<<", result);
        }
    }];
}

- (void)testMethod
{
    NSLog(@"test mogemoge");
}


@end
