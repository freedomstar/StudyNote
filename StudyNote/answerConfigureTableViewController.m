//
//  answerConfigureTableViewController.m
//  StudyNote
//
//  Created by 辉仔 on 2017/4/26.
//  Copyright © 2017年 freestar. All rights reserved.
//
#import "userInstance.h"
#import "answerConfigureTableViewController.h"
#import <AFNetworking.h>
#import <UIImageView+WebCache.h>
#import <MBProgressHUD.h>

@interface answerConfigureTableViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *cover;
@property (weak, nonatomic) IBOutlet UITextView *introduction;
@property(strong,nonatomic)AFHTTPSessionManager*manager;
@end

@implementation answerConfigureTableViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.introduction.layer.borderWidth=1;
    self.introduction.layer.borderColor=[[UIColor grayColor] CGColor];
    self.introduction.layer.masksToBounds=YES;
    self.manager = [AFHTTPSessionManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    if (![self.parameters[@"cover"] isEqualToString:@""])
    {
        [self.cover sd_setImageWithURL:self.parameters[@"cover"]];
    }
    self.introduction.text=self.parameters[@"introduction"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)uploadCover:(id)sender
{
    [self callActionSheetFunc];
}

- (void)callActionSheetFunc{
    UIAlertController *c=[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakself = self;
    __weak typeof(c) weakAlert = c;
    [c addAction:[UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                  {
                      [weakself callUIImagePickerControllerAtIndex:1];
                      [weakAlert dismissViewControllerAnimated:YES completion:nil];
                  }]];
    
    [c addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                  {
                      [weakself callUIImagePickerControllerAtIndex:0];
                      [weakAlert dismissViewControllerAnimated:YES completion:nil];
                  }]];
    
    [c addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action)
                  {
                      [weakAlert dismissViewControllerAnimated:YES completion:nil];
                  }]];
    [self presentViewController:c animated:YES completion:nil];
}


- (void)callUIImagePickerControllerAtIndex:(NSInteger)buttonIndex{
    NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    switch (buttonIndex) {
        case 0:
            //来源:相机
            sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
        case 1:
            //来源:相册
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        case 2:
            return;
    }
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = sourceType;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setDimBackground:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = @"上传中";
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    __weak typeof(self) weakself=self;
    NSDictionary *dics=[[NSDictionary alloc] initWithObjectsAndKeys:userInstance.shareInstance.user_id,@"user_id", nil];
    [self.manager POST:[NSString stringWithFormat:@"%@studyNote/API/uploadPhoto.php",urlPrefix]  parameters:dics constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData*jpgData = UIImageJPEGRepresentation(image, 0.8);
        [formData appendPartWithFileData:jpgData name: @"file" fileName: @"image.jpg" mimeType: @"image/jpeg" ];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        weakself.parameters[@"cover"]=[NSString stringWithFormat:@"%@",responseObject[@"url"]];
        [weakself.cover sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",responseObject[@"url"]]]];
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




- (IBAction)published:(id)sender
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setDimBackground:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = @"发布中";
    __weak typeof(self) weakself=self;
    self.parameters[@"introduction"]=self.introduction.text;
    [self.manager POST:[NSString stringWithFormat:@"%@%@", urlPrefix,self.url] parameters:self.parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         __strong __typeof(weakself)strongSelf = weakself;
         NSString* state=[NSString stringWithFormat:@"%@",responseObject[@"state"]];
         if ([state isEqualToString:@"200"])
         {
             [strongSelf.ravc loadAnswer];
             hud.label.text = @"发布成功";
             hud.mode = MBProgressHUDModeText;
             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
             dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                 [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
                 [strongSelf.parentViewController dismissViewControllerAnimated:YES completion:^{
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 2;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
