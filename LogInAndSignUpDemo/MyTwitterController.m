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

#import <SEGAnalytics.h>
#import <Crashlytics/Crashlytics.h>

@interface MyTwitterController ()

@property (strong, nonatomic) NSDictionary *tweetBucketDictionary;
@property (strong, nonatomic) NSArray *possibleAnswerBucketArray;
@property (strong,nonatomic) NSMutableArray *mutableArrayContainingNumbers;
@property (strong,nonatomic) NSDictionary *correctAnswer;
@property (strong, nonatomic) MyActiveTweet *activeTweet;

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

- (void) setTweetBucketDictionary:(NSDictionary *)tweetBucketDictionary{
    //Q:3 Having trouble saving it in User Defaults because of the type of data inside NSDictionary (custom) do I cycle through the whole thing like on our "Entities" project and then make a method that re-writes it when I pull it out of NSUserDefaults?
    
    _tweetBucketDictionary = tweetBucketDictionary;
}

#pragma mark - Generate Tweet and Answers

- (MyActiveTweet *)requestActiveTweet {

 
    MyActiveTweet *activeTweet = [MyActiveTweet new];
    NSMutableDictionary *mutableTweetBucketDictionary = [[NSMutableDictionary alloc]initWithDictionary:self.tweetBucketDictionary]; // convert to mutable dict
    NSMutableArray *tweetIDArray = [mutableTweetBucketDictionary allKeys]; // pull of first tweet from tweetBucketDictionary and assign it to self.activeTweet
    NSString *firstTweetObjectKey = [tweetIDArray firstObject];
    NSDictionary *firstTweetFromBucket = [mutableTweetBucketDictionary objectForKey:firstTweetObjectKey];
    
    activeTweet.correctAnswerID = [firstTweetFromBucket objectForKey:tweetAuthorIDKey];
    activeTweet.correctAnswerPhoto = [firstTweetFromBucket objectForKey:tweetAuthorPhotoKey];// sets correctAnswerImage
    activeTweet.tweet = [firstTweetFromBucket objectForKey:tweetTextKey];
    activeTweet.possibleAnswers = [self requestActivePossibleAnswers:activeTweet];
    
    [mutableTweetBucketDictionary removeObjectForKey:firstTweetObjectKey]; // delete it from tweetBucketDictionary
    self.tweetBucketDictionary = mutableTweetBucketDictionary;// set it back to the Dictioary
    
    return activeTweet;
 
    
/*  ignore - for working in off-line mode
    MyActiveTweet *activeTweet = [MyActiveTweet new];
    activeTweet.tweet = @{tweetTextKey:@"testing tweet text 1",
                      tweetAuthorIDKey:@"authorid123456",
                            tweetIDKey:@"tweetid123456"};
    activeTweet.possibleAnswers = @[@{possibleAnswerAuthorKey:@"1@johnDANGRstorey", possibleAnswerPhotoKey:@"1singleTweetAuthorPhotoURL"},
                                    @{possibleAnswerAuthorKey:@"2@randomTweetGuy", possibleAnswerPhotoKey:@"2singleTweetAuthorPhotoURL"},
                                    @{possibleAnswerAuthorKey:@"3@brainpicker", possibleAnswerPhotoKey:@"3singleTweetAuthorPhotoURL"},
                                    @{possibleAnswerAuthorKey:@"4@justinBieber", possibleAnswerPhotoKey:@"4singleTweetAuthorPhotoURL"},];
    return activeTweet;
*/
}

