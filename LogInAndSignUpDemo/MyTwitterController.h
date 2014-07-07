//
//  MyTwitterController.h
//  twiz
//
//  Created by John D. Storey on 6/8/14.
//
//

#import <Foundation/Foundation.h>

@interface MyTwitterController : NSObject

+ (MyTwitterController *)sharedInstance;

- (NSDictionary *) requestActiveTweet;
- (void) loadTweetBucketDictionary;
- (NSInteger *) incrementScore:(NSInteger *)number;

- (void) setCurrentUserScreenName:(NSString *)userName;
- (void) checkAnswer:(NSString *)selectedAuthorID;

@end

