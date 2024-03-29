//
//  AppDelegate.m
//  LogInAndSignUpDemo
//
//  Created by Mattieu Gamache-Asselin on 6/14/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "AppDelegate.h"
#import "MyCenterViewController.h"
#import "JASidePanelController.h"
#import "JALeftViewController.h"
#import "JARightViewController.h"

//#import <SEGAnalytics.h>
#import <Crashlytics/Crashlytics.h>


@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;


#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent];
    
    // ****************************************************************************
    // Fill in with your Parse and Twitter credentials. Don't forget to add your
    // Facebook id in Info.plist:
    // ****************************************************************************
    [Parse setApplicationId:@"BYtF2ZQMPHkhm8kQzZKgJSXh19Tk02661aGeHQSV" clientKey:@"wCCqhl3GrlEOzESzPGRc1bkcyewI8Qi8KsUtdfhi"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [PFTwitterUtils initializeWithConsumerKey:@"XEiHejzzFjNIzEy2bSNEug" consumerSecret:@"uEeJboXD9ZF3V8sRs89pWpGngF53xqsBd9sTT8GfE"];
    
    // SEG Analytics not working.  Lets switch to Google Analytics
    // [SEGAnalytics setupWithConfiguration:[SEGAnalyticsConfiguration configurationWithWriteKey:@"vspssh598g"]];
    // Crashlytics
    [Crashlytics startWithAPIKey:@"bf558a6cef31aa4273fd55371f9d5ae2cd97e01c"];
    
    // Set default ACLs for Parse
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	self.viewController = [[JASidePanelController alloc] init];
    self.viewController.shouldDelegateAutorotateToVisiblePanel = NO;
    
	self.viewController.leftPanel = [[JALeftViewController alloc] init];
	self.viewController.centerPanel = [[UINavigationController alloc] initWithRootViewController:[[MyCenterViewController alloc] init]];
	self.viewController.rightPanel = [[JARightViewController alloc] init];
	
	self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url];
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
    NSLog(@"App Entered Background, send notification to store values");
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"saveUserInfoNotification"
     object:nil];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"Became active - not currently sending any sort of notification");
    [[PFUser currentUser] refresh];

}

@end
