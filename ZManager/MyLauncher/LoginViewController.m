//
//  LoginViewController.m
//  OrgMobiManager
//
//  Created by ZQX on 13-10-29.
//  Copyright (c) 2013年 ZhangQingxin. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UILabel *error;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;

@property (strong, nonatomic) NSMutableData *loginResult;

- (IBAction)doLogin:(id)sender;

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = COLOR(2, 100, 162);
	[self.view setBackgroundColor:COLOR(234,237,250)];
    self.error.text = @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doLogin:(id)sender {
    self.error.text = @"";
    NSString *username = self.username.text;
    NSString *password = self.password.text;
    if (username.length==0||password.length==0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"请输入用户名和密码登陆。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        [self checkId:username withPassword:password];
    }
}

- (void) checkId:(NSString *)username withPassword:(NSString *)password {
    NSLog(@"UserName: %@, Password: %@", username, password);
    NSString *loginUrl = @"http://www.greatestzhang.com/login.html";
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:loginUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSLog(@"URL: %@", loginUrl);
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if (theConnection) {
        if (!_loginResult) {
            self.loginResult = [NSMutableData data];
        }
    } else {
        self.error.text = @"网络错误，请重试！";
        NSLog(@"Error on checkID");
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
}

-(void)connection:connection didReceiveData:(NSData *)data {
    [self.loginResult appendData:data];
}

-(void)connection:connection didFailWithError:(NSError *)error {
    self.error.text = @"网络错误，请重试！";
}

- (void)connectionDidFinishLoading: (NSURLConnection *) connection {
    NSString *result = [[NSString alloc] initWithData:self.loginResult encoding:NSUTF8StringEncoding];
    
    NSError *error;
    id loginInfo = [NSJSONSerialization JSONObjectWithData:self.loginResult options:NSJSONReadingAllowFragments error: &error];
    
    if (nil != loginInfo) {
        if ([loginInfo isKindOfClass:[NSDictionary class]]){
            NSDictionary *resultDic = (NSDictionary *)loginInfo;
            NSString *success =[resultDic objectForKey:@"result"];
            if ([success isEqualToString:@"1"]) {
                AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                appDelegate.username = self.username.text;
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                self.error.text = @"网络错误，请重试！";
            }
        } else {
            self.error.text = @"网络错误，请重试！";
        }
    } else {
        self.error.text = @"网络错误，请重试！";
    }
    NSLog(@"Response: %@", result);
}
@end
