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
#import "MyActiveTweet.h"
#import "MyConstants.h"

#import "MyTwitterController.h"

@interface MyCenterViewController ()

@property (nonatomic, weak) UIButton *refreshBtn;
@property (nonatomic, strong) MyActiveTweet *activeTweet;

@property (nonatomic, strong) UITextView *tweetLabel;
@property (nonatomic,strong) UILabel *scoreLabel;
@property (nonatomic,assign) NSInteger scoreInt;

@property (nonatomic, strong) UIButton *possibleAnswer1;
@property (nonatomic, strong) UILabel *author1;
@property (nonatomic,strong) UIImageView *authorImageView1;

@property (nonatomic, strong) UIButton *possibleAnswer2;
@property (nonatomic, strong) UILabel *author2;
@property (nonatomic, strong) UIImageView *authorImageView2;

@property (nonatomic, strong) UIButton *possibleAnswer3;
@property (nonatomic, strong) UILabel *author3;
@property (nonatomic, strong) UIImageView *authorImageView3;

@property (nonatomic, strong) UIButton *possibleAnswer4;
@property (nonatomic, strong) UILabel *author4;
@property (nonatomic, strong) UIImageView *authorImageView4;


@end

@implementation MyCenterViewController

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - UIViewController


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIFont *museoButtonFont500_18 = [UIFont fontWithName:@"MuseoSansRounded-500" size:18.0];
    UIFont *museoButtonFont500_22 = [UIFont fontWithName:@"MuseoSansRounded-500" size:22.0];
    UIFont *museoButtonFont300_30 = [UIFont fontWithName:@"MuseoSansRounded-300" size:30.0];
    UIFont *museoButtonFont300_22 = [UIFont fontWithName:@"MuseoSansRounded-300" size:22.0];
    // Check if user is logged in - commented out during offline development
    if (![PFUser currentUser]) {        
        // Customize the Log In View Controller
        MyLogInViewController *logInViewController = [[MyLogInViewController alloc] init];
        logInViewController.modalTransitionStyle = UIModalTransitionStylePartialCurl;
        logInViewController.delegate = self;
        logInViewController.fields =   PFLogInFieldsTwitter;
        // Present Log In View Controller
        [self presentViewController:logInViewController animated:YES completion:NULL];
    } else {

        // makes score button
        UILabel *scoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(20,6,55,32)];
        NSInteger scoreInt = 0;
        scoreLabel.text = [NSString stringWithFormat: @"%d", (int)scoreInt];
        scoreLabel.textColor = [UIColor whiteColor];
        scoreLabel.font = [UIFont fontWithName:@"MuseoSansRounded-500" size:16];
        self.scoreInt = scoreInt;
        self.scoreLabel = scoreLabel;
        [self.navigationController.navigationBar addSubview:self.scoreLabel];
        
        // Tweet Display
        UITextView *tweetLabel = [[UITextView alloc]initWithFrame:CGRectMake(10.0, 10.0f, self.view.bounds.size.width - 20.0f, 180.0)];
        [[tweetLabel layer] setCornerRadius:3.0f];
        [[tweetLabel layer] setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.1].CGColor];
        tweetLabel.textColor = [UIColor whiteColor];
        [tweetLabel setFont:museoButtonFont500_22];
        //sets left padding
        tweetLabel.textContainer.lineFragmentPadding = 15;
        tweetLabel.text = @"Being able to express yourself, clearly and forcefully, in less than the 140 characters is actually a really good thing to learn.  #twitter";
        self.tweetLabel = tweetLabel;
        [self.view addSubview:self.tweetLabel];
    
