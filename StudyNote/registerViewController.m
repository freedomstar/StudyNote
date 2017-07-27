//
//  registerViewController.m
//  StudyNote
//
//  Created by 辉仔 on 2017/5/7.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import "registerViewController.h"
#import <MBProgressHUD.h>
#import <AFNetworking.h>

@interface registerViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *H;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property(strong,nonatomic)AFHTTPSessionManager*manager;
@end

@implementation registerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.manager = [AFHTTPSessionManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.registerButton.layer.cornerRadius=self.registerButton.frame.size.height/2;
    self.registerButton.layer.masksToBounds=YES;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(upViews:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(downViews:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}


-(void)upViews:(NSNotification *) notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int keyBoardHeight = keyboardRect.size.height;
    if (self.H.constant==0)
    {
        __weak typeof(self) weakself=self;
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:0.3
                         animations:^{
                             __strong __typeof(weakself)strongSelf = weakself;
                             strongSelf.H.constant=strongSelf.H.constant-keyBoardHeight+200;
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
                         strongSelf.H.constant=0;
                         [strongSelf.view layoutIfNeeded];
                     }];
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


- (IBAction)register:(id)sender
{
    [self.view endEditing:YES];
    if([self isValidateEmail:self.email.text])
    {
        UIAlertController *c=[UIAlertController alertControllerWithTitle:@"邮箱格式不正确" message:@"请输入正确的邮箱地址" preferredStyle:UIAlertControllerStyleAlert];
        __weak typeof(c) weakAlert = c;
        [c addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [weakAlert dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:c animated:YES completion:nil];
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setDimBackground:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = @"注册中";
    NSDictionary *parameters=[[NSDictionary alloc] initWithObjectsAndKeys:self.email.text,@"email",self.password.text ,@"password",@"普通用户",@"username",@"1",@"education_id",nil];
    __weak typeof(self) weakself=self;
    [self.manager POST:[NSString stringWithFormat:@"%@studyNote/API/register.php", urlPrefix] parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress)
     {
         
     }
               success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         __strong __typeof(weakself)strongSelf = weakself;
         NSString* state=[NSString stringWithFormat:@"%@",responseObject[@"state"]];
         if ([state isEqualToString:@"200"])
         {
             NSDictionary* data=responseObject[@"data"];
             hud.label.text = @"注册成功";
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
             UIAlertController *c=[UIAlertController alertControllerWithTitle:@"注册失败" message:@"你的邮箱已被注册" preferredStyle:UIAlertControllerStyleAlert];
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

- (IBAction)eixt:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)isValidateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
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
