//
//  PersonInfo.h
//  OrgMobiManager
//
//  Created by ZQX on 13-10-31.
//  Copyright (c) 2013年 ZhangQingxin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PersonInfo : NSObject

@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* mobilephone;
@property (nonatomic, copy) NSString* workphone;
@property (nonatomic, copy) NSString* email;
@property (nonatomic, copy) NSString* address;

//-(void) initWithName:(NSString *)name mobilePhone:(NSString *)mobilephone workPhone:(NSString *)workphone email:(NSString *)email;

@end