#pragma mark - Possible Answers Display
    
        // Possible Answer1
        UIButton *possibleAnswer1 = [[UIButton alloc] initWithFrame:CGRectMake(10.0, 200.0, self.view.bounds.size.width - 20.0f, 48)];
        possibleAnswer1.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.2].CGColor;
        possibleAnswer1.layer.borderWidth = 1.0f;
        possibleAnswer1.layer.cornerRadius = 3.0f;
        [possibleAnswer1 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [possibleAnswer1 setTitleEdgeInsets:UIEdgeInsetsMake(0, 50.0f, 0.0f, 0.0f)];
        UIImage *authorImage1 = [UIImage imageNamed:@"johnD.png"];
        UIImageView *authorImageView1 = [[UIImageView alloc] initWithImage:authorImage1];
        [authorImageView1 setFrame:CGRectMake(9, 9, 30, 30)];
        authorImageView1.contentMode = UIViewContentModeScaleAspectFill;
        self.authorImageView1 = authorImageView1;
        
        [possibleAnswer1 setTitle:@"button title" forState:UIControlStateNormal];
        [possibleAnswer1 setFont:museoButtonFont300_22];
        
        
        [possibleAnswer1 addSubview:self.authorImageView1];
        [possibleAnswer1 addTarget:self action:@selector(answerSelected:) forControlEvents:UIControlEventTouchUpInside];
        self.possibleAnswer1 = possibleAnswer1;
        
        // Possible Answer2
        UIView *possibleAnswer2 = [[UIView alloc] initWithFrame:CGRectMake(10.0, 255.0, self.view.bounds.size.width - 20.0f, 48)];
        possibleAnswer2.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.5].CGColor;
        possibleAnswer2.layer.borderWidth = 1.0f;
        possibleAnswer2.layer.cornerRadius = 3.0f;
        UIImage *authorImage2 = [UIImage imageNamed:@"johnD.png"];
        UIImageView *authorImageView2 = [[UIImageView alloc] initWithImage:authorImage2];
        [authorImageView2 setFrame:CGRectMake(9, 9, 30, 30)];
        authorImageView2.contentMode = UIViewContentModeScaleAspectFill;
        self.authorImageView2 = authorImageView2;
        
        
        UILabel *author2 = [[UILabel alloc] initWithFrame:CGRectMake(50, 2, 250, 40)];
        author2.textColor = [UIColor whiteColor];
        author2.text = @"sample author";
        [author2 setFont:museoButtonFont300_30];
        self.author2 = author2;
        
        [possibleAnswer2 addSubview:self.authorImageView2];
        [possibleAnswer2 addSubview:self.author2];
        
        // Possible Answer3
        UIView *possibleAnswer3 = [[UIView alloc] initWithFrame:CGRectMake(10.0, 310.0, self.view.bounds.size.width - 20.0f, 48)];
        possibleAnswer3.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.5].CGColor;
        possibleAnswer3.layer.borderWidth = 1.0f;
        possibleAnswer3.layer.cornerRadius = 3.0f;
        UIImage *authorImage3 = [UIImage imageNamed:@"johnD.png"];
        UIImageView *authorImageView3 = [[UIImageView alloc] initWithImage:authorImage3];
        [authorImageView3 setFrame:CGRectMake(9, 9, 30, 30)];
        authorImageView3.contentMode = UIViewContentModeScaleAspectFill;
        self.authorImageView3 = authorImageView3;
        
        
        UILabel *author3 = [[UILabel alloc] initWithFrame:CGRectMake(50, 2, 250, 40)];
        author3.textColor = [UIColor whiteColor];
        author3.text = @"sample author";
        [author3 setFont:museoButtonFont300_30];
        self.author3 = author3;
        
        [possibleAnswer3 addSubview:self.authorImageView3];
        [possibleAnswer3 addSubview:self.author3];
        
        // Possible Answer4
        UIView *possibleAnswer4 = [[UIView alloc] initWithFrame:CGRectMake(10.0, 365.0, self.view.bounds.size.width - 20.0f, 48)];
        possibleAnswer4.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.5].CGColor;
        possibleAnswer4.layer.borderWidth = 1.0f;
        possibleAnswer4.layer.cornerRadius = 3.0f;
        UIImage *authorImage4 = [UIImage imageNamed:@"johnD.png"];
        UIImageView *authorImageView4 = [[UIImageView alloc] initWithImage:authorImage4];
        [authorImageView4 setFrame:CGRectMake(9, 9, 30, 30)];
        authorImageView4.contentMode = UIViewContentModeScaleAspectFill;
        self.authorImageView4 = authorImageView4;
        
        
        UILabel *author4 = [[UILabel alloc] initWithFrame:CGRectMake(50, 2, 250, 40)];
        author4.textColor = [UIColor whiteColor];
        author4.text = @"sample author";
        [author4 setFont:museoButtonFont300_30];
        self.author4 = author4;
        
        [possibleAnswer4 addSubview:self.authorImageView4];
        [possibleAnswer4 addSubview:self.author4];
        
        
        [self.view addSubview:self.possibleAnswer1];
        [self.view addSubview:possibleAnswer2];
        [self.view addSubview:possibleAnswer3];
        [self.view addSubview:possibleAnswer4];
        
