//
//  RootViewController.m
//  @rigoneri
//  
//  Copyright 2010 Rodrigo Neri
//  Copyright 2011 David Jarrett
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "RootViewController.h"
#import "MyLauncherItem.h"
#import "CustomBadge.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "ContactsController.h"
#import "AboutViewController.h"


@implementation RootViewController

-(void)loadView
{
    
	[super loadView];
    self.title = @"移动信息系统";
   
    UIBarButtonItem *loginBtn = [[UIBarButtonItem alloc] initWithTitle:@"登陆" style:UIBarButtonItemStyleBordered target:self action:@selector(loginAction:)];
    self.navigationItem.rightBarButtonItem = loginBtn;
    
    [[self appControllers] setObject:[AboutViewController  class] forKey:@"AboutViewController"];
    
    //Add your view controllers here to be picked up by the launcher; remember to import them above
	//[[self appControllers] setObject:[MyCustomViewController class] forKey:@"MyCustomViewController"];
	//[[self appControllers] setObject:[MyOtherCustomViewController class] forKey:@"MyOtherCustomViewController"];
	[self.launcherView setEditingAllowed: NO];
	if(![self hasSavedLauncherItems])
	{
		[self.launcherView setPages:[NSMutableArray arrayWithObjects: 
                                     [NSMutableArray arrayWithObjects: 
                                      [[MyLauncherItem alloc] initWithTitle:@"通讯录同步"
                                                                 iPhoneImage:@"contacts"
                                                                   iPadImage:@"contacts"
                                                                      target:@"ContactsController"
                                                                 targetTitle:@"通讯录同步"
                                                                   deletable:NO],
                                      [[MyLauncherItem alloc] initWithTitle:@"通知"
                                                                 iPhoneImage:@"message"
                                                                   iPadImage:@"message"
                                                                      target:@"ItemViewController" 
                                                                 targetTitle:@"通知"
                                                                   deletable:NO],
                                      [[MyLauncherItem alloc] initWithTitle:@"订餐"
                                                                 iPhoneImage:@"food"
                                                                   iPadImage:@"food"
                                                                      target:@"ItemViewController" 
                                                                 targetTitle:@"订餐"
                                                                   deletable:YES],
                                      [[MyLauncherItem alloc] initWithTitle:@"关于"
                                                                 iPhoneImage:@"about"
                                                                   iPadImage:@"about"
                                                                      target:@"AboutViewController"
                                                                 targetTitle:@"关于"
                                                                   deletable:NO],
                                      nil],
                                     nil]];
        
        // Set number of immovable items below; only set it when you are setting the pages as the 
        // user may still be able to delete these items and setting this then will cause movable 
        // items to become immovable.
//        [self.launcherView setNumberOfImmovableItems:4];
        
        // Or uncomment the line below to disable editing (moving/deleting) completely!
	}
    
    // Set badge text for a MyLauncherItem using it's setBadgeText: method
    [(MyLauncherItem *)[[[self.launcherView pages] objectAtIndex:0] objectAtIndex:1] setBadgeText:@"4"];
    
    // Alternatively, you can import CustomBadge.h as above and setCustomBadge: as below.
    // This will allow you to change colors, set scale, and remove the shine and/or frame.
//    [(MyLauncherItem *)[[[self.launcherView pages] objectAtIndex:0] objectAtIndex:1] setCustomBadge:[CustomBadge customBadgeWithString:@"2" withStringColor:[UIColor blackColor] withInsetColor:[UIColor whiteColor] withBadgeFrame:YES withBadgeFrameColor:[UIColor blackColor] withScale:0.8 withShining:NO]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	//If you don't want to support multiple orientations uncomment the line below
    //return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
	return [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if (appDelegate.username != nil) {
        self.navigationItem.rightBarButtonItem.title = @"登出";
    } else {
        self.navigationItem.rightBarButtonItem.title = @"登陆";
    }
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
}

-(void)loginAction:(id)sender {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if (appDelegate.username != nil) {
        appDelegate.username = nil;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"您已成功登出" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        self.navigationItem.rightBarButtonItem.title = @"登陆";
        [alert show];
    } else {
        LoginViewController *login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        UIBarButtonItem *returnButtonItem = [[UIBarButtonItem alloc] init];
        returnButtonItem.title = @"返回";
        login.title = @"登陆";
        self.navigationItem.backBarButtonItem = returnButtonItem;
        [self.navigationController pushViewController:login animated:YES];
    }
}


-(void) initControllerWithName:(NSString *)controllerName {
    if ([controllerName isEqualToString:@"ContactsController"]) {
        ContactsController *contacts = [[ContactsController alloc] initWithRootController:self];
        self.contactsController = contacts;
        [contacts showAskDialog];
    } else if ([controllerName isEqualToString:@"AboutViewController"]) {
//        AboutViewController *about = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
//        UIBarButtonItem *returnButtonItem = [[UIBarButtonItem alloc] init];
//        returnButtonItem.title = @"返回";
//        about.title = @"关于";
//        self.navigationItem.backBarButtonItem = returnButtonItem;
//        [self.navigationController pushViewController:about animated:YES];
    }
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    int type = alertView.tag;
    if (type >= 100 && type<200) {
        [self.contactsController alertView:alertView clickedButtonAtIndex:buttonIndex];
    }
}

@end
