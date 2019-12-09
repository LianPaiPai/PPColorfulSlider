//
//  AppDelegate.m
//  PPColorfulSlider
//
//  Created by 拍拍 on 2019/12/9.
//  Copyright © 2019 PaiPai Lian. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    ViewController *vc = [[ViewController alloc]init];
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
