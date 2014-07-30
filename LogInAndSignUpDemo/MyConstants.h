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

#define TWIZ_FONT_900_24 [UIFont fontWithName:@"MuseoSansRounded-900" size:24.0]
#define TWIZ_FONT_500_18 [UIFont fontWithName:@"MuseoSansRounded-500" size:18.0]
#define TWIZ_FONT_500_22 [UIFont fontWithName:@"MuseoSansRounded-500" size:22.0]
#define TWIZ_FONT_300_30 [UIFont fontWithName:@"MuseoSansRounded-300" size:30.0]
#define TWIZ_FONT_300_22 [UIFont fontWithName:@"MuseoSansRounded-300" size:22.0]

#define PURPLE_COLOR [UIColor colorWithRed:49.0f/255.0f green:35.0f/255.0f blue:105.0f/255.0f alpha:1.0f]
#define RED_COLOR [UIColor colorWithRed:0.957 green:0.573 blue:0.62 alpha:1]
#define GREEN_COLOR [UIColor colorWithRed:0.341 green:0.976 blue:0.969 alpha:1]

#define SCREEN_HORIZONTAL self.view.bounds.size.width
#define SCREEN_VERTICAL self.view.bounds.size.height

static NSString const * tweetBucketDictionaryKey = @"tweetBucketDictionaryKey";

static NSString const * tweetIDKey = @"tweetID";
static NSString const * tweetTextKey = @"tweetText";
static NSString const * tweetAuthorIDKey = @"tweetAuthorID";
static NSString const * tweetPhotoURLKey = @"tweetPhotoURL";
static NSString const * tweetAuthorPhotoKey = @"tweetAuthorPhoto";
static NSString const * tweetPointsKey = @"tweetPoints";

static NSString const * possibleAnswerAuthorKey = @"possibleAnswerAuthor";
static NSString const * possibleAnswerPhotoURLKey = @"possibleAnswerPhotoURLKey";
static NSString const * possibleAnswerPhotoKey = @"possibleAnwerPhoto";

static NSString const * currentUserKey = @"currentUser";

static NSInteger const * tweetBucketSize = 20;

@interface MyConstants : NSObject

@property (strong,nonatomic) NSString *currentUserScreenName;

@property (strong,nonatomic) UIFont *museoButtonFont500_18;

@end
