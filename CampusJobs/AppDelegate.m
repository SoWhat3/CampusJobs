//
//  AppDelegate.m
//  CampusJobs
//
//  Created by Sophia Zheng on 7/6/18.
//  Copyright © 2018 So What. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    ParseClientConfiguration *config = [ParseClientConfiguration   configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        
        configuration.applicationId = @"soWhatCampusJobs";
        configuration.clientKey = @"soWhat3";
        configuration.server = @"http://campus-jobs.herokuapp.com/parse";
    }];
    
    [Parse initializeWithConfiguration:config];
    
    // user persists
    if (PFUser.currentUser) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"tabBarController"];
        
        
 /////////////////////////////////
        [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:27.0/255.0 green:65.0/255.0 blue:113.0/255.0 alpha:1.0]];
        
        [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:27.0/255.0 green:65.0/255.0 blue:113.0/255.0 alpha:1.0]}];
        
        [[UITabBar appearance] setTintColor:[UIColor colorWithRed:27.0/255.0 green:65.0/255.0 blue:113.0/255.0 alpha:1.0]];

    }
    
    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}








@end
