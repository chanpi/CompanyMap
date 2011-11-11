//
//  FoursquareWebLogin.m
//  CompanyMap
//
//  Created by  on 11/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FoursquareWebLogin.h"

@interface FoursquareWebLogin (PrivateMethods)
- (void)cancel;
@end

@implementation FoursquareWebLogin

@synthesize delegate;
@synthesize selector;

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
        [delegate performSelector:selector withObject:[array objectAtIndex:1]];
        [self cancel];
        
    } else if ([url rangeOfString:@"error="].length != 0) {
        NSArray* array = [url componentsSeparatedByString:@"="];
        [delegate performSelector:selector withObject:[array objectAtIndex:1]];
        NSLog(@"Foursquare: %@", [array objectAtIndex:1]);
        
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {}
- (void)webViewDidFinishLoad:(UIWebView *)webView {}
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
