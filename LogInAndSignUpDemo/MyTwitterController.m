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

@interface MyTwitterController ()
@property (strong,nonatomic) NSDictionary *tweetBucketDictionary;

@end

@implementation MyTwitterController


// Q:4 what's wrong with this?  I can't seem to access the tweetBucketArray found in MyTwitterController.h file.
//if (self.tweetBucketArray == 3){
//    [self requestTweetArray];
//}

+ (void) requestActiveTweet{
    // pull of first tweet from tweetBucketDictionary
    
    // assign it to activeTweet
    
    // delete it from tweetBucketDictionary
}

+(void) requestTweetArrayFirstTime{ //sychronous so the view doesn't load before this stuff is loaded Q:5 or should I just do a loading screen
    
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

+ (void) requestTweetArray:(NSString *)screenName{ //requests timeline in the background

    NSString *bodyString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=%@&count=2&trim_user=true", screenName];
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
//             NSLog(@"Response: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
             // convert it to an NSDictionary @{tweetID:@{@"content":@"string of content here",@"authorID":@NSNumber},
             //                                 tweetID:@{@"content":@"string of content here",@"authorID":@NSNumber}}
             NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONWritingPrettyPrinted error:&error];
//             NSLog(@"JSON: %@", json);
             for(id key in json){
                 NSLog(@"key=%@", key);
                 NSNumber *singleTweetID = [key objectForKey:@"id"];
                 NSString *singleTweetText = [key objectForKey:@"text"];
                 NSNumber *singleTweetAuthorID = [[key objectForKey:@"user"]objectForKey:@"id"];
                 NSDictionary *singleTweet = @{tweetIDKey:singleTweetID, tweetTextKey:singleTweetText, tweetAuthorIDKey:singleTweetAuthorID};
                 NSLog(@"activeTweetID: %@ and text: %@ and AuthorID: %@ in dictionary: %@", singleTweetID, singleTweetText, singleTweetAuthorID, singleTweet);
                 
                 NSDictionary *tweetBucketDictionary = [NSDictionary new];
                 // Q:4 this wont work either
                 [tweetBucketDictionary A]
                 
             }
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
    // convert it to an NSDictionary @{tweetID:@{@"content":@"string of content here",@"authorID":@NSNumber},
    //                                 tweetID:@{@"content":@"string of content here",@"authorID":@NSNumber}}
    
    // and Possible Answer Array @[@{@"authorID":@"NSNUMBER",@"authorPic":@"URL"}];
    
    // merge that with already existing tweetBucketDictionary
}
+ (void) generatePossibleAnswers{
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
