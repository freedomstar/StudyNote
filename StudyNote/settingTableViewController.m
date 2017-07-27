//
//  settingTableViewController.m
//  StudyNote
//
//  Created by 辉仔 on 2017/5/19.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import "settingTableViewController.h"
#import "userInstance.h"
#import <YYWebImage/UIButton+YYWebImage.h>
#import <YYCache.h>
#import <UIImageView+WebCache.h>
#import <MBProgressHUD.h>


@interface settingTableViewController ()
@property (weak, nonatomic) IBOutlet UIButton *unLoginButton;
@property (weak, nonatomic) IBOutlet UILabel *cacheSizeLabel;
@end

@implementation settingTableViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.translucent = YES;
    [self.tabBarController.tabBar setHidden:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.unLoginButton.layer.cornerRadius=self.unLoginButton.frame.size.height/2;
    self.unLoginButton.layer.masksToBounds=YES;
    [self countCacheSize];
}

- (void)countCacheSize
{
    float tmpSize = [[SDImageCache sharedImageCache] getSize]/1000.0/1000.0+[YYWebImageManager sharedManager].cache.diskCache.totalCost/1000.0/1000.0;
    NSString* CacheSizeString = tmpSize >= 1 ? [NSString stringWithFormat:@"%.1fM",tmpSize] : [NSString stringWithFormat:@"%.1fK",tmpSize * 1000];
    self.cacheSizeLabel.text=CacheSizeString;
    [self isLogin];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)isLogin
{
    if(userInstance.shareInstance.isLogin)
    {
        self.tableView.tableFooterView.hidden=NO;
    }
    else
    {
        self.tableView.tableFooterView.hidden=YES;
    }
    [self.tableView reloadData];
}

- (IBAction)cancelLogin:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"是否退出当前帐号" message:nil preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakself=self;
    [alertController addAction:[UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action){}]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                {
                                    __strong __typeof(weakself)strongSelf = weakself;
                                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:strongSelf.view animated:YES];
                                    [hud setDimBackground:YES];
                                    hud.mode = MBProgressHUDModeText;
                                    hud.label.text = @"已退出账号";
                                    userInstance.shareInstance.user_id=@"-5";
                                    userInstance.shareInstance.isLogin=NO;
                                    [weakself isLogin];
                                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
                                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                        [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
                                    });
                                }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Table view data deleage
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    switch (indexPath.row) {
        case 0:
            if (1) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"清除缓存" message:[NSString stringWithFormat:@"当前缓存为%@，是清除？",self.cacheSizeLabel.text] preferredStyle:UIAlertControllerStyleAlert];
                __weak typeof(self) weakself=self;
                [alertController addAction:[UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action){}]];
                
                [alertController addAction:[UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                            {
                                                [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
                                                [[YYWebImageManager sharedManager].cache.diskCache removeAllObjects];
                                                [weakself countCacheSize];
                                            }]];
                [self presentViewController:alertController animated:YES completion:nil];
            }
            break;
            
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
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
