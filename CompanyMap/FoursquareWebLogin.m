//
//  FoursquareWebLogin.m
//  CompanyMap
//
//  Created by  on 11/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FoursquareWebLogin.h"
#import "Foursquare2.h"
#import "AppDelegate.h"
//#import <objc/message.h>

@interface FoursquareWebLogin (PrivateMethods)
- (void)cancel;
@end

@implementation FoursquareWebLogin

@synthesize delegate = delegate_;
@synthesize selector = selector_;

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

- (id) initWithUrl:(NSString*)url
{
    self = [super init];
    if (self) {
        url_ = url;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    webView_ = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url_]];
    [webView_ loadRequest:request];
    [webView_ setDelegate:self];
    [self.view addSubview:webView_];
    //[webView_ release];
}

- (void)cancel
{
    [self dismissModalViewControllerAnimated:YES];
}

// ----------- UIWebViewDelegate ここから -----------
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString* url = [[request URL] absoluteString];
        
    if ([url rangeOfString:@"code="].length != 0) {
        NSHTTPCookie* cookie;
        NSHTTPCookieStorage* storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (cookie in [storage cookies]) {
            if ([[cookie domain] isEqualToString:@"foursquare.com"]) {
                [storage deleteCookie:cookie];
            }
        }
        NSArray* array = [url componentsSeparatedByString:@"="];
        NSLog(@"delegate:%@\narray:%@", delegate_, array);
        [self.delegate performSelector:@selector(setCode:) withObject:[array objectAtIndex:1]]; // AppDelegateで設定
        //[delegate_ performSelector:selector_ withObject:[array objectAtIndex:1]]; // AppDelegateで設定
        //objc_msgSend(delegate_, selector_, [array objectAtIndex:1]);
        [self cancel];
        
        if ([url hasPrefix:REDIRECT_URL]) {
            return NO;
        }
        
    } else if ([url rangeOfString:@"error="].length != 0) {
        NSArray* array = [url componentsSeparatedByString:@"="];
        [self.delegate performSelector:@selector(setCode:) withObject:[array objectAtIndex:1]]; // AppDelegateで設定
        //[delegate_ performSelector:selector_ withObject:[array objectAtIndex:1]]; // AppDelegateで設定
        //objc_msgSend(delegate_, selector_, [array objectAtIndex:1]);
        NSLog(@"Foursquare: %@", [array objectAtIndex:1]);
        
    }
    
    // 追記
    if ([url rangeOfString:@"access_token="].length != 0) {
        NSLog(@"!!!!!");
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    /*
     NSString* url = [[webView_.request URL] absoluteString];
     //NSLog(@"koko--> %@", url);
     if ([url isEqualToString:REDIRECT_URL]) {
        NSLog(@"\nsame!\n");
     }
    if ([url rangeOfString:@"access_token="].location != NSNotFound) {
        NSString* accessToken = [[url componentsSeparatedByString:@"="] lastObject];
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:accessToken forKey:@"access_token"];
        [defaults synchronize];
        [self dismissModalViewControllerAnimated:YES];
        
        NSLog(@"--- get access token ---");
    }
     */
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {}

// ----------- UIWebViewDelegate ここまで -----------

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
