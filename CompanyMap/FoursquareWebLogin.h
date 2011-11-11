//
//  FoursquareWebLogin.h
//  CompanyMap
//
//  Created by  on 11/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FoursquareWebLogin : UIViewController<UIWebViewDelegate> {
    NSString* url_;
    UIWebView* webView_;
    id delegate_;
    SEL selector_;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) SEL selector;

- (id) initWithUrl:(NSString*)url;

@end
