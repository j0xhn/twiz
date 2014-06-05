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

