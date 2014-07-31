//
//  MyTwitterController.m
//  twiz
//
//  Created by John D. Storey on 6/8/14.
//
//
#import "MyTwitterController.h"
#import "MyActiveTweet.h"
#import "MyConstants.h"
#import "MyEmptyBucketViewController.h"

//#import <SEGAnalytics.h>
#import <Crashlytics/Crashlytics.h>

@interface MyTwitterController ()

@property (strong, nonatomic) NSMutableDictionary *tweetBucketDictionary;
@property (strong, nonatomic) NSMutableArray *possibleAnswerBucketArray;
@property (strong,nonatomic) NSMutableArray *mutableArrayContainingNumbers;
@property (strong,nonatomic) NSDictionary *correctAnswer;
@property (strong, nonatomic) NSString *currentUser;
@property (strong, nonatomic) UIImage *currentUserImage;
@property (strong,nonatomic) NSNumber *lastTweetID;
@property (assign,nonatomic) int userScore;
@property (strong, nonatomic) MyActiveTweet *activeTweet;

@property (assign,nonatomic) NSInteger infiniteLoopCounter;

@property (assign,nonatomic) BOOL InitialLoadState;

@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskId; // for saving in background functionality - gives about 10 minutes

@end

@implementation MyTwitterController

+ (MyTwitterController *)sharedInstance {
    static MyTwitterController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [MyTwitterController new];
    });
    return sharedInstance;
}

- (id) init{
    self.infiniteLoopCounter = 1;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setCurrentUser)
                                                 name:@"AppDidBecomeActiveNotification"
                                               object:nil];
    self.InitialLoadState = YES;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:tweetBucketDictionaryKey]) {
        self.tweetBucketDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:tweetBucketDictionaryKey];
    }
    return self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(logOutUser)
                                                 name:@"logOutTweetNotification"
                                               object:nil];
}

- (void) logOutUser {
    [PFUser logOut];
}

#pragma mark - Generate Tweet and Answers

- (MyActiveTweet *)requestActiveTweet {
    
    if ([self.tweetBucketDictionary count] == 10) { // for slow connections, this give more time for tweets to load
        NSLog(@"ALERT - 10 tweets left");
        [self loadTweetBucketDictionaryWithCompletion:nil];
    }
    if ([self.tweetBucketDictionary count] == 3) { // for fast connections, but sometimes it logs this, then crashes directly after
        NSLog(@"ALERT - 2 tweets left");
        [self loadTweetBucketDictionaryWithCompletion:nil];
    }
    
    if ([self.tweetBucketDictionary count] == 0) { // presents empty bucket view controller
        // Present Log In View Controller
        [self.delegate ranOutOfTweets];
        MyActiveTweet *emptyTweetsObject = [MyActiveTweet new];
        return emptyTweetsObject;
    }
 
    MyActiveTweet *activeTweet = [MyActiveTweet new];
    NSMutableArray *tweetIDArray = [self.tweetBucketDictionary allKeys]; // pull of first tweet from tweetBucketDictionary and assign it to self.activeTweet
    NSString *firstTweetObjectKey = [tweetIDArray firstObject];
    NSDictionary *firstTweetFromBucket = [self.tweetBucketDictionary objectForKey:firstTweetObjectKey];
    
    activeTweet.correctAnswerID = [firstTweetFromBucket objectForKey:tweetAuthorIDKey];
    activeTweet.correctAnswerPhotoURL = [firstTweetFromBucket objectForKey:tweetPhotoURLKey];
    activeTweet.tweetID = [firstTweetFromBucket objectForKey:tweetIDKey];
    activeTweet.tweet = [firstTweetFromBucket objectForKey:tweetTextKey];
    activeTweet.possibleAnswers = [self requestActivePossibleAnswers:activeTweet];
    
    self.lastTweetID = [firstTweetFromBucket objectForKey:tweetIDKey];
    
    [self.tweetBucketDictionary removeObjectForKey:firstTweetObjectKey]; // delete it from tweetBucketDictionary
//    [[NSUserDefaults standardUserDefaults] setObject:self.tweetBucketDictionary forKey:tweetBucketDictionaryKey]; // save it for when they exit
    
    return activeTweet;
 
}

