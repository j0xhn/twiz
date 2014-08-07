//
//  MyInterstatialAdViewController.m
//  Twiz
//
//  Created from LogInAndSignUpDemo via Parse
//  Copyright (c) 2014 John D. Storey. All rights reserved.
//

#import "MyInterstatialAdViewController.h"
#import "MyConstants.h"
#import <iAd/iAd.h>
#import <UIKit/UIKit.h>

@interface MyInterstatialAdViewController ()

@property (nonatomic, assign) BOOL requestingAd;
@property (strong, nonatomic) ADInterstitialAd *interstitial;
@property (strong, nonatomic) UIView *loadingView;

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
    self.requestingAd = NO;
    self.interstitial = [[ADInterstitialAd alloc] init];
    self.view.backgroundColor = PURPLE_COLOR;
    
    UIView *loadingView = [[UIView alloc]initWithFrame:self.view.bounds];
    
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_HORIZONTAL, 100)];
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.center = CGPointMake(CGRectGetMidX(loadingView.bounds), (CGRectGetMidY(loadingView.bounds) + 30));
    loadingLabel.text = NSLocalizedString(@"Generating Punishment Ad", nil) ;
    loadingLabel.font = TWIZ_FONT_500_18;
    loadingLabel.textColor = [UIColor whiteColor];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(CGRectGetMidX(loadingView.bounds), (CGRectGetMidY(loadingView.bounds)-20));
    [spinner startAnimating];
    
    [loadingView addSubview:spinner];
    [loadingView addSubview:loadingLabel];
    self.loadingView = loadingView;
    [self.view addSubview:self.loadingView];

    [self showFullScreenAd];
}

//Interstitial iAd
-(void)showFullScreenAd {
    //Check if already requesting ad
    if (self.requestingAd == NO) {
        
        self.interstitial.delegate = self;
        self.interstitialPresentationPolicy = ADInterstitialPresentationPolicyManual;
        [self requestInterstitialAdPresentation];
        NSLog(@"interstitialAdREQUEST");
        self.requestingAd = YES;
    }//end if
}

-(void)interstitialAd:(ADInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
    self.interstitial = nil;
    self.requestingAd = NO;
    NSLog(@"interstitialAd didFailWithERROR");
    NSLog(@"%@", error);

    [self.loadingView removeFromSuperview];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setFrame:CGRectMake(0, 0, 100, 30)];
    closeButton.center = CGPointMake(CGRectGetMidX(self.view.bounds), (CGRectGetMidY(self.view.bounds) - 10));
    [closeButton setTitle:@"Click to Exit" forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(removeViewController) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *closeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    closeLabel.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    closeLabel.textAlignment = UIControlContentHorizontalAlignmentCenter;
    closeLabel.textColor = [UIColor whiteColor];
    closeLabel.font = TWIZ_FONT_500_18;
    closeLabel.text = @"No ads to show :(";
    
    [self.view addSubview:closeLabel];
    [self.view addSubview:closeButton];
}

-(void)interstitialAdDidLoad:(ADInterstitialAd *)interstitialAd
{
    if ((interstitialAd != nil) && (_interstitial != nil) && (_requestingAd))
    {
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setFrame:CGRectMake(SCREEN_HORIZONTAL - 100, 30, 100, 30)];
        [closeButton setTitle:@"Exit" forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(removeViewController) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *adPlaceholderView = [[UIView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview: adPlaceholderView];
        [_interstitial presentInView: adPlaceholderView];
        [self.view insertSubview:closeButton aboveSubview:adPlaceholderView];
    }
}

-(void)interstitialAdDidUnload:(ADInterstitialAd *)interstitialAd {
    self.interstitial = nil;
    self.requestingAd = NO;
    NSLog(@"interstitialAdDidUNLOAD");
}

-(void)interstitialAdActionDidFinish:(ADInterstitialAd *)interstitialAd {
    self.interstitial = nil;
    self.requestingAd = NO;
    NSLog(@"interstitialAdDidFINISH");
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
