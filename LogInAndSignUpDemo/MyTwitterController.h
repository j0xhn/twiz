//
//  MyTwitterController.h
//  twiz
//
//  Created by John D. Storey on 6/8/14.
//
//

#import <Foundation/Foundation.h>

@interface MyTwitterController : NSObject

+ (NSDictionary *) requestActiveTweet;
- (NSDictionary *) requestTweetBucketDictionary:(NSString *)screenName;
+ (NSArray *) generatePossibleAnswers;
+ (void) checkAnswer;
+ (void) incrementScore:(NSNumber *)number;

@end
