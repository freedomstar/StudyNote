//
//  loginViewController.m
//  StudyNote
//
//  Created by 辉仔 on 2017/5/7.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import "loginViewController.h"
#import "userInstance.h"
#import <AFNetworking.h>
#import <JMRoundedCorner/JMRoundedCorner.h>
#import <MJRefresh.h>
#import <MBProgressHUD.h>
#import <MJExtension.h>

@interface loginViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *conentViewTopH;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property(strong,nonatomic)AFHTTPSessionManager*manager;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation loginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.manager = [AFHTTPSessionManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.loginButton.layer.cornerRadius=self.loginButton.frame.size.height/2;
    self.loginButton.layer.masksToBounds=YES;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(upViews:) name:UIKeyboardWillShowNotification object:nil];
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(downViews:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)upViews:(NSNotification *) notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int keyBoardHeight = keyboardRect.size.height;
    if (self.conentViewTopH.constant==0)
    {
        __weak typeof(self) weakself=self;
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:0.3
                         animations:^{
                             __strong __typeof(weakself)strongSelf = weakself;
                             strongSelf.conentViewTopH.constant=strongSelf.conentViewTopH.constant-keyBoardHeight+150;
                             [strongSelf.view layoutIfNeeded];
                         }];
    }
}

-(void)downViews:(NSNotification *) notification
{
    __weak typeof(self) weakself=self;
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.3
                     animations:^{
                         __strong __typeof(weakself)strongSelf = weakself;
                         strongSelf.conentViewTopH.constant=0;
                         [strongSelf.view layoutIfNeeded];
                     }];
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


- (IBAction)login:(id)sender
{
    [self.view endEditing:YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setDimBackground:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = @"登陆中";
    self.email.text=[self.email.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSDictionary *parameters=[[NSDictionary alloc] initWithObjectsAndKeys:self.email.text,@"email",self.password.text ,@"password",nil];
    __weak typeof(self) weakself=self;
    [self.manager POST:[NSString stringWithFormat:@"%@studyNote/API/login.php", urlPrefix] parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress)
     {
         
     }
               success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         __strong __typeof(weakself)strongSelf = weakself;
         NSString* state=[NSString stringWithFormat:@"%@",responseObject[@"state"]];
         if ([state isEqualToString:@"200"])
         {
             NSDictionary* data=responseObject[@"data"];
             userInstance.shareInstance.user_id=data[@"user_id"];
             userInstance.shareInstance.username=data[@"username"];
             userInstance.shareInstance.avatar=data[@"avatar"];
             userInstance.shareInstance.isLogin=YES;
             hud.label.text = @"登陆成功";
             hud.mode = MBProgressHUDModeText;
             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
             dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                 [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
                 [strongSelf dismissViewControllerAnimated:YES completion:nil];
             });
         }
         else
         {
             [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
             UIAlertController *c=[UIAlertController alertControllerWithTitle:@"密码或账号不正确" message:@"您输入的密码或账号不正确，请重新输入" preferredStyle:UIAlertControllerStyleAlert];
             __weak typeof(c) weakAlert = c;
             [c addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                 [weakAlert dismissViewControllerAnimated:YES completion:nil];
             }]];
             [strongSelf presentViewController:c animated:YES completion:nil];
         }
     }
               failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         NSLog(@"%@",error);
         [MBProgressHUD hideHUDForView:weakself.view animated:YES];
     }];
}

- (IBAction)exit:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