- (NSDictionary *) requestTweetBucketDictionary:(NSString *)screenName{ //requests timeline in the background
    
    [[SEGAnalytics sharedAnalytics] track:@"Signed Up"
                               properties:@{ @"plan": @"Enterprise" }]; //tracks bucket requests
    
    NSString *bodyString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/home_timeline.json?screen_name=%@&count=20", screenName];
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
         if ([data length] >0 && error == nil)
         {
             NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONWritingPrettyPrinted error:&error];
             
             NSMutableDictionary *tweetBucketDictionary = [NSMutableDictionary new];
             NSMutableArray *possibleAnswerBucketArray = [NSMutableArray new];
 
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
                 NSString *query = [NSString stringWithFormat:@"%@ = %%@", possibleAnswerAuthorKey];
                 NSPredicate *pred = [NSPredicate predicateWithFormat:query,singleTweetAuthorID];
                 NSArray *filteredArray = [possibleAnswerBucketArray filteredArrayUsingPredicate:pred];
                 if (filteredArray.count == 0) {
                     NSDictionary *possibleAnswer = @{possibleAnswerAuthorKey:singleTweetAuthorID,
                                                      possibleAnswerPhotoKey:singleTweetimage};
                [possibleAnswerBucketArray addObject:possibleAnswer];
                 }
                 
                 

                 [tweetBucketDictionary setValue:singleTweet forKey:[NSString stringWithFormat:@"%@",singleTweetID]];
             }

             self.possibleAnswerBucketArray = possibleAnswerBucketArray;
             self.tweetBucketDictionary = tweetBucketDictionary;
             NSLog(@"tweet bucket finished Loading");
             
         }
         else if ([data length] == 0 && error == nil)
         {
             NSLog(@"Nothing was downloaded.");
         }
         else if (error != nil){
             UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                      message:@"Something went wrong, check your internet connection then try again"
                                                                     delegate:self
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles:nil];
             [errorAlertView show];
             NSLog(@"Error = %@", error);
         }
     }];
    return self.tweetBucketDictionary;
}

#pragma mark - Answers and Score

-(void) generateRandomNumberArray {
    int objectsInArray = [self.possibleAnswerBucketArray count]; // makes it so you don't get numbers higher than what is currently in there
    NSInteger randomNumber = (NSInteger) arc4random_uniform(objectsInArray); // picks between 0 and n-1
    if (self.mutableArrayContainingNumbers) {
        // Q:2 it gives me an error here, but no error message.  Shows something in memory, what is happening?
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
    
    // checks to see if correctAnswer is duplicate in possibleAnswerArray
//    NSString *query = [NSString stringWithFormat:@"%@ = %%@", possibleAnswerAuthorKey];
//    NSPredicate *pred = [NSPredicate predicateWithFormat:query,correctAnswer[possibleAnswerAuthorKey]];
//    NSArray *filteredArray = [activePossibleAnswers filteredArrayUsingPredicate:pred];
//    if ([filteredArray count] != 0) {
//        NSLog(@"duplicates");
//        [self requestActivePossibleAnswers:activeTweet];
//    } else {
//        NSLog(@"no duplicates");
//    }
    for (NSDictionary *answer in activePossibleAnswers) {
        if (answer[possibleAnswerAuthorKey] == correctAnswer[possibleAnswerAuthorKey]) {
            NSLog(@"this answer is a duplicate");
            // Q:1 sometimes this method DOES NOT recognize a duplicate, and sometimes it does.  Also the following line doesn't restart the method... why?
            [self requestActivePossibleAnswers:activeTweet];
        }
    }
    
    NSInteger randomIndexNumber = (NSInteger) arc4random_uniform(4); // pics random number n-1
    [activePossibleAnswers insertObject:correctAnswer atIndex:randomIndexNumber];
    
    return activePossibleAnswers;
}
/*
- (void) checkAnswer:(NSString *)selectedAuthorID{
    
    NSString *correctAuthorID = self.activeTweet.correctAnswerID;
    
    if([selectedAuthorID isEqualToString:correctAuthorID]){
        NSLog(@"%@ is equal to %@", selectedAuthorID, correctAuthorID );
    } else {
        NSLog(@"%@ is not equal to %@", selectedAuthorID, correctAuthorID );
    }
}
 */
- (void) incrementScore:(NSNumber *)number{
    // take the score, increment the number, then resave it as the score
    
}

@end
