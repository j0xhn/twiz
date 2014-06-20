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
- (NSDictionary *) requestTweetBucketDictionary:(NSString *)screenName;

- (void) checkAnswer:(NSNumber *)selectedAuthorID;

@end

