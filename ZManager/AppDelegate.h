//
//  AppDelegate.h
//  OrgMobiManager
//
//  Created by ZQX on 13-10-27.
//  Copyright (c) 2013年 ZhangQingxin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@class MyLauncherViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSNumber *sysver;
@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;

@end

