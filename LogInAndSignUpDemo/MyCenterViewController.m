//
//  SubclassConfigViewController.m
//  LogInAndSignUpDemo
//
//  Created by Mattieu Gamache-Asselin on 6/15/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "MyCenterViewController.h"
#import "MyLogInViewController.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"

#import "MyTwitterController.h"

@interface MyCenterViewController ()

@property (nonatomic, weak) UIButton *refreshBtn;
@property (nonatomic, strong) NSDictionary *activeTweet;
@property (nonatomic, strong) UITextView *tweetLabel;

@end

@implementation MyCenterViewController

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewDidLoad:(BOOL)animated{ // loaded once

    
}


#pragma mark - UIViewController
- (void) viewWillAppear:(BOOL)animated{ // loaded everytime view is about to appear

    // Navigation Bar
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"MainBG.png"]]];
    self.title = @"Twiz";
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:49.0f/255.0f green:35.0f/255.0f blue:105.0f/255.0f alpha:1.0f];
    self.navigationController.navigationBar.translucent = NO;
    //  [self.navigationController.navigationBar setFrame:CGRectMake(0, 0, 320, 14)];
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSFontAttributeName: [UIFont fontWithName:@"MuseoSansRounded-900" size:24],
                                                                      NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                      }];
    

    // creates listener for Twitter Login
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshView)
                                                 name:@"LoginSuccessfulNotification"
                                               object:nil];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    // Check if user is logged in
    if (![PFUser currentUser]) {        
        // Customize the Log In View Controller
        MyLogInViewController *logInViewController = [[MyLogInViewController alloc] init];
        logInViewController.modalTransitionStyle = UIModalTransitionStylePartialCurl;
        logInViewController.delegate = self;
        logInViewController.fields =   PFLogInFieldsTwitter;
        // Present Log In View Controller
        [self presentViewController:logInViewController animated:YES completion:NULL];
    } else {
        // works only if you login, then close app and login, not after information is actually sent to twitter, then redirects you back up to top 'viewWillAppear' method.. so now I'm going to create a listener to listen for login and refreash page so that the correct view comes in
        
        // makes score button
        UILabel *scoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(20,6,55,32)];
        scoreLabel.text = @"100";
        scoreLabel.textColor = [UIColor whiteColor];
        scoreLabel.font = [UIFont fontWithName:@"MuseoSansRounded-500" size:16];
        [self.navigationController.navigationBar addSubview:scoreLabel];
        
        // Tweet Display
        UITextView *tweetLabel = [[UITextView alloc]initWithFrame:CGRectMake(10.0, 10.0f, self.view.bounds.size.width - 20.0f, 180.0)];
        [[tweetLabel layer] setCornerRadius:3.0f];
        [[tweetLabel layer] setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.1].CGColor];
        tweetLabel.textColor = [UIColor whiteColor];
        UIFont *museoButtonFont50022 = [UIFont fontWithName:@"MuseoSansRounded-500" size:22.0];
        [tweetLabel setFont:museoButtonFont50022];
        //sets left padding
        tweetLabel.textContainer.lineFragmentPadding = 15;
        tweetLabel.text = @"Being able to express yourself, clearly and forcefully, in less than the 140 characters is actually a really good thing to learn.  #twitter";
        self.tweetLabel = tweetLabel;
        [self.view addSubview:self.tweetLabel];
        
        // request button
        UIButton *requestBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        requestBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [requestBtn setTitle:@"Refresh Active Tweet" forState:UIControlStateNormal];
        [requestBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        UIFont *museoButtonFont500 = [UIFont fontWithName:@"MuseoSansRounded-500" size:18.0];
        [requestBtn setFont:museoButtonFont500];
        requestBtn.frame = CGRectMake(10.0, self.view.bounds.size.height - 100.0f, self.view.bounds.size.width - 20.0f, 40.0);
        [[requestBtn layer] setCornerRadius:3.0f];
        [[requestBtn layer] setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.1].CGColor];
        [requestBtn addTarget:self action:@selector(requestActiveTweet) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:requestBtn];
        
        // refresh button
        UIButton *refreshBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        refreshBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [refreshBtn setTitle:@"Refresh Bucket" forState:UIControlStateNormal];
        [refreshBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [refreshBtn setFont:museoButtonFont500];
        refreshBtn.frame = CGRectMake(10.0, self.view.bounds.size.height - 50.0f, self.view.bounds.size.width - 20.0f, 40.0);
        [[refreshBtn layer] setCornerRadius:3.0f];
        [[refreshBtn layer] setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.1].CGColor];
        [refreshBtn addTarget:self action:@selector(loadTweets) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:refreshBtn];

    }
}

- (void) refreshView{
    NSLog(@"You want to refresh view - from CenterViewController");
    self.sidePanelController.centerPanel = [[UINavigationController alloc] initWithRootViewController:[[MyCenterViewController alloc] init]];
}

- (void)loadTweets
{
    NSLog(@"You want to load tweets - from CenterViewController");
    NSString *userName = [NSString stringWithFormat:[[PFUser currentUser] username]];
    // Q1: Now after turning it into a instance method I can't call it on the class anymore.  What is the correct model for this?  Is this why we create those [sharedInstance] type of controllers?  Or should I just create an instance of "MyTwitterController" when the view initializes.  That seems to me to be wrong....
//    [MyTwitterController requestTweetBucketDictionary:(NSString *)userName];

}

- (void)requestActiveTweet
{
    NSLog(@"You want to request active with answers tweet - from CenterViewController");
    self.activeTweet = [MyTwitterController requestActiveTweet];
    self.tweetLabel.text = [self.activeTweet objectForKey:@"tweetText"];
}

#pragma mark - PFLogInViewControllerDelegate

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    if (username && password && username.length && password.length) {
        return YES;
    }
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    return NO;
}

// Sent to the delegate when a PFUser is logged in... not working
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    NSLog(@"User dismissed the logInViewController");
}


#pragma mark - PFSignUpViewControllerDelegate

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) {
            informationComplete = NO;
            break;
        }
    }
    
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}


#pragma mark - ()

- (IBAction)logOutButtonTapAction:(id)sender {
    [PFUser logOut];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
