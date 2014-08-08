//  
//  SubclassConfigViewController.m
//  Twiz
//
//  Created from LogInAndSignUpDemo via Parse
//  Copyright (c) 2014 John D. Storey. All rights reserved.
//

#import "MyCenterViewController.h"
#import "MyLogInViewController.h"
#import "MyInterstatialAdViewController.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"
#import "MyActiveTweet.h"
#import "MyConstants.h"
#import "MyEmptyBucketViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "PossibleAnswerBtn.h"
#import "UIImageView+AFNetworking.h"
#import <iAd/iAd.h>
#import <UIKit/UIKit.h>

#import "MyTwitterController.h"

@interface MyCenterViewController () <MyTwitterDelegate>

@property (nonatomic, strong) MyActiveTweet *activeTweet;
@property (nonatomic, strong) PossibleAnswerBtn *possibleAnswer1;
@property (nonatomic, strong) PossibleAnswerBtn *possibleAnswer2;
@property (nonatomic, strong) PossibleAnswerBtn *possibleAnswer3;
@property (nonatomic, strong) PossibleAnswerBtn *possibleAnswer4;
@property (nonatomic, weak) UIButton *refreshBtn;

@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UITextView *tweetLabel;
@property (nonatomic,strong) UILabel *scoreLabel;
@property (nonatomic,assign) NSInteger scoreInt;

@property (nonatomic, assign) BOOL isIphone4;
@property (nonatomic, assign) CGFloat heightScaleFactor;
@property (nonatomic, assign) CGFloat additionalForSmall;

@property (nonatomic, assign) NSInteger wrongAnswerCount;

@end

@implementation MyCenterViewController

- (void) dealloc //Q:3 Do I need this?
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) ranOutOfTweets{

    MyEmptyBucketViewController *emptyBucketViewController = [[MyEmptyBucketViewController alloc] init];
    emptyBucketViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:emptyBucketViewController animated:YES completion:nil]; // Present Log In View Controller
    
    emptyBucketViewController.onButtonPress = ^{
        [[MyTwitterController sharedInstance] loadTweetBucketDictionaryWithCompletion:^(bool success) {
            if (success) { // on success
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self resetActiveTweet];
                });
                
                [self dismissViewControllerAnimated:YES completion:nil];

            } else { // on error
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Not Quite Yet"
                                                                  message:@"Looks like you're twitter feed still hasn't refreashed.  Try back again in 30 minutes."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
                [message show];
            }
        }];
    };
}

-(void)viewDidLoad{
    [MyTwitterController sharedInstance].delegate = self; // registers this view as the delegate for MyTwitterController

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
    // creates listener for App logout
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshView)
                                                 name:@"logOutTweetNotification"
                                               object:nil];
    
    // sets height factor to work accross versions 4 and 5
    NSInteger height = [[UIScreen mainScreen] bounds].size.height;
    if (height > 560) {
        self.heightScaleFactor = 1;
        self.additionalForSmall = 0;
    } else {
        self.heightScaleFactor = .845;
        self.additionalForSmall = 10;
        self.isIphone4 = TRUE;
    }
    
    if (![PFUser currentUser]) {  // Check if user is logged in - commented out during offline development
        MyLogInViewController *logInViewController = [[MyLogInViewController alloc] init];
        logInViewController.modalTransitionStyle = UIModalTransitionStylePartialCurl;
        logInViewController.delegate = self;
        logInViewController.fields = PFLogInFieldsTwitter;

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
        // sets score label
        self.scoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(40,6,55,32)];
        NSNumber *userScore = [[MyTwitterController sharedInstance] requestInitialScore];
        self.scoreLabel.text = [userScore stringValue];
        self.scoreLabel.textColor = [UIColor whiteColor];
        self.scoreLabel.font = TWIZ_FONT_500_18;
        [self.mainView addSubview:self.scoreLabel];
        [self.navigationController.navigationBar addSubview:self.scoreLabel];
        
#pragma mark - Loading Indicator
        
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

#pragma mark - Answer Selected

