//
//  RMAppDelegate.m
//  SwipeProject
//
//  Created by ramonqlee on 5/4/13.
//  Copyright (c) 2013 ramonqlee. All rights reserved.
//

#import "RMAppDelegate.h"
#import "SideBarViewController.h"
#import "RMLeftSideViewController.h"
#import "RMRightSideViewController.h"
#import "RMTabbedViewController.h"


@implementation RMAppDelegate

#pragma mark SideBarViewControllerDelegate
- (UIViewController*)middleViewController
{
    //TODO::subchannel of current channel
    NSString* title = nil;
    NSString* url = nil;
    NSUserDefaults* setting = [NSUserDefaults standardUserDefaults];
    NSDictionary* dict = [setting objectForKey:kAsterName];
    if (dict) {
        title = [dict objectForKey:kTitle];
        url = [dict objectForKey:kUrl];
    }
    
    return [[[RMTabbedViewController alloc]init:url withTitle:title]autorelease];
}
-(UIViewController*)leftViewController:(id<SiderBarDelegate>)delegate
{
    //TODO::channel views
    RMLeftSideViewController* left = [[[RMLeftSideViewController alloc]init]autorelease];
    left.delegate = delegate;
    return left;
}
-(UIViewController*)rightViewController:(id<SiderBarDelegate>)delegate
{
    //TODO::settings,recommend,etc
    return nil;
//    RMRightSideViewController* right= [[[RMRightSideViewController alloc]init]autorelease];
//    right.delegate = delegate;
//    return [[[UINavigationController alloc]initWithRootViewController:right]autorelease];
}

- (void)showSideBarControllerWithDirection:(SideBarShowDirection)direction
{
    if (self.sideBarController) {
        [self.sideBarController showSideBarControllerWithDirection:direction];
    }
}

#pragma mark AppDelegate
- (void)dealloc
{
    
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    [self setDefaultSettingsIfNotSet];
    
    self.sideBarController = [[SideBarViewController alloc]initWithNibName:@"SideBarViewController" bundle:nil];
    self.sideBarController.delegate = self;
    self.window.rootViewController = self.sideBarController;
    [self.window makeKeyAndVisible];
    return YES;
}
//当首次进入时，设置程序的初始值
-(void)setDefaultSettingsIfNotSet
{
    NSUserDefaults* setting = [NSUserDefaults standardUserDefaults];
    NSDictionary* dict = [setting objectForKey:kAsterName];
    if (!dict) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"LeftChannels" ofType:@"plist"];
        NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        NSLog(@"%@", data);//直接打印数据
        //add into section
        for (NSDictionary* item in [data allValues]) {
            //set
            [setting setObject:item forKey:kAsterName];
            [setting synchronize];
            break;
        }
    }
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
