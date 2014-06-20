//
//  MyActiveTweet.h
//  twiz
//
//  Created by John D. Storey on 6/17/14.
//
//

#import <Foundation/Foundation.h>

@interface MyActiveTweet : NSObject

@property (strong, nonatomic) NSNumber *correctAnswerID;
@property (strong, nonatomic) NSDictionary *tweet;
@property (strong,nonatomic) NSArray *possibleAnswers;

@end
