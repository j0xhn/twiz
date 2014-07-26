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
#import "MyEmptyBucketViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "PossibleAnswerBtn.h"


#import "MyTwitterController.h"

@interface MyCenterViewController () <MyTwitterDelegate>

@property (nonatomic, weak) UIButton *refreshBtn;
@property (nonatomic, strong) MyActiveTweet *activeTweet;

@property (nonatomic, strong) UIView *mainView;
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

-(void) ranOutOfTweets{
    // removes views so that they don't overlap upon reload
    [self.mainView removeFromSuperview];
    [self.scoreLabel removeFromSuperview];
    
    MyEmptyBucketViewController *emptyBucketViewController = [[MyEmptyBucketViewController alloc] init];
    emptyBucketViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:emptyBucketViewController animated:YES completion:nil]; // Present Log In View Controller

    
}
#pragma mark - UIViewController


-(void)viewDidLoad{
    [MyTwitterController sharedInstance].delegate = self; // registers this view as the delegate for MyTwitterController
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // creates listener for Twitter Login
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshView)
                                                 name:@"LoginSuccessfulNotification"
                                               object:nil];
    // creates listener for the first time your tweetBucket is finished loading
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetActiveTweet)
                                                 name:@"resetActiveTweetNotification"
                                               object:nil];
    // creates listener for App closing to save info
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveUserInfo)
                                                 name:@"saveUserInfoNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshView)
                                                 name:@"logOutTweetNotification"
                                               object:nil];
    
    

    // Check if user is logged in - commented out during offline development
    if (![PFUser currentUser]) {        
        // Customize the Log In View Controller
        MyLogInViewController *logInViewController = [[MyLogInViewController alloc] init];
        logInViewController.modalTransitionStyle = UIModalTransitionStylePartialCurl;
        logInViewController.delegate = self;
        logInViewController.fields = PFLogInFieldsTwitter;
        // Present Log In View Controller
        [self presentViewController:logInViewController animated:YES completion:NULL];
    } else {
        [[PFUser currentUser] refresh];
        [[MyTwitterController sharedInstance] setCurrentUser];
        // sets image and initial score
        UIImage *currentUserImage = [[MyTwitterController sharedInstance] requestUserImage];
        UIImageView *userImageView = [[UIImageView alloc] initWithImage:currentUserImage];
        [userImageView setFrame:CGRectMake(10,8,25,25)];
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2;
        userImageView.layer.masksToBounds = YES;
        [self.navigationController.navigationBar addSubview:userImageView];
        
        self.scoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(40,6,55,32)];
        NSNumber *userScore = [[MyTwitterController sharedInstance] requestInitialScore];
        self.scoreLabel.text = [userScore stringValue];
        self.scoreLabel.textColor = [UIColor whiteColor];
        self.scoreLabel.font = TWIZ_FONT_500_18;
        [self.mainView addSubview:self.scoreLabel];
        [self.navigationController.navigationBar addSubview:self.scoreLabel];
        
#pragma mark - Bottom Buttons
        
        UIView *loadingView = [[UIView alloc]initWithFrame:CGRectMake((SCREEN_HORIZONTAL - 200)/2, (SCREEN_VERTICAL - 200)/2, 200, 100)];
        
        UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 200, 100)];
        loadingLabel.textAlignment = NSTextAlignmentCenter;
        loadingLabel.text = NSLocalizedString(@"Creating Quiz", nil) ;
        loadingLabel.font = TWIZ_FONT_300_22;
        loadingLabel.textColor = [UIColor whiteColor];

        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        spinner.center = CGPointMake(CGRectGetMidX(loadingView.bounds), CGRectGetMidY(loadingView.bounds));
        [spinner startAnimating];
        
        [loadingView addSubview:spinner];
        [loadingView addSubview:loadingLabel];

        [self.view addSubview:loadingView];
        
        [[MyTwitterController sharedInstance] loadTweetBucketDictionaryWithCompletion:^(bool success) {
                [spinner stopAnimating];
                [loadingView removeFromSuperview];
                dispatch_async(dispatch_get_main_queue(), ^{ // fixes errors it throws that are UI related when reseting Tweet
                    [self resetActiveTweet]; // added because sometimes upon login it wouldn't load tweet
                });
            }];
    }
}

- (void) refreshView{
    self.sidePanelController.centerPanel = [[UINavigationController alloc] initWithRootViewController:[[MyCenterViewController alloc] init]];
}

