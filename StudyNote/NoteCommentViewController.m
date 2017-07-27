//
//  NoteCommentViewController.m
//  StudyNote
//
//  Created by 辉仔 on 2017/4/11.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import "NoteCommentViewController.h"
#import "userInstance.h"
#import <AFNetworking.h>
#import <MBProgressHUD.h>

@interface NoteCommentViewController ()
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewBottomH;
@property (weak, nonatomic) IBOutlet UITextView *TextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewH;
@property(strong,nonatomic)AFHTTPSessionManager*manager;
@end

@implementation NoteCommentViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.TextView becomeFirstResponder];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.manager = [AFHTTPSessionManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.TextView.layer.masksToBounds = YES;
    self.TextView.layer.cornerRadius = 5;
    self.TextView.layer.borderWidth = 2.0;
    self.TextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.sendButton.layer.masksToBounds = YES;
    self.sendButton.layer.cornerRadius = self.sendButton.frame.size.height/2;
}

- (IBAction)sendComment:(id)sender
{
    NSString *str = [self.TextView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (![str isEqualToString:@""] && self.TextView.text.length<100)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [hud setDimBackground:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.label.text = @"发布中";
        NSDictionary *parameters=[[NSDictionary alloc] initWithObjectsAndKeys:userInstance.shareInstance.user_id,@"user_id",self.note_id,@"note_id",self.TextView.text,@"content",nil];
            __weak typeof(self) weakself=self;
        [self.manager POST:[NSString stringWithFormat:@"%@studyNote/API/addNoteComment.php", urlPrefix] parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            __strong __typeof(weakself)strongSelf = weakself;
            [strongSelf.view endEditing:YES];
            NSString* state=[NSString stringWithFormat:@"%@",responseObject[@"state"]];
            if ([state isEqualToString:@"200"])
            {
                hud.label.text = @"发布成功";
                hud.mode = MBProgressHUDModeText;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
                    [strongSelf dismissViewControllerAnimated:YES completion:^{
                        [strongSelf.readNotePageTableViewController reloadNoteComment];
                    }];
                });
            }
            else
            {
                hud.label.text = @"发布失败";
                hud.mode = MBProgressHUDModeText;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
                });
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@",error);
            hud.label.text = @"发布失败";
            hud.mode = MBProgressHUDModeText;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [MBProgressHUD hideHUDForView:weakself.view animated:YES];
            });
        }];
    }
    else
    {
        UIAlertController *c=[UIAlertController alertControllerWithTitle:@"输入的评论无效" message:@"输入的评论过长（100字上限）或格式不正确" preferredStyle:UIAlertControllerStyleAlert];
        __weak typeof(c) weakAlert = c;
        [c addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [weakAlert dismissViewControllerAnimated:YES completion:^{
                
            }];
        }]];
        [self presentViewController:c animated:YES completion:^{
            
        }];
    }
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.viewBottomH.constant=kbSize.height;
}


- (IBAction)Exit:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