- (void) answerSelected:(id)sender {
    // initialize everything needed for animation
    PossibleAnswerBtn *selectedAnswerBtn = sender;
    PossibleAnswerBtn *correctAnswerBtn = [PossibleAnswerBtn new];
    NSString *selectedAuthorID = [selectedAnswerBtn currentTitle];
    NSString *correctAuthorID = self.activeTweet.correctAnswerID;
    NSNumber *number = [NSNumber new];
    BOOL isCorrect = nil;
    
    if([selectedAuthorID isEqualToString:correctAuthorID]){
        isCorrect = true;
        number = [NSNumber numberWithInt:5];
        selectedAnswerBtn.layer.borderWidth = 0.0;
        selectedAnswerBtn.possibleAnswerPoints.text = [NSString stringWithFormat:@"+%@", selectedAnswerBtn.possibleAnswerPoints.text];
        selectedAnswerBtn.possibleAnswerPoints.textColor = PURPLE_COLOR;
        selectedAnswerBtn.backgroundColor = GREEN_COLOR; /* green #57f9f7*/
        [selectedAnswerBtn setTitleColor:PURPLE_COLOR forState:UIControlStateNormal];
        
    } else {
        isCorrect = false;
        NSLog(@"%@ is not equal to %@", selectedAuthorID, correctAuthorID );
        number = [NSNumber numberWithInt:-1];
        selectedAnswerBtn.layer.borderWidth = 0.0;
        selectedAnswerBtn.backgroundColor = RED_COLOR; /*red #f4929e*/
        
        for (int i = 0; i < [self.activeTweet.possibleAnswers count]; i++) {
            if ([[self.activeTweet.possibleAnswers objectAtIndex:i][tweetPointsKey] isEqualToNumber:[NSNumber numberWithInt:5]]) {
                switch (i) {
                    case 0:
                        correctAnswerBtn = self.possibleAnswer1;
                        break;
                    case 1:
                        correctAnswerBtn = self.possibleAnswer2;
                        break;
                    case 2:
                        correctAnswerBtn = self.possibleAnswer3;
                        break;
                    case 3:
                        correctAnswerBtn = self.possibleAnswer4;
                        break;
                    default:
                        NSLog(@"Didn't match any! WTF?");
                        break;
                }
                correctAnswerBtn.layer.borderWidth = 0.0;
                correctAnswerBtn.backgroundColor = GREEN_COLOR;
                correctAnswerBtn.alpha = 0;
                [correctAnswerBtn setTitleColor:PURPLE_COLOR forState:UIControlStateNormal];
                [self.view addSubview:correctAnswerBtn];
            }
        }
    }
    // set general animations
    [self.view addSubview:selectedAnswerBtn];
    self.mainView.alpha = .4;
    // gets ready for animation by converting position inside button view to main window's view
    CGRect frame = [selectedAnswerBtn convertRect:selectedAnswerBtn.possibleAnswerPoints.frame toView:self.view];
    [self.view addSubview:selectedAnswerBtn.possibleAnswerPoints];
    selectedAnswerBtn.possibleAnswerPoints.frame = frame;
    
    if (isCorrect) {
        [UIView animateWithDuration:.17 delay:0 options:nil animations:^{ // original show and scale up
            [selectedAnswerBtn.possibleAnswerPoints setHidden:(false)];
            selectedAnswerBtn.possibleAnswerPoints.transform = CGAffineTransformScale(selectedAnswerBtn.possibleAnswerPoints.transform, 1.5, 1.5);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{ // scale down
                selectedAnswerBtn.possibleAnswerPoints.transform = CGAffineTransformScale(selectedAnswerBtn.possibleAnswerPoints.transform, .7, .7);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:.06 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{ // bounce back up
                   selectedAnswerBtn.possibleAnswerPoints.transform = CGAffineTransformScale(selectedAnswerBtn.possibleAnswerPoints.transform, 1.2, 1.2);
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:.04 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{ // bounce back up
                        selectedAnswerBtn.possibleAnswerPoints.transform = CGAffineTransformScale(selectedAnswerBtn.possibleAnswerPoints.transform, .9, .9);
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:.5 delay:.5 options:UIViewAnimationOptionCurveEaseOut animations:^{ // zoom up to corner
                            [selectedAnswerBtn.possibleAnswerPoints setCenter:CGPointMake(60, -5)];
                            selectedAnswerBtn.backgroundColor = [UIColor clearColor];
                        } completion:^(BOOL finished) {
                            [selectedAnswerBtn.possibleAnswerPoints removeFromSuperview]; // removes points from view
                            [UIView animateWithDuration:.12 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{ // score button pops up
                                self.scoreLabel.transform = CGAffineTransformScale(self.scoreLabel.transform, 1.2, 1.2);
                            } completion:^(BOOL finished) {
                                [UIView animateWithDuration:.05 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{ // score button pops down
                                    self.scoreLabel.transform = CGAffineTransformScale(self.scoreLabel.transform, .83333, .83333);
                                } completion:^(BOOL finished) {
                                    [selectedAnswerBtn removeFromSuperview];
                                    [correctAnswerBtn removeFromSuperview];
                                    self.scoreInt = [[[MyTwitterController sharedInstance] incrementScoreWithNumber:number] intValue];
                                    self.scoreLabel.text = [NSString stringWithFormat: @"%d", (int)self.scoreInt];
                                    [self resetActiveTweet]; // loads new tweet
                                    
                                }];
                            }];
                        }];
                    }];
                }];
            }];
        }];

    } else { // in event of wrong answer
        [selectedAnswerBtn.possibleAnswerPoints setHidden:(false)];
        [UIView animateWithDuration:1.6 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{ // original fade in
            correctAnswerBtn.alpha = 1;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{ // original scale up
                correctAnswerBtn.alpha = .5;
                selectedAnswerBtn.alpha = .5;
            } completion:^(BOOL finished) {
                [selectedAnswerBtn removeFromSuperview];
                [selectedAnswerBtn.possibleAnswerPoints removeFromSuperview];
                [correctAnswerBtn removeFromSuperview];
                self.scoreInt = [[[MyTwitterController sharedInstance] incrementScoreWithNumber:number] intValue];
                self.scoreLabel.text = [NSString stringWithFormat: @"%d", (int)self.scoreInt];
                
                if (self.wrongAnswerCount == 5) {
                    [self showFullScreenAd];
                } else {
                    self.wrongAnswerCount++;
                }
                
                [self resetActiveTweet]; // loads new tweet
            }];
        }];
    }
}

