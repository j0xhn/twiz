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

@interface MyTwitterController ()

@property (strong, nonatomic) NSDictionary *tweetBucketDictionary;
@property (strong, nonatomic) NSArray *possibleAnswerBucketArray;
@property (strong,nonatomic) NSMutableArray *mutableArrayContainingNumbers;

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

#pragma mark - Generate Tweet and Answers

- (MyActiveTweet *)requestActiveTweet {
    
    MyActiveTweet *activeTweet = [MyActiveTweet new];
        // convert dictionary to Array
    NSMutableDictionary *mutableTweetBucketDictionary = [[NSMutableDictionary alloc]initWithDictionary:self.tweetBucketDictionary];
        // pull of first tweet from tweetBucketDictionary and assign it to self.activeTweet
    NSMutableArray *tweetIDArray = [mutableTweetBucketDictionary allKeys];
    NSString *firstTweetObjectKey = [tweetIDArray firstObject];
    NSDictionary *firstTweetFromBucket = [mutableTweetBucketDictionary objectForKey:firstTweetObjectKey];
    
    activeTweet.correctAnswerID = [firstTweetFromBucket objectForKey:tweetAuthorIDKey];
    activeTweet.tweet = [firstTweetFromBucket objectForKey:tweetTextKey];
        // delete it from tweetBucketDictionary
    [mutableTweetBucketDictionary removeObjectForKey:firstTweetObjectKey];
        // set it back to the Dictioary
    self.tweetBucketDictionary = mutableTweetBucketDictionary;
    //Q:1Path_step2 - method generates the appropriate activeTweet, then calls the 'generatePossibleAnswers' method (works)
    [self generatePossibleAnswers];
    
    return activeTweet;
/*
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
                 NSLog(@"key=%@", key);
                 // for active tweet dictionary
                 NSNumber *singleTweetID = [key objectForKey:@"id"];
                 NSString *singleTweetText = [key objectForKey:@"text"];
                 NSNumber *singleTweetAuthorID = [[key objectForKey:@"user"]objectForKey:@"id"];
                 NSDictionary *singleTweet = @{tweetTextKey:singleTweetText,
                                               tweetAuthorIDKey:singleTweetAuthorID,
                                               tweetIDKey:singleTweetID};
                 NSLog(@"activeTweetID: %@ and text: %@ and AuthorID: %@ in dictionary: %@", singleTweetID, singleTweetText, singleTweetAuthorID, singleTweet);
                 // converts URL to UIImage
//                 NSString *singleTweetAuthorPhoto = [[key objectForKey:@"user"] objectForKey:@"profile_image_url_https"];
                 NSURL *imageURL = [NSURL URLWithString:[[key objectForKey:@"user"] objectForKey:@"profile_image_url_https"]];
                 NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                 UIImage *image = [UIImage imageWithData:imageData];
                 
                 NSDictionary *possibleAnswer = @{possibleAnswerAuthorKey:singleTweetAuthorID, possibleAnswerPhotoKey:image};
                 
                 [possibleAnswerBucketArray addObject:possibleAnswer];
                 [tweetBucketDictionary setValue:singleTweet forKey:[NSString stringWithFormat:@"%@",singleTweetID]];
             }

             self.possibleAnswerBucketArray = possibleAnswerBucketArray;
             self.tweetBucketDictionary = tweetBucketDictionary;
             
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
    NSInteger randomNumber = (NSInteger) arc4random_uniform(21); // picks between 0 and n-1
    if ([self.mutableArrayContainingNumbers containsObject: [NSNumber numberWithInteger:randomNumber]]){
        [self generateRandomNumberArray]; // call the method again and get a new object
        } else {
            // end case, it doesn't contain it so you have a number you can use
            [self.mutableArrayContainingNumbers addObject: [NSNumber numberWithInteger:randomNumber]];
            if (![self.mutableArrayContainingNumbers count] == 4) {
                [self generateRandomNumberArray];
            }
        }
}

- (NSArray *) generatePossibleAnswers{
    // Q:1 this call isn't getting fired when the debugger runs over it.  To track the path of how I get here search Q:1Path and I'll show you the steps.
    //Q:1Path_step3 - makes it's way into the method but skips over this method like it doesn't even exist.  Any ideas?
    [self generateRandomNumberArray];

    NSArray *activePossibleAnswers = [NSArray new];
    return activePossibleAnswers;
    
    // select that person dictionary in the array
    
    // check to see if they are already in the possibleAnswers dictionary by comparing AuthorID values
    
    // when reach 4 in the possible Answers Array stop loop.
    
}

- (void) checkAnswer:(NSNumber *)selectedAuthorID{
    // check if the dictionary item from the button selected matches the authorID on the activeTweet.
    
    // increment the score with right.
    
}
- (void) incrementScore:(NSNumber *)number{
    // take the score, increment the number, then resave it as the score
    
}

@end
