//
//  AppDelegate.m
//  NaviTransition
//
//  Created by khl on 2016/11/20.
//  Copyright © 2016年 khl. All rights reserved.
//

#import "KHLAppDelegate.h"
#import "KHLRootNaviController.h"
#import "KHLRootViewController.h"

@interface KHLAppDelegate ()

@end

@implementation KHLAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    KHLRootViewController *rootVC = [KHLRootViewController new];
    
    KHLRootNaviController *rootNavi = [[KHLRootNaviController alloc] initWithRootViewController:rootVC];
    rootNavi.navigationBar.barTintColor = [UIColor yellowColor];
    rootNavi.transferNavigationBarAttributes = NO;
    self.window.rootViewController = rootNavi;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
