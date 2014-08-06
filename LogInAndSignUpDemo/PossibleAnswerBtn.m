//
//  PossibleAnswerBtn.m
//  Twiz
//
//  Created from LogInAndSignUpDemo via Parse
//  Copyright (c) 2014 John D. Storey. All rights reserved.
//

#import "PossibleAnswerBtn.h"
#import "MyConstants.h"

@implementation PossibleAnswerBtn

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        // Initialization code
        self.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.2].CGColor;
        self.layer.borderWidth = 1.0f;
        self.layer.cornerRadius = 3.0f;
        [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 50.0f, 0.0f, 0.0f)];
        [self.titleLabel setFont:TWIZ_FONT_500_22];
        self.possibleAnswerPoints = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width-47), 8, 30,30)];
        self.possibleAnswerPoints.textAlignment = UITextAlignmentCenter;
        self.possibleAnswerPoints.textColor = [UIColor whiteColor];
        self.possibleAnswerPoints.font = TWIZ_FONT_900_24;
        [self.possibleAnswerPoints setHidden:(true)];
        self.possibleAnswerImage = [[UIImageView alloc]initWithFrame:CGRectMake(9, 9, 30, 30)];
        self.possibleAnswerImage.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.possibleAnswerPoints];
        [self addSubview:self.possibleAnswerImage];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
