//
//  MyTwitterController.h
//  twiz
//
//  Created by John D. Storey on 6/8/14.
//
//

#import <Foundation/Foundation.h>
#import "MyCenterViewController.h"

@class MyTwitterController; // creates protocol to handle presenting new page via MyCenterViewController
@protocol MyTwitterDelegate
- (void) ranOutOfTweets;
@end

@interface MyTwitterController : NSObject

@property (nonatomic, weak) MyCenterViewController *centerVC;
+ (MyTwitterController *)sharedInstance;
@property (nonatomic, weak) id <MyTwitterDelegate> delegate;

- (NSNumber *) requestInitialScore;
- (UIImage *) requestUserImage;
- (NSDictionary *) requestActiveTweet;
- (void) loadTweetBucketDictionaryWithCompletion:(void (^)(bool success))block;
- (NSNumber *) incrementScoreWithNumber:(NSNumber *)number;
- (void) saveUserInfo;
- (void) setCurrentUser;

@end

