//
//  SearchViewController.h
//  CompanyMap
//
//  Created by  on 11/11/09.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController {
    IBOutlet UIButton* freeSearchButton_;
    IBOutlet UIButton* areaButton_;
    IBOutlet UIButton* headCountButton_;
    IBOutlet UIButton* categoryButton_;
    IBOutlet UIButton* visitDayButton_;
    IBOutlet UIButton* visitPurposeButton_;
    IBOutlet UIButton* limitedSearchButton_;
}

@property (nonatomic, retain) UIButton* freeSearchButton;
@property (nonatomic, retain) UIButton* areaButton;
@property (nonatomic, retain) UIButton* headCountButton;
@property (nonatomic, retain) UIButton* categoryButton;
@property (nonatomic, retain) UIButton* visitDayButton;
@property (nonatomic, retain) UIButton* visitPurposeButton;
@property (nonatomic, retain) UIButton* limitedSearchButton;

- (IBAction)freeSearchButtonTouched:(id)sender;
- (IBAction)areaButtonTouched:(id)sender;
- (IBAction)headCountButtonTouched:(id)sender;
- (IBAction)categoryButtonTouched:(id)sender;
- (IBAction)visitDayButtonTouched:(id)sender;
- (IBAction)visitPurposeButtonTouched:(id)sender;
- (IBAction)limitedSearchButtonTouched:(id)sender;

@end
