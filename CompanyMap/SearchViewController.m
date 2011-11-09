//
//  SearchViewController.m
//  CompanyMap
//
//  Created by  on 11/11/09.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchViewController.h"

@implementation SearchViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// UIViewでやらねばならない
- (void)_drawLine
{
    CGContextRef cgcontext = UIGraphicsGetCurrentContext();
    
    // 線の色
//    CGContextSetRGBStrokeColor(cgcontext, 0.0f, 0.0f, 0.0f, 0.9f);
    CGContextSetRGBStrokeColor(cgcontext, 0.1f, 0.1f, 0.9f, 1.0f);
    
    CGContextMoveToPoint(cgcontext, 20, 95);
    CGContextAddLineToPoint(cgcontext, 300, 95);
    CGContextStrokePath(cgcontext);
}
*/

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