- (void) loadTweetBucketDictionaryWithCompletion:(void (^)(bool success))block{ //requests timeline in the background
    //Q:1 analytics not working... any idea why or how to debug?  Should I just switch to using raw google analytics instead?
//    [[SEGAnalytics sharedAnalytics] track:@"Signed Up"
//                               properties:@{ @"plan": @"Enterprise" }]; //tracks bucket requests
    NSString *bodyString = @"";
    if (!self.currentUser){ // if user stops using app, then re-opens app it erases self.currentUser, this sets it.
        self.currentUser = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_USER_KEY];
    }
    if (!self.lastTweetID) {
        bodyString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/home_timeline.json?screen_name=%@&count=100", self.currentUser];
    } else {
        bodyString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/home_timeline.json?screen_name=%@&count=100&since_id=%@", self.currentUser, self.lastTweetID];
    }
    
    NSURL *url = [NSURL URLWithString:bodyString];
    NSMutableURLRequest *tweetRequest = [NSMutableURLRequest requestWithURL:url];
    [[PFTwitterUtils twitter] signRequest:tweetRequest];
    // ASYNCH
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:tweetRequest queue:queue completionHandler:^(
                                                                                          NSURLResponse *response,
                                                                                          NSData *data,
                                                                                          NSError *error)
     {
         if (error) { // error for when you exeed your limit
             NSLog(@"error %@", error);
             if (block) { // if passes "nil" then this ensures it doesn't throw an error
                 block(NO);
             }
         }
         else if ([data length] >1)
         {
             NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONWritingPrettyPrinted error:&error];
             
         // Q:3 - app just freezes if passed an error here, should show alert view.
             
             for(id key in json){
                 
                 // for active tweet dictionary
                 NSNumber *singleTweetID = [key objectForKey:@"id"];
                 NSString *singleTweetText = [key objectForKey:@"text"];
                 NSString *singleTweetAuthorID = [[key objectForKey:@"user"]objectForKey:@"screen_name"];
                 NSNumber *defaultPoints = [NSNumber numberWithInteger:-1];
                 
                 NSURL *singleTweetimageURL = [NSURL URLWithString:[[key objectForKey:@"user"] objectForKey:@"profile_image_url_https"]];
                 
                 NSDictionary *singleTweet = @{tweetTextKey:singleTweetText,
                                               tweetAuthorIDKey:singleTweetAuthorID,
                                               tweetIDKey:singleTweetID,
                                               tweetPhotoURLKey: singleTweetimageURL
//                                               tweetAuthorPhotoKey:singleTweetimage
                                               };
                
                 
                 // sets possibleAnswerBucketArray to unique answers
                 if (!self.possibleAnswerBucketArray) { // on initial load creates a new possible Answer bucket array
                     self.possibleAnswerBucketArray = [NSMutableArray new];
                 }
                 NSString *query = [NSString stringWithFormat:@"%@ = %%@", possibleAnswerAuthorKey];
                 NSPredicate *pred = [NSPredicate predicateWithFormat:query,singleTweetAuthorID];
                 NSArray *filteredArray = [self.possibleAnswerBucketArray filteredArrayUsingPredicate:pred];
                 if (filteredArray.count == 0) {
                     NSDictionary *possibleAnswer = @{possibleAnswerAuthorKey:singleTweetAuthorID,
                                                      possibleAnswerPhotoURLKey: singleTweetimageURL,
                                                      tweetPointsKey:defaultPoints};
                     [self.possibleAnswerBucketArray addObject:possibleAnswer];
                 }
                 
                 if (!self.tweetBucketDictionary) { // for the initial load, if no dictionary it creates one
                     self.tweetBucketDictionary = [NSMutableDictionary new];
                 }
                 [self.tweetBucketDictionary setValue:singleTweet forKey:[NSString stringWithFormat:@"%@",singleTweetID]];
             }
             
             if (self.InitialLoadState) {
                 self.InitialLoadState = NO; // turns off auto ask
             }
             NSLog(@"tweet bucket finished Loading");
             if (self.possibleAnswerBucketArray < 4) { // checks to see if there are atleast 4 possible answers
                 UIAlertView *infiniteLoopAlert = [[UIAlertView alloc]
                                                   initWithTitle:@"Whoops! Lets try this again"
                                                   message:@"Something went wrong under the hood.  Usually it's because you didn't have at least 4 new tweets to create your quiz with, so close the app and wait a couple of minutes then try again"
                                                   delegate:self
                                                   cancelButtonTitle:@"Thanks!"
                                                   otherButtonTitles:nil];
                 [infiniteLoopAlert show];
             }

             if (block) { // if passes "nil" then this ensures it doesn't throw an error
                 block(YES);
             }
             
         }
         else if ([data length] == 0 && error == nil)
         {
             NSLog(@"Nothing was downloaded.");
             if (block) { // if passes "nil" then this ensures it doesn't throw an error
                 block(NO);
             }
         }
         else if (error != nil){
             UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                      message:@"Something went wrong, check your internet connection then try again"
                                                                     delegate:self
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles:nil];
             [errorAlertView show];
             NSLog(@"Error = %@", error);
             if (block) { // if passes "nil" then this ensures it doesn't throw an error
                 block(NO);
             }
         }
     }];
}

#pragma mark - Answers and Score

