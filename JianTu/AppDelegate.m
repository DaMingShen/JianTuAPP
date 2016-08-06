//
//  AppDelegate.m
//  JianTu
//
//  Created by KevinSu on 16/7/31.
//  Copyright © 2016年 KevinSu. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "WZNetworkMonitor.h"
#import <UMSocial.h>
#import <UMSocialWechatHandler.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    HomeViewController * homeVC = [[HomeViewController alloc]init];
    self.window.rootViewController = homeVC;
    [self.window makeKeyAndVisible];
    
    //网络监听
    [[WZNetworkMonitor monitor]start];
    
    //自动处理键盘事件
    [IQKeyboardManager sharedManager].enable = YES;
    
    //加载字体
    [[FontManager manager]loadFont];
    
    //初始化友盟
    [UMSocialData setAppKey:@"56a4941667e58e200d001b8d"];
    [UMSocialWechatHandler setWXAppId:@"wxf8ce75c31226366a" appSecret:@"4692af8d31f541dba7b1a2ffbcd29019" url:@"www.baidu.com"];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
