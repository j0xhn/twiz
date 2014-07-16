//
//  MyEmptyBucketViewController.m
//  twiz
//
//  Created by John D. Storey on 7/12/14.
//
//

#import "MyTwitterController.h"
#import "MyEmptyBucketViewController.h"
#import "MyConstants.h"

@interface MyEmptyBucketViewController ()

@end

@implementation MyEmptyBucketViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithPatternImage:PURPLE_BACKGROUND];
    
    UILabel *headline = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, self.view.bounds.size.width, 40)];
    headline.text = @"Whoops!";
    headline.textColor = [UIColor whiteColor];
    headline.textAlignment = NSTextAlignmentCenter;
    UIFont *museoTitleFont = [UIFont fontWithName:@"MuseoSansRounded-900" size:40.0];
    headline.font = museoTitleFont;
    headline.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:headline];
    
    // tagline
    UILabel *taglineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 240, self.view.bounds.size.width, 40)];
    taglineLabel.text = @"You ran out of tweets. Wait a bit and try again";
    taglineLabel.textColor = [UIColor whiteColor];
    taglineLabel.textAlignment = NSTextAlignmentCenter;
    
    UIFont *museoTagLineFont = [UIFont fontWithName:@"MuseoSansRounded-300" size:14.0];
    taglineLabel.font = museoTagLineFont;
    taglineLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:taglineLabel];
    
    // makes my custom button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(reloadTweets)
     forControlEvents:UIControlEventTouchUpInside];
    
    [button setTitle:@"Try Reloading Tweets" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIFont *museoButtonFont = [UIFont fontWithName:@"MuseoSansRounded-500" size:18.0];
    [button setFont:museoButtonFont];
    button.frame = CGRectMake(60.0, 287.0, 200.0, 40.0);
    [[button layer] setCornerRadius:5.0f];
    [[button layer] setBorderWidth:1.0f];
    [[button layer] setBorderColor:[UIColor whiteColor].CGColor];
    [self.view addSubview:button];
    
}

- (void)reloadTweets{
    NSLog(@"You wanna reload");
    [[MyTwitterController sharedInstance] loadTweetBucketDictionaryWithCompletion:^(bool success) {
        if (success) { // on success
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"resetActiveTweetNotification"
                 object:nil];
            });
            [self dismissViewControllerAnimated:YES completion:nil];
        } else { // on error
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Not Quite Yet"
                                                              message:@"Looks like you're twitter feed still hasn't refreashed.  Try back again in 30 minutes."
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            
            [message show];
        }
        
    }];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
