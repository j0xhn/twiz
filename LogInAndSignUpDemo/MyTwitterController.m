//
//  MyTwitterController.m
//  twiz
//
//  Created by John D. Storey on 6/8/14.
//
//
#import "MyTwitterController.h"
#import "MyLogInViewController.h"
#import "MyCenterViewController.h"

static NSString const * tweetIDKey = @"tweetID";
static NSString const * tweetTextKey = @"tweetText";
static NSString const * tweetAuthorIDKey = @"tweetAuthorID";

static NSString const * possibleAnswerAuthorKey = @"possibleAnswerAuthor";
static NSString const * possibleAnswerPhotoKey = @"possibleAnwerPhoto";

@interface MyTwitterController ()

@property (strong, nonatomic) NSDictionary *activeTweet;
@property (strong, nonatomic) NSDictionary *tweetBucketDictionary;
@property (strong, nonatomic) NSMutableArray *possibleAnswers;
@property (strong, nonatomic) NSNumber *correctAnswerID;

@end

@implementation MyTwitterController

#pragma mark - Generate Tweets

+ (NSDictionary *) requestActiveTweet{
    NSDictionary *activeTweet = [NSDictionary new];
    activeTweet = @{tweetAuthorIDKey:@"111111authorID", tweetTextKey:@"sample tweet text", tweetIDKey:@"22222222tweetID",
                    @"possibleAnswerArray": @[@{possibleAnswerAuthorKey: @"possibleAnswerAuthor1",possibleAnswerPhotoKey:@"possibleAnswerPhoto1"},
                                              @{possibleAnswerAuthorKey: @"possibleAnswerAuthor2",possibleAnswerPhotoKey:@"possibleAnswerPhoto2"},
                                              @{possibleAnswerAuthorKey: @"possibleAnswerAuthor3",possibleAnswerPhotoKey: @"possibleAnswerPhoto3"},
                                              @{possibleAnswerAuthorKey: @"possibleAnswerAuthor4",possibleAnswerPhotoKey: @"possibleAnswerPhoto4"} ]};
    
//    // convert dictionary to Array
//    NSMutableArray *tweetBucketArray = [NSArray alloc]initWithObjects:self.tweetBucketDictionary, nil];
//    // pull of first tweet from tweetBucketDictionary and assign it to self.activeTweet
//    self.activeTweet = [tweetBucketArray firstObject];
//    // delete it from tweetBucketDictionary
//    [tweetBucketArray removeObjectAtIndex:0];
//    // set it back to the Dictioary
//    for(id key in tweetBucketArray){
//        NSMutableDictionary *singleTweet = key;
    return activeTweet;
    
}

+(void) requestTweetArrayFirstTime{ // sychronous so the view doesn't load before this stuff is loaded Q:1 or should I just do a loading screen?
    
    NSString *bodyString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=johnDANGRstorey&count=2"];
    NSURL *url = [NSURL URLWithString:bodyString];
    NSMutableURLRequest *tweetRequest = [NSMutableURLRequest requestWithURL:url];
    [[PFTwitterUtils twitter] signRequest:tweetRequest];
        NSURLResponse *response = nil;
        NSError *error = nil;
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

+ (NSDictionary *) requestTweetBucketDictionary:(NSString *)screenName{ //requests timeline in the background

    NSString *bodyString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=%@&count=20", screenName];
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
             NSMutableArray *possibleAnswers = [NSMutableArray new];
             
             for(id key in json){
                 NSLog(@"key=%@", key);
                 // for active tweet dictionary
                 NSNumber *singleTweetID = [key objectForKey:@"id"];
                 NSString *singleTweetText = [key objectForKey:@"text"];
                 NSNumber *singleTweetAuthorID = [[key objectForKey:@"user"]objectForKey:@"id"];
                 NSDictionary *singleTweet = @{tweetTextKey:singleTweetText, tweetAuthorIDKey:singleTweetAuthorID};
                 NSLog(@"activeTweetID: %@ and text: %@ and AuthorID: %@ in dictionary: %@", singleTweetID, singleTweetText, singleTweetAuthorID, singleTweet);
                 // for possible answers array
                 NSString *singleTweetAuthorPhoto = [[key objectForKey:@"user"] objectForKey:@"profile_image_url_https"];
                 NSDictionary *possibleAnswer = @{possibleAnswerAuthorKey:singleTweetAuthorID, possibleAnswerPhotoKey:singleTweetAuthorPhoto};
                 
                 [possibleAnswers addObject:possibleAnswer];
                 [tweetBucketDictionary setValue:singleTweet forKey:[NSString stringWithFormat:@"%@",singleTweetID]];
             }
             // Q2:  I can't seem to reference my own values up above in the @implementation.... why?
//              self.tweetBucketDictionary = tweetBucketDictionary;

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
}

#pragma mark - Answers and Score

+ (NSArray *) generatePossibleAnswers{
    
    // create a new instance of possibleAnswers dictionary
    
    // generate random number arc4random() % 20
    
    // select that person dictionary in the array
    
    // check to see if they are already in the possibleAnswers dictionary by comparing AuthorID values
    
    // when reach 4 in the possible Answers Array stop loop.
    
}

+ (void) checkAnswer{
    // check if the dictionary item from the button selected matches the authorID on the activeTweet.
    
    // increment the score with right.
    
}
+ (void) incrementScore:(NSNumber *)number{
    // take the score, increment the number, then resave it as the score
    
}

@end
