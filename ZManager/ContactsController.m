//
//  ContactsController.m
//  OrgMobiManager
//
//  Created by ZQX on 13-10-30.
//  Copyright (c) 2013年 ZhangQingxin. All rights reserved.
//

#import "ContactsController.h"
#import "PersonInfo.h"
#import "MProgressAlertView.h"
#import "Constants.h"

@implementation ContactsController

-(ContactsController*) initWithRootController:(UIViewController *)controller {
    ContactsController *c = [self init];
    rootController = controller;
    needCancel = false;
    return c;
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    int type = alertView.tag;
    switch (type) {
        case CONTACTS_ASK_ALERT:
            if (buttonIndex == 1) {
                if ([self requestPermission]) {
                    [self showSyncDialog];
                }
            }
            break;
            
        default:
            break;
    }
}


-(void) showAskDialog {
    UIAlertView *askAlert = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"是否需要同步通讯录？" delegate:rootController cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    askAlert.tag = CONTACTS_ASK_ALERT;
    [askAlert show];
}

-(BOOL) requestPermission {
    CFErrorRef *myError = NULL;
    ABAddressBookRef aBook = ABAddressBookCreateWithOptions(NULL, myError);
    __block BOOL accessGranted = NO;
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(aBook, ^(bool granted, CFErrorRef error) {
            // First time access has been granted, add the contact
            accessGranted = granted;
        });
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
        accessGranted = YES;
    } else {
        UIAlertView *askAlert = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"无法读取通讯录，请在设置中打开读取通讯录权限。" delegate:rootController cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [askAlert show];
    }
    return accessGranted;
}


