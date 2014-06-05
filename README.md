Twiz
===
the twitter quiz game

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