- (void)loadTweets
{
    [[MyTwitterController sharedInstance] loadTweetBucketDictionaryWithCompletion:nil];
}

#pragma mark - Answer Selected

- (void) answerSelected:(id)sender{
    // initialize everything needed for animation
    PossibleAnswerBtn *selectedAnswerBtn = sender;
    NSString *selectedAuthorID = [selectedAnswerBtn currentTitle];
    NSString *correctAuthorID = self.activeTweet.correctAnswerID;
    UILabel *floatScore = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_HORIZONTAL/2, 30, 50, 50)];
    UIView *correctScoreView = [[UIView alloc] initWithFrame:self.view.bounds];
    UIWindow *mainWindow = [[UIApplication sharedApplication] keyWindow];
    [mainWindow addSubview:correctScoreView];
    
    if([selectedAuthorID isEqualToString:correctAuthorID]){
        
        NSLog(@"%@ is equal to %@", selectedAuthorID, correctAuthorID );
        NSNumber *number = [NSNumber numberWithInt:5];
        self.scoreInt = [[[MyTwitterController sharedInstance] incrementScoreWithNumber:number] intValue];
        self.scoreLabel.text = [NSString stringWithFormat: @"%d", (int)self.scoreInt];

        
    } else {
        
        NSLog(@"%@ is not equal to %@", selectedAuthorID, correctAuthorID );
        NSNumber *number = [NSNumber numberWithInt:-1];
        self.scoreInt = [[[MyTwitterController sharedInstance] incrementScoreWithNumber:number] intValue];
        self.scoreLabel.text = [NSString stringWithFormat: @"%d", (int)self.scoreInt];

    }
    
    // set general animations
    
    [correctScoreView addSubview:selectedAnswerBtn];
    self.mainView.alpha = .6;

    [UIView animateWithDuration:1 delay:.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // set animations that move
        [selectedAnswerBtn.possibleAnswerPoints setHidden:(false)];
        [selectedAnswerBtn.possibleAnswerPoints setCenter:CGPointMake((SCREEN_HORIZONTAL/2),-30)];
    } completion:^(BOOL finished) {
        [correctScoreView removeFromSuperview];
        [self resetActiveTweet]; // loads new tweet
    }];
    
   
}

- (void)resetActiveTweet
{
    [self.mainView removeFromSuperview]; // clears old tweet
    self.activeTweet = [[MyTwitterController sharedInstance] requestActiveTweet];
    self.mainView = [[UIView alloc] initWithFrame:self.view.bounds]; // overall view to remove after answer has been selected

    // Redraws tweet and possible answers

    self.tweetLabel = [[UITextView alloc]initWithFrame:CGRectMake(10.0, 10.0f, self.view.bounds.size.width - 20.0f, 200.0)];
    [[self.tweetLabel layer] setCornerRadius:3.0f];
    [[self.tweetLabel layer] setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.1].CGColor];
    self.tweetLabel.textColor = [UIColor whiteColor];
    [self.tweetLabel setFont:TWIZ_FONT_500_22];
    self.tweetLabel.textContainer.lineFragmentPadding = 15;
    self.tweetLabel.text = self.activeTweet.tweet;
    
    [self.mainView addSubview:self.tweetLabel];

    
