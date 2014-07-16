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
    
    [self.mainView removeFromSuperview];
    
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
        scoreLabel.font = TWIZ_FONT_500_18;
        self.scoreInt = scoreInt;
        self.scoreLabel = scoreLabel;
        [self.navigationController.navigationBar addSubview:self.scoreLabel];
        
#pragma mark - Bottom Buttons
        
        // request button
        UIButton *requestBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        requestBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [requestBtn setTitle:@"Luanch Empty Bucket View" forState:UIControlStateNormal];
        [requestBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        requestBtn.titleLabel.font = TWIZ_FONT_500_18;
        requestBtn.frame = CGRectMake(10.0, self.view.bounds.size.height - 60.0f, self.view.bounds.size.width - 20.0f, 20.0);
        [[requestBtn layer] setCornerRadius:3.0f];
        [[requestBtn layer] setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.1].CGColor];
        [requestBtn addTarget:self action:@selector(ranOutOfTweets) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:requestBtn];
        
        // refresh button
        UIButton *refreshBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        refreshBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [refreshBtn setTitle:@"Refresh Bucket" forState:UIControlStateNormal];
        [refreshBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        refreshBtn.titleLabel.font = TWIZ_FONT_500_18;
        refreshBtn.frame = CGRectMake(10.0, self.view.bounds.size.height - 30.0f, self.view.bounds.size.width - 20.0f, 20.0);
        [[refreshBtn layer] setCornerRadius:3.0f];
        [[refreshBtn layer] setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.1].CGColor];
        [refreshBtn addTarget:self action:@selector(loadTweets) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:refreshBtn];

    }
}

- (void) refreshView{
    self.sidePanelController.centerPanel = [[UINavigationController alloc] initWithRootViewController:[[MyCenterViewController alloc] init]];
    [[MyTwitterController sharedInstance] loadTweetBucketDictionaryWithCompletion:nil];
}

- (void)loadTweets
{
    [[MyTwitterController sharedInstance] loadTweetBucketDictionaryWithCompletion:nil];
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
        UILabel *floatScore = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
        floatScore.backgroundColor = [UIColor whiteColor];
        
    } else {
        NSLog(@"%@ is not equal to %@", selectedAuthorID, correctAuthorID );
        NSInteger oldScore = [self.scoreLabel.text intValue];
        self.scoreInt = oldScore - 1;
        self.scoreLabel.text = [NSString stringWithFormat: @"%d", (int)self.scoreInt];
    }
    [self.mainView removeFromSuperview]; // clears old tweet
    [self resetActiveTweet]; // loads new tweet
}

-(void)buttonHighlight:(id)sender{
    NSLog(@"button should highlight");
    [sender setBackgroundColor:[UIColor whiteColor]];
    
}

- (void)resetActiveTweet
{
    
    self.activeTweet = [[MyTwitterController sharedInstance] requestActiveTweet];
    self.mainView = [[UIView alloc] initWithFrame:self.view.bounds]; // overall view to remove after answer has been selected
    
    // Redraws tweet and possible answers
    self.tweetLabel = [[UITextView alloc]initWithFrame:CGRectMake(10.0, 10.0f, self.view.bounds.size.width - 20.0f, 180.0)];
    [[self.tweetLabel layer] setCornerRadius:3.0f];
    [[self.tweetLabel layer] setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.1].CGColor];
    self.tweetLabel.textColor = [UIColor whiteColor];
    [self.tweetLabel setFont:TWIZ_FONT_500_22];
    self.tweetLabel.textContainer.lineFragmentPadding = 15; //sets left padding
    self.tweetLabel.text = self.activeTweet.tweet;
    
    [self.mainView addSubview:self.tweetLabel];
   

    
