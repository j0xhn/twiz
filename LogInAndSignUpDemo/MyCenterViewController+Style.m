//
//  MyCenterViewController+Style.m
//  Twiz
//
//  Created from LogInAndSignUpDemo via Parse
//  Copyright (c) 2014 John D. Storey. All rights reserved.
//

#import "MyCenterViewController+Style.h"
#import <QuartzCore/QuartzCore.h>
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "MyConstants.h"

@implementation MyCenterViewController (Style)

- (void) viewWillAppear:(BOOL)animated{ // loaded everytime view is about to appear, refactor to include all styling of views
    
    // Navigation Bar
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:PURPLE_BACKGROUND]];
    self.title = NSLocalizedString(@"Twiz", nil);
    self.navigationController.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = PURPLE_COLOR;
    self.navigationController.navigationBar.translucent = NO;
    //  [self.navigationController.navigationBar setFrame:CGRectMake(0, 0, 320, 14)];
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSFontAttributeName: [UIFont fontWithName:@"MuseoSansRounded-900" size:24],
                                                                      NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                      }];
    
}

@end
