//
//  AppDelegate.m
//  weather
//
//  Created by hp on 6/23/16.
//  Copyright © 2016 hp. All rights reserved.
//

#import "AppDelegate.h"
#import "Foundation+Log.h"
#import "ZSRMainViewController.h"
#import "ZSRAddCityController.h"
#import "AFNetworking.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [NSThread sleepForTimeInterval:2];//设置启动页面时间
    [application setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    self.window  = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    ZSRAddCityController *addController = [[ZSRAddCityController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:addController];
    self.window.rootViewController = nvc;
    
    BOOL login = [userDefault boolForKey:@"isLogin"];
    if (login) {
        ZSRMainViewController *mainController = [ZSRMainViewController sharedMainViewController];
        [nvc pushViewController:mainController animated:NO];
    }
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    [self networkChange];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];

}

- (void)applicationDidEnterBackground:(UIApplication *)application {

}

- (void)applicationWillEnterForeground:(UIApplication *)application {

}

- (void)applicationDidBecomeActive:(UIApplication *)application {

}
- (void)applicationWillTerminate:(UIApplication *)application {

}


//网络改变
-(void)networkChange{
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        // 当网络状态发生改变的时候调用这个block
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWiFi:
            case AFNetworkReachabilityStatusReachableViaWWAN:
                [dict setValue:networkStatusEnable forKey:networkStatus];
                NSLog(@"有网");
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                [dict setValue:networkStatusNotEnable forKey:networkStatus];
                NSLog(@"断网了");
                break;
                
            case AFNetworkReachabilityStatusUnknown:
                [dict setValue:networkStatusUnkonwn forKey:networkStatus];
                break;
            default:
                [dict setValue:NULL forKey:networkStatus];
                break;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:networkChangeNotification object:nil userInfo:dict];

        });

    }];
    [mgr startMonitoring];
}

@end