#pragma mark - Possible Answers Display
    
    // Possible Answer1
    PossibleAnswerBtn *possibleAnswer1 = [[PossibleAnswerBtn alloc] initWithFrame:CGRectMake(10.0, 220.0, self.view.bounds.size.width - 20.0f, 48)];
    [possibleAnswer1 setTitle:[[self.activeTweet.possibleAnswers objectAtIndex:0] objectForKey:possibleAnswerAuthorKey] forState:UIControlStateNormal];
    
    possibleAnswer1.possibleAnswerPoints.text =  [[[self.activeTweet.possibleAnswers objectAtIndex:0] objectForKey:tweetPointsKey] stringValue];
    possibleAnswer1.possibleAnswerImage.image = [[self.activeTweet.possibleAnswers objectAtIndex:0] objectForKey:possibleAnswerPhotoKey];
    [possibleAnswer1 addTarget:self action:@selector(answerSelected:) forControlEvents:UIControlEventTouchUpInside];
    possibleAnswer1.tag = [[self.activeTweet.possibleAnswers objectAtIndex:0] objectForKey:possibleAnswerAuthorKey];
    
    // Possible Answer2
    PossibleAnswerBtn *possibleAnswer2 = [[PossibleAnswerBtn alloc] initWithFrame:CGRectMake(10.0, 275.0, self.view.bounds.size.width - 20.0f, 48)];
    [possibleAnswer2 setTitle:[[self.activeTweet.possibleAnswers objectAtIndex:1] objectForKey:possibleAnswerAuthorKey] forState:UIControlStateNormal];
    possibleAnswer2.possibleAnswerImage.image = [[self.activeTweet.possibleAnswers objectAtIndex:1] objectForKey:possibleAnswerPhotoKey];
    possibleAnswer2.possibleAnswerPoints.text =  [[[self.activeTweet.possibleAnswers objectAtIndex:1] objectForKey:tweetPointsKey] stringValue];
    [possibleAnswer2 addTarget:self action:@selector(answerSelected:) forControlEvents:UIControlEventTouchUpInside];
    possibleAnswer2.tag = [[self.activeTweet.possibleAnswers objectAtIndex:1] objectForKey:possibleAnswerAuthorKey];
    
    // Possible Answer3
    PossibleAnswerBtn *possibleAnswer3 = [[PossibleAnswerBtn alloc] initWithFrame:CGRectMake(10.0, 330.0, self.view.bounds.size.width - 20.0f, 48)];
    [possibleAnswer3 setTitle:[[self.activeTweet.possibleAnswers objectAtIndex:2] objectForKey:possibleAnswerAuthorKey] forState:UIControlStateNormal];
    possibleAnswer3.possibleAnswerPoints.text =  [[[self.activeTweet.possibleAnswers objectAtIndex:2] objectForKey:tweetPointsKey] stringValue];
    possibleAnswer3.possibleAnswerImage.image = [[self.activeTweet.possibleAnswers objectAtIndex:2] objectForKey:possibleAnswerPhotoKey];
    [possibleAnswer3 addTarget:self action:@selector(answerSelected:) forControlEvents:UIControlEventTouchUpInside];
    possibleAnswer3.tag = [[self.activeTweet.possibleAnswers objectAtIndex:2] objectForKey:possibleAnswerAuthorKey];
    
    // Possible Answer4
    PossibleAnswerBtn *possibleAnswer4 = [[PossibleAnswerBtn alloc] initWithFrame:CGRectMake(10.0, 385.0, self.view.bounds.size.width - 20.0f, 48)];
    [possibleAnswer4 setTitle:[[self.activeTweet.possibleAnswers objectAtIndex:3] objectForKey:possibleAnswerAuthorKey] forState:UIControlStateNormal];
    possibleAnswer4.possibleAnswerPoints.text =  [[[self.activeTweet.possibleAnswers objectAtIndex:3] objectForKey:tweetPointsKey] stringValue];
    possibleAnswer4.possibleAnswerImage.image = [[self.activeTweet.possibleAnswers objectAtIndex:3] objectForKey:possibleAnswerPhotoKey];
    [possibleAnswer4 addTarget:self action:@selector(answerSelected:) forControlEvents:UIControlEventTouchUpInside];
    possibleAnswer4.tag = [[self.activeTweet.possibleAnswers objectAtIndex:3] objectForKey:possibleAnswerAuthorKey];
    
    // skip button
    UIButton *refreshBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    refreshBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [refreshBtn setTitle:NSLocalizedString(@"Skip", nil) forState:UIControlStateNormal];
    [refreshBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    refreshBtn.titleLabel.font = TWIZ_FONT_300_30;
    refreshBtn.frame = CGRectMake(10.0, self.view.bounds.size.height - 60.0f, self.view.bounds.size.width - 20.0f, 50.0);
    [[refreshBtn layer] setCornerRadius:3.0f];
    [[refreshBtn layer] setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.1].CGColor];
    [refreshBtn addTarget:self action:@selector(resetActiveTweet) forControlEvents:UIControlEventTouchUpInside];
    
    [self.mainView addSubview:refreshBtn];
    
    [self.mainView addSubview:possibleAnswer1]; // adds each answer to the mainView
    [self.mainView addSubview:possibleAnswer2];
    [self.mainView addSubview:possibleAnswer3];
    [self.mainView addSubview:possibleAnswer4];
    
    [self.view addSubview:self.mainView]; // adds mainView to superview so that it can be dismissed yet still keep background

}

- (void) saveUserInfo{
    
    [[MyTwitterController sharedInstance] saveUserInfo];

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
    [PFUser logOut];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
