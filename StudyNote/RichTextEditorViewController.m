//
//  RichTextEditorViewController.m
//  StudyNote
//
//  Created by 辉仔 on 2017/4/5.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import "userInstance.h"
#import "RichTextEditorViewController.h"
#import <AFNetworking.h>
#import "ZSSDemoPickerViewController.h"
#import "DemoModalViewController.h"

@interface RichTextEditorViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property(strong,nonatomic)AFHTTPSessionManager*manager;
@end

@implementation RichTextEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.manager = [AFHTTPSessionManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [self.editorView.scrollView setAlwaysBounceHorizontal:YES];
//    NSString*html=@"";
//    [self setHTML:html];
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
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
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
}

- (void)showInsertURLAlternatePicker {
    
    [self dismissAlertView];
    
    ZSSDemoPickerViewController *picker = [[ZSSDemoPickerViewController alloc] init];
    picker.demoView = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:picker];
    nav.navigationBar.translucent = NO;
    [self presentViewController:nav animated:YES completion:nil];
    
}


- (void)showInsertImageAlternatePicker {
    
    [self dismissAlertView];
    
    ZSSDemoPickerViewController *picker = [[ZSSDemoPickerViewController alloc] init];
    picker.demoView = self;
    picker.isInsertImagePicker = YES;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:picker];
    nav.navigationBar.translucent = NO;
    [self presentViewController:nav animated:YES completion:nil];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismiss:(id)sender
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
