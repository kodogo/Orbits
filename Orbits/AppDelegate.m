//
//  AppDelegate.m
//  Orbits
//
//  Created by ajs on 15/8/15.
//  Copyright (c) 2015 ajs. All rights reserved.
//

#import "AppDelegate.h"
#import "OrbitsViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

OrbitsViewController *ovc;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	// Override point for customization after application launch.

	NSBundle *appBundle = [NSBundle mainBundle];
	ovc = [[OrbitsViewController alloc] initWithNibName:@"OrbitsViewController"
										   bundle:appBundle];
	 	
	self.window.rootViewController= ovc;
	
	self.window.backgroundColor = [UIColor whiteColor];
	[self.window makeKeyAndVisible];
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[ovc pause];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[ovc resume];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
