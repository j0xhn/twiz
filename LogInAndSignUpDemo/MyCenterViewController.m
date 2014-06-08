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

@interface MyCenterViewController ()

- (void) refreshView;
@property (nonatomic, weak) UIButton *refreshBtn;

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

        // sets username
        UILabel *userName = [[UILabel alloc]initWithFrame:CGRectMake(10, 100, self.view.bounds.size.width, 40)];
        userName.text = [NSString stringWithFormat:NSLocalizedString(@"Welcome %@!", nil), [[PFUser currentUser] username]];
        [self.view addSubview:userName];
        
        // Tweet Display
        UITextView *tweetLabel = [[UITextView alloc]initWithFrame:CGRectMake(10.0, 10.0f, self.view.bounds.size.width - 20.0f, 180.0)];
        [[tweetLabel layer] setCornerRadius:3.0f];
        [[tweetLabel layer] setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.1].CGColor];
        tweetLabel.textColor = [UIColor whiteColor];
        UIFont *museoButtonFont50022 = [UIFont fontWithName:@"MuseoSansRounded-500" size:22.0];
        [tweetLabel setFont:museoButtonFont50022];
        //sets left padding
        tweetLabel.textContainer.lineFragmentPadding = 15;
        tweetLabel.text = @"Being able to express yourself, clearly and forcefully, in less than the 140 characters is actually a really good thing to learn.  #learning";
        [self.view addSubview:tweetLabel];
        
        // refresh button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [button setTitle:@"Refresh" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        UIFont *museoButtonFont500 = [UIFont fontWithName:@"MuseoSansRounded-500" size:18.0];
        [button setFont:museoButtonFont500];
        button.frame = CGRectMake(10.0, self.view.bounds.size.height - 50.0f, self.view.bounds.size.width - 20.0f, 40.0);
        [[button layer] setCornerRadius:3.0f];
        [[button layer] setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.1].CGColor];
        [button addTarget:self action:@selector(loadTweets) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        self.refreshBtn = button;
    }
}
//  here I need it to not exactly create a new instance of the controller, but just refreash the existing view.  Or do you think it's a better pattern to create a new view to initiate after the "LoginSuccessfulNotification" is called Q:2 what's the correct pattern for this?

//  Q:3 should I be setting all the login for setting labels, buttons, etc... in this view so they just automatically get called once the login comes back successfull?  This however would mean I need to do it outside of the function as well because it wouldn't naturally do it everytime I answer a question or it logs in with a user from the initial screen (like a 'remember me' user that hasn't logged out. Or I could keep all the logic inside of my refreshView and just call that meathod upon viewDidLoad.  I guess most of my questions are on data structure and where it is most appropriate to call which functions.

// A:2 I ended up just dismissing the viewcontroller in the LoginViewController, transitioning back to the center, and create a new instance of the view controller.
- (void) refreshView{
    NSLog(@"You want to refresh view");
    self.sidePanelController.centerPanel = [[UINavigationController alloc] initWithRootViewController:[[MyCenterViewController alloc] init]];
}

- (void)loadTweets
{
    NSString *bodyString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=johnDANGRstorey&count=2"];
    
    NSURL *url = [NSURL URLWithString:bodyString];
    NSMutableURLRequest *tweetRequest = [NSMutableURLRequest requestWithURL:url];
    
    [[PFTwitterUtils twitter] signRequest:tweetRequest];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    // Post status synchronously - TODO: change to Asynch
    NSData *data = [NSURLConnection sendSynchronousRequest:tweetRequest
                                         returningResponse:&response
                                                     error:&error];
    
    // Handle response.
    if (!error) {
        NSLog(@"Response: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    } else {
        NSLog(@"Error: %@", error);
    }
    


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