- (void)resetActiveTweet {
    
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{ // fade out old tweet
        self.mainView.alpha = 0;
    } completion:^(BOOL finished) {
        
        [self.mainView removeFromSuperview]; // clears old tweet completely
        self.activeTweet = [[MyTwitterController sharedInstance] requestActiveTweet];
        self.mainView = [[UIView alloc] initWithFrame:self.view.bounds]; // overall view to remove after answer has been selected
        self.mainView.alpha = 0;
        
        // Redraws tweet and possible answers
        self.tweetLabel = [[UITextView alloc]initWithFrame:CGRectMake(10.0, 10.0f, self.view.bounds.size.width - 20.0f, (200.0 * self.heightScaleFactor))];
        self.tweetLabel.dataDetectorTypes = UIDataDetectorTypeLink; // makes links clickable
        self.tweetLabel.linkTextAttributes = @{NSForegroundColorAttributeName:GREEN_COLOR};
        self.tweetLabel.editable = NO; // disables editing
        [[self.tweetLabel layer] setCornerRadius:3.0f];
        [[self.tweetLabel layer] setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.1].CGColor];
        self.tweetLabel.textColor = [UIColor whiteColor];
        [self.tweetLabel setFont:TWIZ_FONT_500_22];
        self.tweetLabel.textContainer.lineFragmentPadding = 15;
        self.tweetLabel.text = self.activeTweet.tweet;
        
        [self.mainView addSubview:self.tweetLabel];
        
        
#pragma mark - Possible Answers Display
        
        // refactor if possible into a loop - changing just the initial height on each time it goes through
        
        // Possible Answer1
        self.possibleAnswer1 = [[PossibleAnswerBtn alloc] initWithFrame:CGRectMake(10.0, (220.0 * self.heightScaleFactor), self.view.bounds.size.width - 20.0f, (48 * self.heightScaleFactor))];
        [self.possibleAnswer1 setTitle:self.activeTweet.possibleAnswers[0][possibleAnswerAuthorKey] forState:UIControlStateNormal];
        self.possibleAnswer1.possibleAnswerPoints.text =  [self.activeTweet.possibleAnswers[0][tweetPointsKey] stringValue];
        [self.possibleAnswer1.possibleAnswerImage setImageWithURL:self.activeTweet.possibleAnswers[0][possibleAnswerPhotoURLKey] placeholderImage:[UIImage imageNamed:@"mrT.jpg"]];
        [self.possibleAnswer1 addTarget:self action:@selector(answerSelected:) forControlEvents:UIControlEventTouchUpInside];
        self.possibleAnswer1.tag = self.activeTweet.possibleAnswers[0][possibleAnswerAuthorKey];
        
        // Possible Answer2
        self.possibleAnswer2 = [[PossibleAnswerBtn alloc] initWithFrame:CGRectMake(10.0, (275.0 * self.heightScaleFactor), self.view.bounds.size.width - 20.0f, (48 * self.heightScaleFactor))];
        [self.possibleAnswer2 setTitle: self.activeTweet.possibleAnswers[1][possibleAnswerAuthorKey] forState:UIControlStateNormal];
        [self.possibleAnswer2.possibleAnswerImage setImageWithURL:self.activeTweet.possibleAnswers[1][possibleAnswerPhotoURLKey] placeholderImage:[UIImage imageNamed:@"mrT.jpg"]];
        self.possibleAnswer2.possibleAnswerPoints.text =  [self.activeTweet.possibleAnswers[1][tweetPointsKey] stringValue];
        [self.possibleAnswer2 addTarget:self action:@selector(answerSelected:) forControlEvents:UIControlEventTouchUpInside];
        self.possibleAnswer2.tag = self.activeTweet.possibleAnswers[1][possibleAnswerAuthorKey];
        
        // Possible Answer3
        self.possibleAnswer3 = [[PossibleAnswerBtn alloc] initWithFrame:CGRectMake(10.0, (330.0 * self.heightScaleFactor), self.view.bounds.size.width - 20.0f, (48 * self.heightScaleFactor))];
        [self.possibleAnswer3 setTitle:self.activeTweet.possibleAnswers[2][possibleAnswerAuthorKey] forState:UIControlStateNormal];
        self.possibleAnswer3.possibleAnswerPoints.text = [self.activeTweet.possibleAnswers[2][tweetPointsKey] stringValue];
        [self.possibleAnswer3.possibleAnswerImage setImageWithURL:self.activeTweet.possibleAnswers[2][possibleAnswerPhotoURLKey] placeholderImage:[UIImage imageNamed:@"mrT.jpg"]];
        [self.possibleAnswer3 addTarget:self action:@selector(answerSelected:) forControlEvents:UIControlEventTouchUpInside];
        self.possibleAnswer3.tag = self.activeTweet.possibleAnswers[2][possibleAnswerAuthorKey];
        
        // Possible Answer4
        self.possibleAnswer4 = [[PossibleAnswerBtn alloc] initWithFrame:CGRectMake(10.0, (385.0 * self.heightScaleFactor), self.view.bounds.size.width - 20.0f, (48 * self.heightScaleFactor))];
        [self.possibleAnswer4 setTitle:self.activeTweet.possibleAnswers[3][possibleAnswerAuthorKey] forState:UIControlStateNormal];
        self.possibleAnswer4.possibleAnswerPoints.text =  [self.activeTweet.possibleAnswers[3] [tweetPointsKey] stringValue];
        [self.possibleAnswer4.possibleAnswerImage setImageWithURL:self.activeTweet.possibleAnswers[3][possibleAnswerPhotoURLKey] placeholderImage:[UIImage imageNamed:@"mrT.jpg"]];
        [self.possibleAnswer4 addTarget:self action:@selector(answerSelected:) forControlEvents:UIControlEventTouchUpInside];
        self.possibleAnswer4.tag = self.activeTweet.possibleAnswers[3][possibleAnswerAuthorKey];
        
        // skip button
        UIButton *refreshBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        refreshBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [refreshBtn setTitle:NSLocalizedString(@"Skip", nil) forState:UIControlStateNormal];
        [refreshBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        refreshBtn.titleLabel.font = TWIZ_FONT_300_22;
        refreshBtn.frame = CGRectMake(10.0, (440 * self.heightScaleFactor), self.view.bounds.size.width - 20.0f, ((50.0 * self.heightScaleFactor)));
        [[refreshBtn layer] setCornerRadius:3.0f];
        [[refreshBtn layer] setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.1].CGColor];
        [refreshBtn addTarget:self action:@selector(resetActiveTweet) forControlEvents:UIControlEventTouchUpInside];
        
        if (self.isIphone4) { // adjust image placement, selected answer point placement, and font for 3.5 inch screens

            self.possibleAnswer1.possibleAnswerImage.frame = CGRectMake((9 * self.heightScaleFactor), (9  * self.heightScaleFactor), (30  * self.heightScaleFactor), (30  * self.heightScaleFactor));
            self.possibleAnswer2.possibleAnswerImage.frame = CGRectMake((9 * self.heightScaleFactor), (9  * self.heightScaleFactor), (30  * self.heightScaleFactor), (30  * self.heightScaleFactor));
            self.possibleAnswer3.possibleAnswerImage.frame = CGRectMake((9 * self.heightScaleFactor), (9  * self.heightScaleFactor), (30  * self.heightScaleFactor), (30  * self.heightScaleFactor));
            self.possibleAnswer4.possibleAnswerImage.frame = CGRectMake((9 * self.heightScaleFactor), (9  * self.heightScaleFactor), (30  * self.heightScaleFactor), (30  * self.heightScaleFactor));
            refreshBtn.frame = CGRectMake(10.0, (440 * self.heightScaleFactor), self.view.bounds.size.width - 20.0f, ((50.0 * self.heightScaleFactor) - 10));
            self.possibleAnswer1.possibleAnswerPoints.frame = CGRectMake((self.possibleAnswer1.frame.size.width-37), 5, 30,30);
            self.possibleAnswer2.possibleAnswerPoints.frame = CGRectMake((self.possibleAnswer1.frame.size.width-37), 5, 30,30);
            self.possibleAnswer3.possibleAnswerPoints.frame = CGRectMake((self.possibleAnswer1.frame.size.width-37), 5, 30,30);
            self.possibleAnswer4.possibleAnswerPoints.frame = CGRectMake((self.possibleAnswer1.frame.size.width-37), 5, 30,30);
            [self.tweetLabel setFont:[UIFont fontWithName:@"MuseoSansRounded-500" size:(22.0 * self.heightScaleFactor)]];

        }
        
        [self.mainView addSubview:refreshBtn];
        [self.mainView addSubview:self.possibleAnswer1]; // adds each answer to the mainView
        [self.mainView addSubview:self.possibleAnswer2];
        [self.mainView addSubview:self.possibleAnswer3];
        [self.mainView addSubview:self.possibleAnswer4];
        
        [self.view addSubview:self.mainView];// adds mainView to superview so that it can be dismissed yet still keep background
        
        [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{ // fade to introduce active tweet
            self.mainView.alpha = 1;
        } completion:^(BOOL finished) {
            
        }];
    }];
}

-(void)showFullScreenAd {
    MyInterstatialAdViewController *adView = [MyInterstatialAdViewController new];
    [self presentViewController:adView animated:YES completion:nil];
}

- (void) saveUserInfo {
    
    [[MyTwitterController sharedInstance] saveUserInfo];
}

- (void) refreshView {
    self.sidePanelController.centerPanel = [[UINavigationController alloc] initWithRootViewController:[[MyCenterViewController alloc] init]];
}

- (void)loadTweets {
    [[MyTwitterController sharedInstance] loadTweetBucketDictionaryWithCompletion:nil];
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
    
    return informationComplete;
}

- (IBAction)logOutButtonTapAction:(id)sender {
    [self.sidePanelController showCenterPanelAnimated:YES];
    [PFUser logOut];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