#pragma mark - Bottom Buttons
        
        // request button
        UIButton *requestBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        requestBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [requestBtn setTitle:@"Refresh Active Tweet" forState:UIControlStateNormal];
        [requestBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        requestBtn.titleLabel.font = museoButtonFont500_18;
        requestBtn.frame = CGRectMake(10.0, self.view.bounds.size.height - 60.0f, self.view.bounds.size.width - 20.0f, 20.0);
        [[requestBtn layer] setCornerRadius:3.0f];
        [[requestBtn layer] setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.1].CGColor];
        [requestBtn addTarget:self action:@selector(requestActiveTweet) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:requestBtn];
        
        // refresh button
        UIButton *refreshBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        refreshBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [refreshBtn setTitle:@"Refresh Bucket" forState:UIControlStateNormal];
        [refreshBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        refreshBtn.titleLabel.font = museoButtonFont500_18;
        refreshBtn.frame = CGRectMake(10.0, self.view.bounds.size.height - 30.0f, self.view.bounds.size.width - 20.0f, 20.0);
        [[refreshBtn layer] setCornerRadius:3.0f];
        [[refreshBtn layer] setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.1].CGColor];
        [refreshBtn addTarget:self action:@selector(loadTweets) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:refreshBtn];

    }
}

- (void) refreshView{
    self.sidePanelController.centerPanel = [[UINavigationController alloc] initWithRootViewController:[[MyCenterViewController alloc] init]];
}

- (void)loadTweets
{
    [[MyTwitterController sharedInstance] loadTweetBucketDictionary];
}

#pragma mark - Answer Selected

- (void) answerSelected:(id)sender{
    NSString *selectedAuthorID = [(UIButton *)sender currentTitle];
    NSString *correctAuthorID = self.activeTweet.correctAnswerID;
    
    if([selectedAuthorID isEqualToString:correctAuthorID]){
        NSLog(@"%@ is equal to %@", selectedAuthorID, correctAuthorID );
        NSInteger oldScore = [self.scoreLabel.text intValue];
        self.scoreInt = oldScore + 10;
        self.scoreLabel.text = [NSString stringWithFormat: @"%d", (int)self.scoreInt];
        
    } else {
        NSLog(@"%@ is not equal to %@", selectedAuthorID, correctAuthorID );
        NSInteger oldScore = [self.scoreLabel.text intValue];
        self.scoreInt = oldScore - 1;
        self.scoreLabel.text = [NSString stringWithFormat: @"%d", (int)self.scoreInt];
    }

    [self requestActiveTweet]; // loads new tweet
}

- (void)requestActiveTweet
{
    self.activeTweet = [[MyTwitterController sharedInstance] requestActiveTweet];
    self.tweetLabel.text = self.activeTweet.tweet;
    
    [self.possibleAnswer1 setTitle:[[self.activeTweet.possibleAnswers objectAtIndex:0] objectForKey:possibleAnswerAuthorKey] forState:UIControlStateNormal];
//    self.possibleAnswer1.titleLabel.text = [[self.activeTweet.possibleAnswers objectAtIndex:0] objectForKey:possibleAnswerAuthorKey];
    self.authorImageView1.image = [[self.activeTweet.possibleAnswers objectAtIndex:0] objectForKey:possibleAnswerPhotoKey];
    self.possibleAnswer1.tag = [[self.activeTweet.possibleAnswers objectAtIndex:0] objectForKey:possibleAnswerAuthorKey];
    
    
    self.author2.text = [[self.activeTweet.possibleAnswers objectAtIndex:1] objectForKey:possibleAnswerAuthorKey];
    self.authorImageView2.image = [[self.activeTweet.possibleAnswers objectAtIndex:1] objectForKey:possibleAnswerPhotoKey];
    
    self.author3.text = [[self.activeTweet.possibleAnswers objectAtIndex:2] objectForKey:possibleAnswerAuthorKey];
    self.authorImageView3.image = [[self.activeTweet.possibleAnswers objectAtIndex:2] objectForKey:possibleAnswerPhotoKey];
    
    self.author4.text = [[self.activeTweet.possibleAnswers objectAtIndex:3] objectForKey:possibleAnswerAuthorKey];
    self.authorImageView4.image = [[self.activeTweet.possibleAnswers objectAtIndex:3] objectForKey:possibleAnswerPhotoKey];
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
    [self.sidePanelController showCenterPanelAnimated:YES];
//    [PFUser logOut];
//    [self.navigationController popViewControllerAnimated:YES];
}

@end
