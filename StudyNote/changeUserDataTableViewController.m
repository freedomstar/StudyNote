//
//  changeUserDataTableViewController.m
//  StudyNote
//
//  Created by 辉仔 on 2017/5/16.
//  Copyright © 2017年 freestar. All rights reserved.
//
#import "userInstance.h"
#import "changeUserDataTableViewController.h"
#import <AFNetworking.h>
#import <UIImageView+WebCache.h>
#import <MBProgressHUD.h>

@interface changeUserDataTableViewController ()<UIPickerViewDataSource,UIPickerViewDelegate,UIScrollViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UITextField *school;
@property (weak, nonatomic) IBOutlet UITextField *sex;
@property (weak, nonatomic) IBOutlet UITextView *introduction;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UITextField *education;
@property(strong,nonatomic)AFHTTPSessionManager*manager;
@property(strong,nonatomic)NSString*avatarUrl;
@property (strong, nonatomic) NSArray *educations;
@property (strong, nonatomic) NSArray *sexs;
@end

@implementation changeUserDataTableViewController


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.translucent = YES;
    [self.tabBarController.tabBar setHidden:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.introduction.layer.borderWidth=1;
    self.introduction.layer.borderColor=[[UIColor grayColor] CGColor];
    self.introduction.layer.masksToBounds=YES;
    self.avatarUrl=userInstance.shareInstance.avatar;
    self.manager = [AFHTTPSessionManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.sexs=[NSArray arrayWithObjects:@"无",@"男",@"女", nil];
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"deployList" ofType:@"plist"];
    NSDictionary*data = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    self.educations=data[@"education"];
    self.education.text=@"无";
     UIPickerView* pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 50, [UIScreen mainScreen].bounds.size.width, 250)];
    pickerView.delegate=self;
    pickerView.dataSource=self;
    [pickerView setShowsSelectionIndicator:YES];
    [self.education setInputView:pickerView];
    UIPickerView* pickerView1 = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 50, [UIScreen mainScreen].bounds.size.width, 250)];
    pickerView1.tag=1;
    pickerView1.delegate=self;
    pickerView1.dataSource=self;
    [pickerView1 setShowsSelectionIndicator:YES];
    [self.sex setInputView:pickerView1];
    [self getUser];
}

- (IBAction)uploadAvatar:(id)sender
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
    CGSize targetSize=CGSizeMake(120, image.size.height/image.size.width*120);
    UIGraphicsBeginImageContext(targetSize);
    [image drawInRect:CGRectMake(0,0,targetSize.width,targetSize.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
   
    __weak typeof(self) weakself=self;
    NSDictionary *dics=[[NSDictionary alloc] initWithObjectsAndKeys:userInstance.shareInstance.user_id,@"user_id", nil];
    [self.manager POST:[NSString stringWithFormat:@"%@studyNote/API/uploadPhoto.php",urlPrefix]  parameters:dics constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData*jpgData = UIImageJPEGRepresentation(scaledImage, 0.5);
        [formData appendPartWithFileData:jpgData name: @"file" fileName: @"image.jpg" mimeType: @"image/jpeg" ];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        self.avatarUrl=[NSString stringWithFormat:@"%@",responseObject[@"url"]];
        [weakself.avatar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",responseObject[@"url"]]]];
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



-(void)getUser
{
    NSDictionary *parameters=[[NSDictionary alloc] initWithObjectsAndKeys:userInstance.shareInstance.user_id,@"loginUser",userInstance.shareInstance.user_id,@"user_id",nil];
    __weak typeof(self) weakself=self;
    [self.manager POST:[NSString stringWithFormat:@"%@studyNote/API/getUser.php", urlPrefix] parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress)
     {
         
     }
               success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         __strong __typeof(weakself)strongSelf = weakself;
         NSDictionary* data=responseObject[@"data"];
         [strongSelf.avatar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",data[@"avatar"]]]];
          strongSelf.introduction.text=[NSString stringWithFormat:@"%@",data[@"introduction"]];
         strongSelf.school.text=[NSString stringWithFormat:@"%@",data[@"fansCount"]];
         strongSelf.username.text=[NSString stringWithFormat:@"%@",data[@"username"]];
         if(![[NSString stringWithFormat:@"%@",data[@"introduction"]] isEqualToString:@"<null>"])
             strongSelf.introduction.text=[NSString stringWithFormat:@"%@",data[@"introduction"]];
         if(![[NSString stringWithFormat:@"%@",data[@"sex"]] isEqualToString:@"<null>"])
         {
             strongSelf.sex.text=[NSString stringWithFormat:@"%@",data[@"sex"]];
         }
         else
         {
              strongSelf.sex.text=@"无";
         }
         strongSelf.username.text=[NSString stringWithFormat:@"%@",data[@"username"]];
         int education_id=[[NSString stringWithFormat:@"%@",data[@"education_id"]] intValue];
//         if (education_id==1)
//             education_id-=1;
         strongSelf.education.text=strongSelf.educations[education_id-1];
     }
               failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveAct:(id)sender
{
//    education_id=
    NSDictionary *parameters=[[NSDictionary alloc] initWithObjectsAndKeys:self.school.text,@"school",userInstance.shareInstance.user_id,@"user_id",self.sex.text,@"sex",[NSString stringWithFormat:@"%lu",(unsigned long)[self.educations indexOfObject:self.education.text]+1],@"education_id",self.avatarUrl,@"avatar",self.introduction.text,@"introduction",self.username.text,@"username",nil];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setDimBackground:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = @"修改中";
       __weak typeof(self) weakself=self;
    [self.manager POST:[NSString stringWithFormat:@"%@studyNote/API/updateUser.php", urlPrefix] parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress)
     {
         
     }
               success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         __strong __typeof(weakself)strongSelf = weakself;
         NSString* state=[NSString stringWithFormat:@"%@",responseObject[@"state"]];
         if ([state isEqualToString:@"200"])
         {
             userInstance.shareInstance.username=strongSelf.username.text;
             userInstance.shareInstance.avatar=self.avatarUrl;
             hud.label.text = @"修改成功";
             hud.mode = MBProgressHUDModeText;
             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
             dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                 [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
                 [strongSelf dismissViewControllerAnimated:YES completion:^{
                 }];
             });
         }
         else
         {
             hud.label.text = @"修改失败";
             hud.mode = MBProgressHUDModeText;
             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
             dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                 [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
             });
         }
     }
               failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         NSLog(@"%@",error);
         hud.label.text = @"修改失败";
         hud.mode = MBProgressHUDModeText;
         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
             [MBProgressHUD hideHUDForView: weakself.view animated:YES];
         });
     }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
        [self.view endEditing:YES];
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag==1)
        return self.sexs.count;
    return self.educations.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag==1)
        return self.sexs[row];
    return self.educations[row];
}


#pragma mark - UIPickerViewDelegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView.tag==1)
    {
        self.sex.text=self.sexs[row];
    }
    else
    {
        self.education.text=self.educations[row];
        //    self.parameters[@"education_id"]=[NSString stringWithFormat:@"%d",row];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
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
