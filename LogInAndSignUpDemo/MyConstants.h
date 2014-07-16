//
//  MyConstants.h
//  twiz
//
//  Created by John D. Storey on 6/17/14.
//
//
#import <Foundation/Foundation.h>
#define CURRENT_USER_KEY @"currentUser"
#define PURPLE_BACKGROUND [UIImage imageNamed:@"MainBG.png"]
#define TWIZ_FONT_500_18 [UIFont fontWithName:@"MuseoSansRounded-500" size:18.0]
#define TWIZ_FONT_500_22 [UIFont fontWithName:@"MuseoSansRounded-500" size:22.0]
#define TWIZ_FONT_300_30 [UIFont fontWithName:@"MuseoSansRounded-300" size:30.0]
#define TWIZ_FONT_300_22 [UIFont fontWithName:@"MuseoSansRounded-300" size:22.0]

static NSString const * tweetBucketDictionaryKey = @"tweetBucketDictionaryKey";

static NSString const * tweetIDKey = @"tweetID";
static NSString const * tweetTextKey = @"tweetText";
static NSString const * tweetAuthorIDKey = @"tweetAuthorID";
static NSString const * tweetAuthorPhotoKey = @"tweetAuthorPhoto";

static NSString const * possibleAnswerAuthorKey = @"possibleAnswerAuthor";
static NSString const * possibleAnswerPhotoKey = @"possibleAnwerPhoto";

static NSString const * currentUserKey = @"currentUser";

static NSInteger const * tweetBucketSize = 20;

@interface MyConstants : NSObject

@property (strong,nonatomic) NSString *currentUserScreenName;

@property (strong,nonatomic) UIFont *museoButtonFont500_18;

@end
