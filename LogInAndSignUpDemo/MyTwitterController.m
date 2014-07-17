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

#import <SEGAnalytics.h>
#import <Crashlytics/Crashlytics.h>

@interface MyTwitterController ()

@property (strong, nonatomic) NSMutableDictionary *tweetBucketDictionary;
@property (strong, nonatomic) NSMutableArray *possibleAnswerBucketArray;
@property (strong,nonatomic) NSMutableArray *mutableArrayContainingNumbers;
@property (strong,nonatomic) NSDictionary *correctAnswer;
@property (strong, nonatomic) NSString *currentUser;
@property (strong,nonatomic) NSNumber *lastTweetID;
@property (assign,nonatomic) int userScore;
@property (strong, nonatomic) MyActiveTweet *activeTweet;

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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setCurrentUser)
                                                 name:@"AppDidBecomeActiveNotification"
                                               object:nil];
    self.InitialLoadState = YES;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:tweetBucketDictionaryKey]) {
        self.tweetBucketDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:tweetBucketDictionaryKey];
    }
    return self;
}

#pragma mark - Generate Tweet and Answers

- (MyActiveTweet *)requestActiveTweet {
    
    if ([self.tweetBucketDictionary count] == 10) { // for slow connections, this give more time for tweets to load
        NSLog(@"ALERT - 10 tweets left");
        [self loadTweetBucketDictionaryWithCompletion:nil];
    }
    if ([self.tweetBucketDictionary count] == 2) { // for fast connections
        NSLog(@"ALERT - 2 tweets left");
        [self loadTweetBucketDictionaryWithCompletion:nil];
    }
    
    if ([self.tweetBucketDictionary count] == 0) { // presents empty bucket view controller
        NSLog(@"ALERT - Out of Tweets");
        MyEmptyBucketViewController *EmptyBucketViewController = [[MyEmptyBucketViewController alloc] init];
        EmptyBucketViewController.modalTransitionStyle = UIModalTransitionStylePartialCurl;
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
    activeTweet.correctAnswerPhoto = [firstTweetFromBucket objectForKey:tweetAuthorPhotoKey];// sets correctAnswerImage
    activeTweet.tweetID = [firstTweetFromBucket objectForKey:tweetIDKey];
    activeTweet.tweet = [firstTweetFromBucket objectForKey:tweetTextKey];
    activeTweet.possibleAnswers = [self requestActivePossibleAnswers:activeTweet];
    
    self.lastTweetID = [firstTweetFromBucket objectForKey:tweetIDKey];
    
    [self.tweetBucketDictionary removeObjectForKey:firstTweetObjectKey]; // delete it from tweetBucketDictionary
//    [[NSUserDefaults standardUserDefaults] setObject:self.tweetBucketDictionary forKey:tweetBucketDictionaryKey]; // save it for when they exit
    
    return activeTweet;
 
}

- (void) loadTweetBucketDictionaryWithCompletion:(void (^)(bool success))block{ //requests timeline in the background
    //Q:1 analytics not working...?
    [[SEGAnalytics sharedAnalytics] track:@"Signed Up"
                               properties:@{ @"plan": @"Enterprise" }]; //tracks bucket requests
    NSString *bodyString = @"";
    if (!self.currentUser){ // if user stops using app, then re-opens app it erases self.currentUser, this sets it.
        self.currentUser = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_USER_KEY];
    }
    if (!self.lastTweetID) {
        bodyString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/home_timeline.json?screen_name=%@&count=20", self.currentUser];
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
         else if ([data length] >0)
         {
             NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONWritingPrettyPrinted error:&error];
 
             for(id key in json){
                 // for active tweet dictionary
                 NSNumber *singleTweetID = [key objectForKey:@"id"];
                 NSString *singleTweetText = [key objectForKey:@"text"];
                 NSString *singleTweetAuthorID = [[key objectForKey:@"user"]objectForKey:@"screen_name"];
                 
                 NSURL *singleTweetimageURL = [NSURL URLWithString:[[key objectForKey:@"user"] objectForKey:@"profile_image_url_https"]];
                 NSData *singleTweetimageData = [NSData dataWithContentsOfURL:singleTweetimageURL];
                 UIImage *singleTweetimage = [UIImage imageWithData:singleTweetimageData];
                 
                 if (!singleTweetimage) {
                     singleTweetimage = [UIImage imageNamed:@"johnD"];
                 }
                 
                 NSDictionary *singleTweet = @{tweetTextKey:singleTweetText,
                                               tweetAuthorIDKey:singleTweetAuthorID,
                                               tweetIDKey:singleTweetID,
                                               tweetAuthorPhotoKey:singleTweetimage};
                
                 
                 // sets possibleAnswerBucketArray to unique answers
                 if (!self.possibleAnswerBucketArray) { // on initial load creates a new possible Answer bucket array
                     self.possibleAnswerBucketArray = [NSMutableArray new];
                 }
                 NSString *query = [NSString stringWithFormat:@"%@ = %%@", possibleAnswerAuthorKey];
                 NSPredicate *pred = [NSPredicate predicateWithFormat:query,singleTweetAuthorID];
                 NSArray *filteredArray = [self.possibleAnswerBucketArray filteredArrayUsingPredicate:pred];
                 if (filteredArray.count == 0) {
                     NSDictionary *possibleAnswer = @{possibleAnswerAuthorKey:singleTweetAuthorID,
                                                      possibleAnswerPhotoKey:singleTweetimage};
                     [self.possibleAnswerBucketArray addObject:possibleAnswer];
                 }
                 
                 if (!self.tweetBucketDictionary) { // for the initial load, if no dictionary it creates one
                     self.tweetBucketDictionary = [NSMutableDictionary new];
                 }
                 [self.tweetBucketDictionary setValue:singleTweet forKey:[NSString stringWithFormat:@"%@",singleTweetID]];
             }
             
             if (self.InitialLoadState) {
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [[NSNotificationCenter defaultCenter]
                      postNotificationName:@"resetActiveTweetNotification"
                      object:nil];
                 });
                 // notification comes AFTER tweetBucketDictionary has been made so central view controller can ask for active tweet
                 self.InitialLoadState = NO; // turns off auto ask
             }
             NSLog(@"tweet bucket finished Loading");
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
        if ([self.mutableArrayContainingNumbers containsObject: [NSNumber numberWithInteger:randomNumber]]){
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
//    [self.mutableArrayContainingNumbers removeAllObjects]; // clears the array so the logic works correctly in the number generator
    self.mutableArrayContainingNumbers = nil;
    
    NSDictionary *correctAnswer = [[NSDictionary alloc]initWithObjectsAndKeys:activeTweet.correctAnswerPhoto,possibleAnswerPhotoKey,activeTweet.correctAnswerID,possibleAnswerAuthorKey, nil];

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
- (void) setCurrentUser{
    PFUser *currentUser = [PFUser currentUser];
    self.userScore = [currentUser[@"userScore"] integerValue];
    self.lastTweetID = currentUser[@"lastTweetID"];
    self.currentUser = currentUser[@"username"];
    
}

-(void) saveUserInfo {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        NSLog(@"current User: %@", currentUser);
        [currentUser setObject:self.lastTweetID forKey:@"lastTweetID"];
        NSNumber *scoreForStore = [NSNumber numberWithInt:self.userScore]; // converts int for storage
        [currentUser setObject:scoreForStore forKey:@"userScore"];
        self.backgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskId];
        }];
        
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
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
