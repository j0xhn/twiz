//
//  SubclassConfigViewController.h
//  Twiz
//
//  Created from LogInAndSignUpDemo via Parse
//  Copyright (c) 2014 John D. Storey. All rights reserved.
//

@interface MyCenterViewController : UIViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@property (nonatomic,strong) UIView *startView;
@property (nonatomic, strong) IBOutlet UILabel *welcomeLabel;

- (IBAction)logOutButtonTapAction:(id)sender;

@end
