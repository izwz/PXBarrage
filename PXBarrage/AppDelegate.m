//
//  AppDelegate.m
//  PXBarrage
//
//  Created by WZH ZHANG on 2022/5/11.
//

#import "AppDelegate.h"
#import "PXBarrageViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    PXBarrageViewController *vc = [[PXBarrageViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    return YES;
    return YES;
}




@end
