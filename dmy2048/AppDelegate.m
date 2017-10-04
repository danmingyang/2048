//
//  AppDelegate.m
//  dmy2048
//
//  Created by dmy on 2017/10/2.
//  Copyright © 2017年 dmy. All rights reserved.
//

#import "AppDelegate.h"
#import "PlayGameViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    PlayGameViewController *rootViewController = [[PlayGameViewController alloc] init];
    self.window.rootViewController = rootViewController;
    //makeKeyWindow 让当前UIWindow变成keyWindow（主窗口）
    //makeKeyAndVisible 让当前UIWindow变成keyWindow，并显示出来
    //[UIApplication sharedApplication].windows 获取当前应用的所有的UIWindow
    //[UIApplication sharedApplication].keyWindow 获取当前应用的主窗口
    //view.window 获得某个UIView所在的UIWindow
    [self.window makeKeyAndVisible];
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
