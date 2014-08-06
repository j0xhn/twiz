//
//  MyInterstatialAdViewController.m
//  Twiz
//
//  Created from LogInAndSignUpDemo via Parse
//  Copyright (c) 2014 John D. Storey. All rights reserved.
//

#import "MyInterstatialAdViewController.h"
#import "MyConstants.h"

@interface MyInterstatialAdViewController ()

@end

@implementation MyInterstatialAdViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{ // still in development, not finished yet - but displays an add
    [super viewDidLoad];
    self.view.backgroundColor = PURPLE_COLOR;
    
    UILabel *adDescriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 300, 50)];
    adDescriptionLabel.text = @"As punishment, view this ad";
    adDescriptionLabel.font = TWIZ_FONT_500_18;
    adDescriptionLabel.textColor = [UIColor whiteColor];
    adDescriptionLabel.textAlignment = UIControlContentHorizontalAlignmentCenter;
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setFrame:CGRectMake(SCREEN_HORIZONTAL/2, SCREEN_VERTICAL/2, 100, 30)];
    [closeButton setTitle:@"exit button" forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(removeViewController) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:adDescriptionLabel];
    [self.view addSubview:closeButton];
}

- (void) removeViewController{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