-(void)showSyncDialog {
    
    syncProgressAlert = [[MProgressAlertView alloc] initWithTitle:@"同步通讯录" message:@"同步中..." delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
    [syncProgressAlert show];
    [self sendRequest];
}

- (void)changePercentage:(NSNumber *)percentage {
    if ([percentage floatValue] >= 1.0f) {
        [syncProgressAlert dismissWithClickedButtonIndex:-1 animated:YES];
    } else {
        syncProgressAlert.progressView.progress = [percentage floatValue];
        syncProgressAlert.progressLabel.text = [NSString stringWithFormat:@"%d%%",(int)(100*[percentage floatValue])];
    }
}


-(void)sendRequest {
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.greatestzhang.com/ioscontacts.html"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
        [self changePercentage:[NSNumber numberWithFloat: 0.3f]];
        receivedData = [NSMutableData data];
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection  {
    NSString *result = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    if (IS_DEBUG) {
        NSLog(@"Response: %@", result);
    }

    [self changePercentage:[NSNumber numberWithFloat: 0.4f]];
    [self processData];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
}

-(void)processData {
    
    NSMutableArray *contacts = [self paserJson];

    if (groupName != nil && groupName != NULL && contacts != nil && contacts != NULL && [contacts count] > 0) {
        
        if (!needCancel) {
            [self cleanOldData];
        }
        if (!needCancel) {
            [self addPersonToGroup:groupName withPersons:contacts];
        }
        [self changePercentage:[NSNumber numberWithFloat: 1.0f]];
        [self showSuccessDialog: [NSNumber numberWithInteger:contacts.count]];
    } else {
        [self showFaildDialog];
    }
}

-(void)showSuccessDialog: (NSNumber *)count {
    NSString *msg = [NSString stringWithFormat:@"同步 %@ 个联系人。",count];
    UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"成功" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [successAlert show];
}

-(void)showFaildDialog {
    [syncProgressAlert dismissWithClickedButtonIndex:-1 animated:NO];
    UIAlertView *faildAlert = [[UIAlertView alloc] initWithTitle:@"失败" message:@"同步失败，请重试。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [faildAlert show];
}

-(NSMutableArray *) paserJson {
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingMutableContainers error:&error];
    if (json == nil) {
        NSLog(@"Error with paser json....");
    }
    groupName = [json objectForKey:@"group"];
    NSArray *contacts = [json objectForKey:@"contacts"];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dic in contacts) {
        PersonInfo *info = [[PersonInfo alloc] init];
        info.name = [dic objectForKey:@"name"];
        if ([[dic objectForKey:@"mobile"] isKindOfClass:[NSNumber class]] ) {
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            info.mobilephone = [formatter stringFromNumber:[dic objectForKey:@"mobile"]];
        } else {
            info.mobilephone = [dic objectForKey:@"mobile"];
        }
        info.address = [dic objectForKey:@"address"];
        [array addObject:info];
        
        if (IS_DEBUG) {
            NSLog(@"Group: %@", groupName);
            NSLog(@"Name: %@", [dic objectForKey:@"name"]);
            NSLog(@"Moblie: %@", [dic objectForKey:@"mobile"]);
            NSLog(@"Address: %@", [dic objectForKey:@"address"]);
            
        }
    }
    
    [self changePercentage:[NSNumber numberWithFloat: 0.5f]];
    return array;
}


- (void) cleanOldData {
    //Delete all person in the group that the name same as server
    
    CFErrorRef *error = NULL;
    ABAddressBookRef book = ABAddressBookCreateWithOptions(nil, error);
        
    //Get group which the name same as server
    CFArrayRef groupArrayRef = ABAddressBookCopyArrayOfAllGroups(book);

    if (groupArrayRef != nil && groupArrayRef != NULL && CFArrayGetCount(groupArrayRef) > 0) {
        for (CFIndex i = CFArrayGetCount(groupArrayRef)-1; i >= 0; i--) {
            ABRecordRef groupRef = (ABRecordRef) CFArrayGetValueAtIndex(groupArrayRef, i);
            CFStringRef groupNameRef = (CFStringRef) ABRecordCopyValue(groupRef, kABGroupNameProperty);
            NSString *localGroupName = (__bridge NSString *)groupNameRef;
            if ([localGroupName isEqualToString:groupName] == YES) {
                //Delete the persons in the group
                CFArrayRef personArrayRef = ABGroupCopyArrayOfAllMembers(groupRef);
                if (personArrayRef != nil && personArrayRef != NULL && CFArrayGetCount(personArrayRef) > 0) {
                    for (int i=0; i<CFArrayGetCount(personArrayRef); i++) {
                        ABRecordRef personRef = (ABRecordRef) CFArrayGetValueAtIndex(personArrayRef, i);
                        ABAddressBookRemoveRecord(book, personRef, error);
                        ABAddressBookSave(book, error);
                        CFRelease(personRef);
                    }
                }
                    
                //Delete the group
                ABAddressBookRemoveRecord(book, groupRef, error);
                ABAddressBookSave(book, error);
                CFRelease(groupNameRef);
                CFRelease(groupRef);
            }
                
        }
    }
    
    CFRelease(book);


    [self changePercentage:[NSNumber numberWithFloat: 0.6f]];
}



- (void)addGroup:(NSString *) groupname {
    CFErrorRef *myError = NULL;
    CFStringRef string=(__bridge CFStringRef) groupname;
    ABAddressBookRef aBook = ABAddressBookCreateWithOptions(NULL, myError);
    ABRecordRef newGroup = ABGroupCreate();
    ABRecordSetValue(newGroup, kABGroupNameProperty, string, nil);
    ABAddressBookAddRecord(aBook, newGroup, nil);
    ABAddressBookSave(aBook, nil);
    CFRelease(newGroup);
    CFRelease(aBook);
}


-(void)addPersonToGroup:(NSString *)name withPersons: (NSArray *) contacts {
    CFErrorRef *error = NULL;
    [self changePercentage:[NSNumber numberWithFloat: 0.7f]];
    //Create Group
    CFStringRef nameRef =(__bridge CFStringRef) name;
    ABAddressBookRef book = ABAddressBookCreateWithOptions(NULL, error);
    ABRecordRef groupRef = ABGroupCreate();
    ABRecordSetValue(groupRef, kABGroupNameProperty, nameRef, nil);
    ABAddressBookAddRecord(book, groupRef, nil);
    ABAddressBookSave(book, nil);
    
    //AddPerson
    for (int i=0; i<[contacts count]; i++) {        
        PersonInfo *info = [contacts objectAtIndex:i];
        ABRecordRef personRef = ABPersonCreate();

        if (info.name != NULL && info.name != nil) {
            ABRecordSetValue(personRef, kABPersonFirstNameProperty, (__bridge CFStringRef)(info.name), error);
        }
        
        if (info.address != NULL && info.address != nil) {
            ABMutableMultiValueRef multiAddress = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
            CFErrorRef anError = NULL;
            ABMultiValueIdentifier multivalueIdentifier;
            
            NSMutableDictionary *addressDictionary = [[NSMutableDictionary alloc] init];
            [addressDictionary setObject:info.address forKey:(NSString *) kABPersonAddressStreetKey];
            
            ABMultiValueAddValueAndLabel(multiAddress, (__bridge CFTypeRef)(addressDictionary), kABHomeLabel, &multivalueIdentifier);
            ABRecordSetValue(personRef, kABPersonAddressProperty, multiAddress, &anError);
            CFRelease(multiAddress);
        }
        
        if (info.mobilephone != NULL && info.mobilephone != nil) {
            ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
            CFErrorRef anError = NULL;
            ABMultiValueIdentifier multivalueIdentifier;
            ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(info.mobilephone), kABPersonPhoneMobileLabel, &multivalueIdentifier);
            ABRecordSetValue(personRef, kABPersonPhoneProperty, multiPhone, &anError);
            CFRelease(multiPhone);
        }

        
        ABAddressBookAddRecord(book, personRef, error);
        CFRelease(personRef);
        if (ABAddressBookSave(book, error)) {
            if (IS_DEBUG) {
                NSLog(@"Name: %@", info.name);
                NSLog(@"Save to AddressBook success");
            }

            if (ABGroupAddMember(groupRef, personRef, error)) {
                if (IS_DEBUG) {
                    ABAddressBookSave(book, error);
                    NSLog(@"Add to Group success");
                }
            } else {
                [self showFaildDialog];
                if (IS_DEBUG) {
                    NSLog(@"Add to Group faild");
                }
            }
        } else {
            [self showFaildDialog];
        }

        
    }

    CFRelease(groupRef);
    CFRelease(book);
    [self changePercentage:[NSNumber numberWithFloat: 0.8f]];
}

@end
