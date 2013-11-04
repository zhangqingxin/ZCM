//
//  AppDelegate.m
//  OrgMobiManager
//
//  Created by ZQX on 13-10-27.
//  Copyright (c) 2013年 ZhangQingxin. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window, navigationController;

- (void)applicationDidFinishLaunching:(UIApplication*)application
{
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    if (!window)
    {
        return;
    }
    window.backgroundColor = [UIColor blackColor];
    
	navigationController = [[UINavigationController alloc] initWithRootViewController:
							[[RootViewController alloc] init]];
	navigationController.navigationBar.tintColor = COLOR(2, 100, 162);
	
    [window addSubview:navigationController.view];
    [window makeKeyAndVisible];
    [window layoutSubviews];
    
}

@end
