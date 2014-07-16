//
//  MyLogInViewController.m
//  LogInAndSignUpDemo
//
//  Created by Mattieu Gamache-Asselin on 6/15/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//
#import "MyLogInViewController.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "MyCenterViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MyTwitterController.h"
#import "MyConstants.h"

@interface MyLogInViewController ()

@end

@implementation MyLogInViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.logInView setBackgroundColor:[UIColor colorWithPatternImage:PURPLE_BACKGROUND]];
    
    // if 'nil' not selected it will bring up Parse Logo
    [self.logInView setLogo:[UIImage imageNamed:nil]];
    // removes pre-made twitter button
    [self.logInView.twitterButton removeFromSuperview];
    
    UILabel *logoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, self.view.bounds.size.width, 40)];
    logoLabel.text = @"TWIZ";
    logoLabel.textColor = [UIColor whiteColor];
    logoLabel.textAlignment = NSTextAlignmentCenter;
    UIFont *museoTitleFont = [UIFont fontWithName:@"MuseoSansRounded-900" size:40.0];
    logoLabel.font = museoTitleFont;
    logoLabel.textAlignment = NSTextAlignmentCenter;
    [self.logInView addSubview:logoLabel];
    
    // tagline
    UILabel *taglineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 240, self.view.bounds.size.width, 40)];
    taglineLabel.text = @"the twitter quiz game";
    taglineLabel.textColor = [UIColor whiteColor];
    taglineLabel.textAlignment = NSTextAlignmentCenter;
    
    UIFont *museoTagLineFont = [UIFont fontWithName:@"MuseoSansRounded-300" size:14.0];
    taglineLabel.font = museoTagLineFont;
    taglineLabel.textAlignment = NSTextAlignmentCenter;
    [self.logInView addSubview:taglineLabel];
    
    // makes my custom button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(twitterSignIn)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Login with Twitter" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIFont *museoButtonFont = [UIFont fontWithName:@"MuseoSansRounded-500" size:18.0];
    [button setFont:museoButtonFont];
    button.frame = CGRectMake(60.0, 287.0, 200.0, 40.0);
    [[button layer] setCornerRadius:5.0f];
    [[button layer] setBorderWidth:1.0f];
    [[button layer] setBorderColor:[UIColor whiteColor].CGColor];
    [self.view addSubview:button];

}

-(BOOL) twitterSignIn {
    NSLog(@"You Clicked Sign In");
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Twitter login.");
            return;
        } else if (user.isNew) {
            // give intro run through here, or welcome message
            NSURL *verify = [NSURL URLWithString:@"https://api.twitter.com/1.1/account/verify_credentials.json"];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:verify];
            [[PFTwitterUtils twitter] signRequest:request];
            NSURLResponse *response = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&response
                                                             error:&error];
            NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            NSLog(@"%@",result);
            
            [user setObject:[result objectForKey:@"profile_image_url_https"]
                     forKey:@"picture"];
            // does this thing help?
            [user setUsername:[result objectForKey:@"screen_name"]];
            
            NSString * names = [result objectForKey:@"name"];
            NSMutableArray * array = [NSMutableArray arrayWithArray:[names componentsSeparatedByString:@" "]];
            if ( array.count > 1){
                [user setObject:[array lastObject]
                         forKey:@"last_name"];
                
                [array firstObject];
                [user setObject:[array componentsJoinedByString:@" " ]
                         forKey:@"first_name"];
            }
            
            [user saveInBackground];
            [PFUser currentUser];
            NSLog(@"username:%@", user.username);
            [[MyTwitterController sharedInstance] setCurrentUserScreenName:user.username];
            [self dismissViewControllerAnimated:YES completion:NULL];
            // Q:2 doesn't refresh the view upon login
            
        } else {
            
            NSLog(@"signin Sucessfull");
            NSLog(@"username:%@", user.username);
            [[MyTwitterController sharedInstance] setCurrentUserScreenName:user.username];
//            [[MyTwitterController sharedInstance] requestTweetBucketDictionary];
            [self dismissViewControllerAnimated:YES completion:NULL];
            // Q:2 doesn't refresh the view upon login

        }
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"LoginSuccessfulNotification"
         object:nil];
    }];
    return YES;
}
- (void)loadTweets
{
    [[MyTwitterController sharedInstance] loadTweetBucketDictionaryWithCompletion:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
