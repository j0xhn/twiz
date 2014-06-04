//
//  MuseoWhiteLabel.m
//  LogInAndSignUpDemo
//
//  Created by John D. Storey on 5/30/14.
//
//

#import "MuseoWhiteLabel.h"

@implementation MuseoWhiteLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        UIFont *museoFont = [UIFont fontWithName:@"MuseoSansRounded" size:12.f];
        museoWhiteLabel.font = museoFont;
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
