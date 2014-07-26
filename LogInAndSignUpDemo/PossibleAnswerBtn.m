//
//  PossibleAnswerBtn.m
//  twiz
//
//  Created by John D. Storey on 7/26/14.
//
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
        [self.titleLabel setFont:TWIZ_FONT_300_22];
        self.possibleAnswerImage = [[UIImageView alloc]initWithFrame:CGRectMake(9, 9, 30, 30)];
        self.possibleAnswerImage.contentMode = UIViewContentModeScaleAspectFill;
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