#pragma mark - Possible Answers Display
    
    // Possible Answer1
    self.possibleAnswer1 = [[UIButton alloc] initWithFrame:CGRectMake(10.0, 200.0, self.view.bounds.size.width - 20.0f, 48)];
    self.possibleAnswer1.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.2].CGColor;
    self.possibleAnswer1.layer.borderWidth = 1.0f;
    self.possibleAnswer1.layer.cornerRadius = 3.0f;
    [self.possibleAnswer1 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.possibleAnswer1 setTitleEdgeInsets:UIEdgeInsetsMake(0, 50.0f, 0.0f, 0.0f)];
    [self.possibleAnswer1 addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
    [self.possibleAnswer1 setTitle:[[self.activeTweet.possibleAnswers objectAtIndex:0] objectForKey:possibleAnswerAuthorKey] forState:UIControlStateNormal];
    [self.possibleAnswer1 setFont:TWIZ_FONT_300_22];
    self.authorImageView1 = [[UIImageView alloc] initWithImage:[[self.activeTweet.possibleAnswers objectAtIndex:0] objectForKey:possibleAnswerPhotoKey]];
    [self.authorImageView1 setFrame:CGRectMake(9, 9, 30, 30)];
    self.authorImageView1.contentMode = UIViewContentModeScaleAspectFill;

    [self.possibleAnswer1 addSubview:self.authorImageView1];
    [self.possibleAnswer1 addTarget:self action:@selector(answerSelected:) forControlEvents:UIControlEventTouchUpInside];
 
    self.possibleAnswer1.tag = [[self.activeTweet.possibleAnswers objectAtIndex:0] objectForKey:possibleAnswerAuthorKey];
    
    // Possible Answer2
    self.possibleAnswer2 = [[UIButton alloc] initWithFrame:CGRectMake(10.0, 255.0, self.view.bounds.size.width - 20.0f, 48)];
    self.possibleAnswer2.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.2].CGColor;
    self.possibleAnswer2.layer.borderWidth = 1.0f;
    self.possibleAnswer2.layer.cornerRadius = 3.0f;
    [self.possibleAnswer2 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.possibleAnswer2 setTitleEdgeInsets:UIEdgeInsetsMake(0, 50.0f, 0.0f, 0.0f)];
    [self.possibleAnswer2 addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
    [self.possibleAnswer2 setTitle:[[self.activeTweet.possibleAnswers objectAtIndex:1] objectForKey:possibleAnswerAuthorKey] forState:UIControlStateNormal];
    [self.possibleAnswer2 setFont:TWIZ_FONT_300_22];
    self.authorImageView2 = [[UIImageView alloc] initWithImage:[[self.activeTweet.possibleAnswers objectAtIndex:1] objectForKey:possibleAnswerPhotoKey]];
    [self.authorImageView2 setFrame:CGRectMake(9, 9, 30, 30)];
    self.authorImageView2.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.possibleAnswer2 addSubview:self.authorImageView2];
    [self.possibleAnswer2 addTarget:self action:@selector(answerSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    self.possibleAnswer2.tag = [[self.activeTweet.possibleAnswers objectAtIndex:1] objectForKey:possibleAnswerAuthorKey];

    
    // Possible Answer3
    self.possibleAnswer3 = [[UIButton alloc] initWithFrame:CGRectMake(10.0, 310.0, self.view.bounds.size.width - 20.0f, 48)];
    self.possibleAnswer3.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.2].CGColor;
    self.possibleAnswer3.layer.borderWidth = 1.0f;
    self.possibleAnswer3.layer.cornerRadius = 3.0f;
    [self.possibleAnswer3 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.possibleAnswer3 setTitleEdgeInsets:UIEdgeInsetsMake(0, 50.0f, 0.0f, 0.0f)];
    [self.possibleAnswer3 addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
    [self.possibleAnswer3 setTitle:[[self.activeTweet.possibleAnswers objectAtIndex:2] objectForKey:possibleAnswerAuthorKey] forState:UIControlStateNormal];
    [self.possibleAnswer3 setFont:TWIZ_FONT_300_22];
    self.authorImageView3 = [[UIImageView alloc] initWithImage:[[self.activeTweet.possibleAnswers objectAtIndex:2] objectForKey:possibleAnswerPhotoKey]];
    [self.authorImageView3 setFrame:CGRectMake(9, 9, 30, 30)];
    self.authorImageView3.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.possibleAnswer3 addSubview:self.authorImageView3];
    [self.possibleAnswer3 addTarget:self action:@selector(answerSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    self.possibleAnswer3.tag = [[self.activeTweet.possibleAnswers objectAtIndex:2] objectForKey:possibleAnswerAuthorKey];
    
    // Possible Answer4
    self.possibleAnswer4 = [[UIButton alloc] initWithFrame:CGRectMake(10.0, 365.0, self.view.bounds.size.width - 20.0f, 48)];
    self.possibleAnswer4.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.2].CGColor;
    self.possibleAnswer4.layer.borderWidth = 1.0f;
    self.possibleAnswer4.layer.cornerRadius = 3.0f;
    [self.possibleAnswer4 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.possibleAnswer4 setTitleEdgeInsets:UIEdgeInsetsMake(0, 50.0f, 0.0f, 0.0f)];
    [self.possibleAnswer4 addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
    [self.possibleAnswer4 setTitle:[[self.activeTweet.possibleAnswers objectAtIndex:3] objectForKey:possibleAnswerAuthorKey] forState:UIControlStateNormal];
    [self.possibleAnswer4 setFont:TWIZ_FONT_300_22];
    self.authorImageView4 = [[UIImageView alloc] initWithImage:[[self.activeTweet.possibleAnswers objectAtIndex:3] objectForKey:possibleAnswerPhotoKey]];
    [self.authorImageView4 setFrame:CGRectMake(9, 9, 30, 30)];
    self.authorImageView4.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.possibleAnswer4 addSubview:self.authorImageView4];
    [self.possibleAnswer4 addTarget:self action:@selector(answerSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    self.possibleAnswer4.tag = [[self.activeTweet.possibleAnswers objectAtIndex:3] objectForKey:possibleAnswerAuthorKey];
    
    
    [self.mainView addSubview:self.possibleAnswer1]; // adds each answer to the mainView
    [self.mainView addSubview:self.possibleAnswer2];
    [self.mainView addSubview:self.possibleAnswer3];
    [self.mainView addSubview:self.possibleAnswer4];
    
    [self.view addSubview:self.mainView]; // adds mainView to superview so that it can be dismissed yet still keep background

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