-(void) generateRandomNumberArray {
    int objectsInArray = [self.possibleAnswerBucketArray count]; // makes it so you don't get numbers higher than what is currently in there

    NSInteger randomNumber = (NSInteger) arc4random_uniform(objectsInArray); // picks between 0 and n-1
    if (self.mutableArrayContainingNumbers) {
        if ([self.mutableArrayContainingNumbers containsObject: [NSNumber numberWithInteger:randomNumber]]){ // crashes here when you don't have more than 4 possible answers to choose from
            [self generateRandomNumberArray]; // call the method again and get a new object
        } else {
            // end case, it doesn't contain it so you have a number you can use
            [self.mutableArrayContainingNumbers addObject: [NSNumber numberWithInteger:randomNumber]];
            if ([self.mutableArrayContainingNumbers count] != 3) {
                [self generateRandomNumberArray];
            }
        }

    } else { // runs the first time
        NSMutableArray *mutableArrayContainingNumbers = [NSMutableArray new];
        [mutableArrayContainingNumbers addObject: [NSNumber numberWithInteger:randomNumber]];
        self.mutableArrayContainingNumbers = mutableArrayContainingNumbers;
        [self generateRandomNumberArray];
    }
    
}

- (NSMutableArray *) requestActivePossibleAnswers:(MyActiveTweet *)activeTweet{
    
    [self generateRandomNumberArray];
    
    NSMutableArray *activePossibleAnswers = [NSMutableArray new];
    for (int i = 0; i < [self.mutableArrayContainingNumbers count]; i++)
    {
        NSNumber *possibleAnswerRandomNumber = self.mutableArrayContainingNumbers[i];
        // if error's here it's because you don't have any possibleAnswers
        NSDictionary *possibleAnswer = [self.possibleAnswerBucketArray objectAtIndex:possibleAnswerRandomNumber.integerValue];
        [activePossibleAnswers addObject:possibleAnswer];
    }

    self.mutableArrayContainingNumbers = nil;
    NSNumber *points = [NSNumber numberWithInteger:5];
    NSDictionary *correctAnswer = [[NSDictionary alloc]initWithObjectsAndKeys:
                                   activeTweet.correctAnswerPhotoURL, possibleAnswerPhotoURLKey,
                                   activeTweet.correctAnswerID,possibleAnswerAuthorKey,
                                   points, tweetPointsKey, nil];

    for (NSDictionary *answer in activePossibleAnswers) {
        if ([answer[possibleAnswerAuthorKey] isEqualToString:correctAnswer[possibleAnswerAuthorKey]]) {
            NSLog(@"this answer is a duplicate");
            return [self requestActivePossibleAnswers:activeTweet];
        }
    }
    
    NSInteger randomIndexNumber = (NSInteger) arc4random_uniform(4); // pics random number n-1
    [activePossibleAnswers insertObject:correctAnswer atIndex:randomIndexNumber];
    
    return activePossibleAnswers;
}
- (NSNumber *) requestInitialScore{
    NSNumber *initialScore = [NSNumber numberWithInteger:self.userScore];
    return initialScore;
}
- (UIImage *) requestUserImage {
    return self.currentUserImage;
}
- (void) setCurrentUser{
    PFUser *currentUser = [PFUser currentUser];
    self.userScore = [currentUser[@"userScore"] integerValue];
    // long process because parse was having an issue saving my NSNumber, so I converted it to string.  This de-converts.

    NSString *numberFromStoreInString = currentUser[@"lastTweetString"];
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * lastTweetID = [f numberFromString:numberFromStoreInString];

    self.lastTweetID = lastTweetID;
    self.currentUser = currentUser[@"username"];
    
    NSURL *currentUserImageURL = [NSURL URLWithString:currentUser[@"picture"]];
    NSData *currentUserimageData = [NSData dataWithContentsOfURL:currentUserImageURL];
    UIImage *currentUserImage = [UIImage imageWithData:currentUserimageData];
    self.currentUserImage = currentUserImage;
}

-(void) saveUserInfo {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        NSString *lastTweetString = [NSString stringWithFormat:@"%@", self.lastTweetID];
        [currentUser setObject:lastTweetString forKey:@"lastTweetString"];
        NSNumber *scoreForStore = [NSNumber numberWithInt:self.userScore]; // converts int for storage
        [currentUser setObject:scoreForStore forKey:@"userScore"];
        self.backgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskId];
        }];
        
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                PFUser *currentUser = [PFUser currentUser];
                NSLog(@"Hooray! Saved to Parse!");
            }
            if (error) {
                NSLog(@"Ooops, we got this error: %@", error);
            }

            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskId];
        }];
        
    } else {
        // show the signup or login screen
        NSLog(@"ERROR: NO CURRENT USER");
    }
}

- (void) loadValuesFromParse {
    
}

- (NSNumber *) incrementScoreWithNumber:(NSNumber *)number{
    NSLog(@"Change Score score by %ld", (long) [number intValue]);
    self.userScore = self.userScore + [number intValue];
    NSNumber *newScore = [NSNumber numberWithInt:self.userScore];
    return newScore;
}

- (void) toggleInitialLoadState{
    if (self.InitialLoadState) {
        self.InitialLoadState = NO;
    } else {
        self.InitialLoadState = YES;
    }
    
}

@end
