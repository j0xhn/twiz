//
//  MyConstants.h
//  twiz
//
//  Created by John D. Storey on 6/17/14.
//
//
#import <Foundation/Foundation.h>

static NSString const * tweetIDKey = @"tweetID";
static NSString const * tweetTextKey = @"tweetText";
static NSString const * tweetAuthorIDKey = @"tweetAuthorID";

static NSString const * possibleAnswerAuthorKey = @"possibleAnswerAuthor";
static NSString const * possibleAnswerPhotoKey = @"possibleAnwerPhoto";

static NSInteger const * tweetBucketSize = 20;
//Q5: how to define NSDictionary as static?
/*
static NSDictionary const * sampleActiveTweet = @{tweetTextKey:@"testing tweet text 1",
                                                  tweetAuthorIDKey:@"authorid123456",
                                                  tweetIDKey:@"tweetid123456"};
*/
@interface MyConstants : NSObject

@end
