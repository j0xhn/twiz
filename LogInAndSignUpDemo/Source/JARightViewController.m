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
#import "MyTwitterController.h"
#import "UIViewController+JASidePanel.h"
#import "MyConstants.h"
#import <Twitter/Twitter.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface JARightViewController () <MFMailComposeViewControllerDelegate>

@end

@implementation JARightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *rightView = [[UIView alloc]initWithFrame:self.view.bounds];
    rightView.backgroundColor = SIDE_PANEL_COLOR;
    [self.view insertSubview:rightView aboveSubview:self.view];
    
    // rate button
    UIButton *rateAppBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rateAppBtn setTitle:NSLocalizedString(@"Rate", nil) forState:UIControlStateNormal];
    [rateAppBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    rateAppBtn.titleLabel.font = TWIZ_FONT_300_22;
    rateAppBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [rateAppBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 70.0f, 0.0f, 0.0f)];
    rateAppBtn.frame = CGRectMake(100, 50, 180, 50);
    [rateAppBtn addTarget:self
                   action:@selector(rateApp)
         forControlEvents:UIControlEventTouchUpInside];
    UIImageView *rateIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_star.png"]];
    [rateIconImageView setFrame:CGRectMake(0, 0, 50, 50)];
    [rateAppBtn addSubview:rateIconImageView];
    
    // feedback button
    UIButton *feedbackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [feedbackBtn setTitle:NSLocalizedString(@"Feedback", nil) forState:UIControlStateNormal];
    feedbackBtn.titleLabel.font = TWIZ_FONT_300_22;
    feedbackBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [feedbackBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 70.0f, 0.0f, 0.0f)];
    feedbackBtn.frame = CGRectMake(100, 130, 180, 50);
    [feedbackBtn addTarget:self
                   action:@selector(giveFeedback)
         forControlEvents:UIControlEventTouchUpInside];
    UIImageView *feedbackIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_feedback.png"]];
    [feedbackIconImageView setFrame:CGRectMake(0, 0, 50, 50)];
    [feedbackBtn addSubview:feedbackIconImageView];

    // share button
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareBtn setTitle:NSLocalizedString(@"Share", nil) forState:UIControlStateNormal];
    shareBtn.titleLabel.font = TWIZ_FONT_300_22;
    shareBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [shareBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 70.0f, 0.0f, 0.0f)];
    shareBtn.frame = CGRectMake(100, 210, 180, 50);
    [shareBtn addTarget:self
                  action:@selector(sendTweet)
        forControlEvents:UIControlEventTouchUpInside];
    UIImageView *shareIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_twitter.png"]];
    [shareIconImageView setFrame:CGRectMake(0, 0, 50, 50)];
    [shareBtn addSubview:shareIconImageView];
    
    //logout Button
    UIButton *logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoutBtn setTitle:NSLocalizedString(@"Logout", nil) forState:UIControlStateNormal];
    logoutBtn.titleLabel.font = TWIZ_FONT_300_22;
    logoutBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [logoutBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 70.0f, 0.0f, 0.0f)];
    logoutBtn.frame = CGRectMake(100, 290, 180, 50);
    [logoutBtn addTarget:self
                 action:@selector(twitterLogOut)
       forControlEvents:UIControlEventTouchUpInside];
    UIImageView *logoutIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_logout.png"]];
    [logoutIconImageView setFrame:CGRectMake(0, 0, 50, 50)];
    [logoutBtn addSubview:logoutIconImageView];
    
    [rightView addSubview:rateAppBtn];
    [rightView addSubview:feedbackBtn];
    [rightView addSubview:shareBtn];
    [rightView addSubview:logoutBtn];
    


}

-(void)rateApp{
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Not Quite Yet"
                                                      message:@"Looks like we haven't hooked up this functionality, you must be an early adopter :)"
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    
    [message show];

}

-(void)giveFeedback{
    
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:@"Twiz Feedback"];
        [mailer setToRecipients:@[@"johndangerstorey@gmail.com"]];
        NSString *emailBody = @"I really like your app but it'd be cooler if...";
        [mailer setMessageBody:emailBody isHTML:NO];
        [self presentModalViewController:mailer animated:YES];
        
    }
    else { // if error
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"Your device doesn't support sending email"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
}

-(void)sendTweet{
    
    SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    [vc setInitialText:@"I pitty da fool dat don't donwload El Twiz so they can make money while on twitter."];    // Settin The Initial Text
    UIImage *image = [UIImage imageNamed:@"mrT.jpg"];    // Adding an Image
    [vc addImage:image];
    NSURL *url = [NSURL URLWithString:@"http://dev.johndangerstorey.com"];     // Adding a URL
    [vc addURL:url];
    [self presentViewController:vc animated:YES completion:nil];
    
    [vc setCompletionHandler:^(TWTweetComposeViewControllerResult result) {     // Setting a Completing Handler
        
        [self dismissModalViewControllerAnimated:YES];
    }];

}

- (void)twitterLogOut{
    NSLog(@"Log Out Clicked");
    [[MyTwitterController sharedInstance] saveUserInfo];
    MyLogInViewController *logInViewController = [[MyLogInViewController alloc] init];
    logInViewController.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    logInViewController.delegate = self;
    logInViewController.fields =   PFLogInFieldsTwitter;
//    [self.sidePanelController showCenterPanelAnimated:YES];
    [self presentViewController:logInViewController animated:YES completion:NULL];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    
    // Remove the mail view
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.label.center = CGPointMake(floorf((self.view.bounds.size.width - self.sidePanelController.rightVisibleWidth) + self.sidePanelController.rightVisibleWidth/2.0f), 25.0f);
}
@end
