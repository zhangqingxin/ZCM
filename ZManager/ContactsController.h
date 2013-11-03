//
//  ContactsController.h
//  OrgMobiManager
//
//  Created by ZQX on 13-10-30.
//  Copyright (c) 2013年 ZhangQingxin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "MProgressAlertView.h"


static const int CONTACTS_ASK_ALERT = 110;
static const int CONTACTS_REQUEST_PERMISSION_FAILD = 120;

@interface ContactsController : NSObject {
    NSMutableData *receivedData;
    UIViewController *rootController;
    NSString *groupName;
    MProgressAlertView *syncProgressAlert;
    
    BOOL needCancel;
}

-(ContactsController*)initWithRootController:(UIViewController*) controller;
-(void)showAskDialog;
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
