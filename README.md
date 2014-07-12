Twiz
===
the twitter quiz game

Built for Mark
```
Mark is a 30 year old guy that is checking his twitter while sitting on the toilet, when things get slow at work, in the checkout line, whenever he rides the train to and from work, and whenever his wife is talking and talking and talking and taaaaaalking....  yeah, he checks them a lot.  

He likes to click and read articles from his news sources, but also loves to just see what his friends are up to.  He feels like he wastes his time on twitter, but loves it so much that he really doesn't care.  When he finds out he can earn amazon gift cards by going through his twitter feed... he is going to crap his pants, download the app, and tell everyone about his new quadcopter he just bought using his giftcard, which his friends will read about on Twiz :)

```

works for tweeting, found at https://parse.com/questions/twitter-tweeting-problems

```

- (void)postStatus:(NSString *)status {
    // Construct the parameters string. The value of "status" is percent-escaped.
    NSString *bodyString = [NSString stringWithFormat:@"status=%@", [status stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    // Explicitly percent-escape the '!' character.
    bodyString = [bodyString stringByReplacingOccurrencesOfString:@"!" withString:@"%21"];

    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
    NSMutableURLRequest *tweetRequest = [NSMutableURLRequest requestWithURL:url];
    tweetRequest.HTTPMethod = @"POST";
    tweetRequest.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];

    [[PFTwitterUtils twitter] signRequest:tweetRequest];

    NSURLResponse *response = nil;
    NSError *error = nil;

    // Post status synchronously.
    NSData *data = [NSURLConnection sendSynchronousRequest:tweetRequest
                                         returningResponse:&response
                                                     error:&error];

    // Handle response.
    if (!error) {
        NSLog(@"Response: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    } else {
        NSLog(@"Error: %@", error);
    }
}
```
works for getting pictures if you swap out user.username with actuall twitter acount handle: http://stackoverflow.com/questions/18917651/how-to-get-twitter-profile-picture-in-ios
```
            // TODO find a way to fetch details with Twitter..
            
            NSString * requestString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/users/show.json?screen_name=%@", user.username];
            
            NSLog(@"username:%@", user.username);
            
            
            NSURL *verify = [NSURL URLWithString:requestString];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:verify];
            [[PFTwitterUtils twitter] signRequest:request];
            NSURLResponse *response = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&response
                                                             error:&error];
            
            
            if ( error == nil){
                NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                NSLog(@"%@",result);
                
                [user setObject:[result objectForKey:@"profile_image_url_https"]
                         forKey:@"picture"];
                // does this thign help?
                [user setUsername:[result objectForKey:@"screen_name"]];
                
                NSString * names = [result objectForKey:@"name"];
                NSMutableArray * array = [NSMutableArray arrayWithArray:[names componentsSeparatedByString:@" "]];
                if ( array.count > 1){
                    [user setObject:[array lastObject]
                             forKey:@"last_name"];
                    
                    [array removeLastObject];
                    [user setObject:[array componentsJoinedByString:@" " ]
                             forKey:@"first_name"];
                }
                
                [user saveInBackground];
            }

```
works for accessing twitter object

```
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    // Create an account type that ensures Twitter accounts are retrieved.
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    // Request access from the user to use their Twitter accounts.
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        
        if(granted) {
            // Get the list of Twitter accounts.
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            
            // For the sake of brevity, we'll assume there is only one Twitter account present.
            // You would ideally ask the user which account they want to tweet from, if there is more than one Twitter account present.
            if ([accountsArray count] > 0) {
                // Grab the initial Twitter account to tweet from.
                ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                NSLog(@"twitter account %@", twitterAccount);
                
                //At this point, the twitterAccount has been pulled into the *twitterAccount object.
            }
        }
    }];
```

giving me 
```
type:com.apple.twitter
identifier: D9F82BCD-4C85-4F48-814D-86AA1CFA2973
active: YES
accountDescription: @johnDANGRstorey
username: johnDANGRstorey
objectID: x-coredata://4BBE83B9-8C9E-4A9C-A61B-7515D1548805/Account/p1
provisionedDataclasses: {()}
enabledDataclasses: {()}
enableAndSyncableDataclasses: {()}
dataclassProperties: (null)
properties: {
    "user_id" = 154177060;
}
parentAccount: (null)
owningBundleID:com.apple.Preferences
authenticated: YES
lastCredentialRenewalRejectedDate: (null)
supportsAuthentication: YES
authenticationType: (null)
credentialType: (null)
created: Wednesday, June 4, 2014 at 10:54:19 PM Mountain Daylight Time
active: YES
visible: YES

```
