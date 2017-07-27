//
//  newQuestionViewController.m
//  StudyNote
//
//  Created by 辉仔 on 2017/4/26.
//  Copyright © 2017年 freestar. All rights reserved.
//
#import "userInstance.h"
#import "newQuestionViewController.h"
#import <AFNetworking.h>
#import "ZSSDemoPickerViewController.h"
#import "DemoModalViewController.h"
#import <MBProgressHUD.h>
#import "questionConfigureTableViewController.h"

@interface newQuestionViewController ()

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property(strong,nonatomic) NSString*cover;
@property(strong,nonatomic)AFHTTPSessionManager*manager;
@end

@implementation newQuestionViewController


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden=YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.manager = [AFHTTPSessionManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [self.editorView.scrollView setAlwaysBounceHorizontal:YES];
    self.cover=@"";
    if (self.QuestionModel!=NULL)
    {
        self.titleTextField.text=self.QuestionModel.title;
        NSString*html=self.QuestionModel.content;
        [self setHTML:html];
    }
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    [hud setDimBackground:YES];
    hud.label.text = @"上传中";
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    //    CGSize targetSize = CGSizeMake(image.size.width * self.selectedImageScale, image.size.height * self.selectedImageScale);
    //    CGSize targetSize = CGSizeMake(320,320);
    //    UIGraphicsBeginImageContext(targetSize);
    //    [image drawInRect:CGRectMake(0,0,targetSize.width,targetSize.height)];
    //    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    //    UIGraphicsEndImageContext();
    float w=image.size.width;
    float h=image.size.height;
    
    __weak typeof(self) weakself=self;
    NSDictionary *dics=[[NSDictionary alloc] initWithObjectsAndKeys:userInstance.shareInstance.user_id,@"user_id", nil];
    [self.manager POST:[NSString stringWithFormat:@"%@studyNote/API/uploadPhoto.php",urlPrefix]  parameters:dics constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData*jpgData = UIImageJPEGRepresentation(image, 0.8);
        [formData appendPartWithFileData:jpgData name: @"file" fileName: @"image.jpg" mimeType: @"image/jpeg" ];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //    [weakself insertImage:[NSString stringWithFormat:@"%@",responseObject[@"url"]] alt:@"ff"];
        [weakself insertImagebylocal:[NSString stringWithFormat:@"%@",responseObject[@"url"]] alt:@"ff" w:w h:h];
        if ([weakself.cover isEqualToString:@""])
        {
            weakself.cover=[NSString stringWithFormat:@"%@",responseObject[@"url"]];
        }
        [hud hideAnimated:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        hud.label.text = @"上传失败";
        hud.mode = MBProgressHUDModeText;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    }];
}

//- (void)showInsertURLAlternatePicker {
//
//    [self dismissAlertView];
//
//    ZSSDemoPickerViewController *picker = [[ZSSDemoPickerViewController alloc] init];
//    picker.demoView = self;
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:picker];
//    nav.navigationBar.translucent = NO;
//    [self presentViewController:nav animated:YES completion:nil];
//
//}


//- (void)showInsertImageAlternatePicker {
//
//    [self dismissAlertView];
//
//    ZSSDemoPickerViewController *picker = [[ZSSDemoPickerViewController alloc] init];
//    picker.demoView = self;
//    picker.isInsertImagePicker = YES;
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:picker];
//    nav.navigationBar.translucent = NO;
//    [self presentViewController:nav animated:YES completion:nil];
//
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(NSString *)getIntroduction:(NSString *)string
{
    NSRegularExpression *regularExpretion=[NSRegularExpression regularExpressionWithPattern:@" <img[^>]+src\\s*=\\s*['\"]([^'\"]+)['\"][^>]*>"
                                                                                    options:0
                                                                                      error:nil];
    string=[regularExpretion stringByReplacingMatchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, string.length) withTemplate:@"[图片]"];
    
    regularExpretion=[NSRegularExpression regularExpressionWithPattern:@"<[^>]*>|\n"
                                                               options:0
                                                                 error:nil];
    string=[regularExpretion stringByReplacingMatchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, string.length) withTemplate:@""];
    string=[string stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (string.length>101)
    {
        string=[string substringWithRange:NSMakeRange(0, 100)];
    }
    return string;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    questionConfigureTableViewController* nctvc=[segue destinationViewController];
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc]init];
    if (self.QuestionModel==NULL)
    {
        parameters[@"content"]=[self getHTML];
        parameters[@"user_id"]=userInstance.shareInstance.user_id;
        parameters[@"title"]=self.titleTextField.text;
        parameters[@"introduction"]=[self getIntroduction:[self getHTML]];
        parameters[@"education_id"]=@"1";
        parameters[@"cover"]=[NSString stringWithFormat:@"%@",self.cover];
        nctvc.url=@"studyNote/API/addQuestion.php";
    }
    else
    {
        parameters[@"content"]=[self getHTML];
        parameters[@"question_id"]=self.QuestionModel.question_id;
        parameters[@"title"]=self.titleTextField.text;
        parameters[@"introduction"]=[self getIntroduction:[self getHTML]];
        parameters[@"education_id"]=self.QuestionModel.education_id;
        parameters[@"cover"]=self.QuestionModel.cover;
        nctvc.url=@"studyNote/API/updateQuestions.php";
    }
    nctvc.rqtvc=self.rqtvc;
    nctvc.parameters=parameters;
}


@end