//
//  MyTwitterController.h
//  twiz
//
//  Created by John D. Storey on 6/8/14.
//
//

#import <Foundation/Foundation.h>

@interface MyTwitterController : NSObject

@property (strong, nonatomic) NSDictionary *activeTweet;
@property (strong, nonatomic) NSDictionary *tweetBucketDictionary;
@property (strong, nonatomic) NSArray *possibleAnswers;
@property (strong, nonatomic) NSNumber *correctAnswerID;


+ (void) requestActiveTweet;
+ (void) requestTweetArray:(NSString *)screenName;
+ (void) generatePossibleAnswers;
+ (void) checkAnswer;
+ (void) incrementScore:(NSNumber *)number;

@end
