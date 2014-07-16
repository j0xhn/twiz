/*
 Copyright (c) 2012 Jesse Andersen. All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 of the Software, and to permit persons to whom the Software is furnished to do
 so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 If you happen to meet one of the copyright holders in a bar you are obligated
 to buy them one pint of beer.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */


#import "JARightViewController.h"
#import "JASidePanelController.h"
#import "MyLogInViewController.h"
#import "UIViewController+JASidePanel.h"
#import "MyConstants.h"
#import <Twitter/Twitter.h>

@interface JARightViewController ()

@end

@implementation JARightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor darkGrayColor];
    self.label.text = @"Options";
// Provided by JASlide -- need to keep hidden until you want to use.
    self.hide.hidden = YES;
    self.removeRightPanel.hidden = YES;
    self.addRightPanel.hidden = YES;
    self.changeCenterPanel.hidden = YES;
    
    // signout button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(twitterLogOut)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Log Out" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setFont:TWIZ_FONT_500_22];
    button.frame = CGRectMake(90.0, 287.0, 200.0, 40.0);
    [[button layer] setCornerRadius:5.0f];
    [[button layer] setBorderWidth:1.0f];
    [[button layer] setBorderColor:[UIColor whiteColor].CGColor];
    [self.view addSubview:button];
    
    // tweet button
    UIButton *tweetButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [tweetButton addTarget:self
               action:@selector(sendTweet)
     forControlEvents:UIControlEventTouchUpInside];
    [tweetButton setTitle:@"Send Tweet" forState:UIControlStateNormal];
    [tweetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [tweetButton setFont:TWIZ_FONT_500_22];
    tweetButton.frame = CGRectMake(90.0, 227.0, 200.0, 40.0);
    [[tweetButton layer] setCornerRadius:5.0f];
    [[tweetButton layer] setBorderWidth:1.0f];
    [[tweetButton layer] setBorderColor:[UIColor whiteColor].CGColor];
    [self.view addSubview:tweetButton];

}

-(void)sendTweet{
    
    SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    // Settin The Initial Text
    [vc setInitialText:@"This tweet was sent using the new Twitter framework available in iOS 5."];
    
    // Adding an Image
    UIImage *image = [UIImage imageNamed:@"sample.jpg"];
    [vc addImage:image];
    
    // Adding a URL
    NSURL *url = [NSURL URLWithString:@"http://mobile.tutsplus.com"];
    [vc addURL:url];
    
    [self presentViewController:vc animated:YES completion:nil];
    
    // Setting a Completing Handler
    [vc setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
        
        [self dismissModalViewControllerAnimated:YES];
    }];
 /*
    // Display Tweet Compose View Controller Modally
    [self presentViewController:vc animated:YES completion:nil];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        // Initialize Tweet Compose View Controller

        
    } else {
        // Show Alert View When The Application Cannot Send Tweets
        NSString *message = @"The application cannot send a tweet at the moment. This is because it cannot reach Twitter or you don't have a Twitter account associated with this device.";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops" message:message delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alertView show];
    }
  */
}

- (void)twitterLogOut{
    NSLog(@"Log Out Clicked");
    [PFUser logOut];
    MyLogInViewController *logInViewController = [[MyLogInViewController alloc] init];
    logInViewController.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    logInViewController.delegate = self;
    logInViewController.fields =   PFLogInFieldsTwitter;

    [self presentViewController:logInViewController animated:YES completion:NULL];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.label.center = CGPointMake(floorf((self.view.bounds.size.width - self.sidePanelController.rightVisibleWidth) + self.sidePanelController.rightVisibleWidth/2.0f), 25.0f);
}

@end
