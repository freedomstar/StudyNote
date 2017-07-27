//
//  meTableViewController.m
//  StudyNote
//
//  Created by 辉仔 on 2017/5/5.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import "meTableViewController.h"
#import "userInstance.h"
#import "loginViewController.h"
#import <UIImageView+WebCache.h>
#import "userPageTableViewController.h"
#import "allListTableViewController.h"

@interface meTableViewController ()<UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *changeUserButton;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *introduction;
@end

@implementation meTableViewController


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.translucent = NO;
    [self.tabBarController.tabBar setHidden:NO];
    if (userInstance.shareInstance.isLogin)
    {
        [self.changeUserButton setHidden:NO];
        self.username.text=userInstance.shareInstance.username;
        [self.avatar sd_setImageWithURL:[NSURL URLWithString:userInstance.shareInstance.avatar]];
    }
    else
    {
        [self.changeUserButton setHidden:YES];
        self.username.text=@"请登陆";
        [self.avatar setImage:[UIImage imageNamed:@"cat-3"]];
        [self.tableView reloadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.avatar.layer.cornerRadius=self.avatar.frame.size.width/2;
    self.avatar.layer.borderWidth=1;
    self.avatar.layer.borderColor=[[UIColor lightGrayColor] CGColor];
    self.avatar.layer.masksToBounds=YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard* main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    switch (indexPath.section) {
        case 0:
            if (userInstance.shareInstance.isLogin)
            {
                userPageTableViewController* uptvc=[main instantiateViewControllerWithIdentifier:@"userPageTableViewController"];
                uptvc.user_id=userInstance.shareInstance.user_id;
                [self.navigationController pushViewController:uptvc animated:YES];
            }
            else
            {
                loginViewController* lvc=[main instantiateViewControllerWithIdentifier:@"login"];
                [self presentViewController:lvc animated:YES completion:nil];
            }
            break;
        case 1:
            if(userInstance.shareInstance.isLogin)
            {
                switch (indexPath.row) {
                    case 0:
                        if (true)
                        {
                            allListTableViewController* ultvc=[main instantiateViewControllerWithIdentifier:@"allListTableViewController"];
                            ultvc.user_id=userInstance.shareInstance.user_id;
                            ultvc.classify=@"Note";
                            ultvc.url=@"studyNote/API/getNotesByUserID.php";
                            [self.navigationController pushViewController:ultvc animated:YES];
                        }
                        break;
                        
                    case 1:
                        if (true)
                        {
                            allListTableViewController* ultvc=[main instantiateViewControllerWithIdentifier:@"allListTableViewController"];
                            ultvc.user_id=userInstance.shareInstance.user_id;
                            ultvc.classify=@"Answer";
                            ultvc.url=@"studyNote/API/getAnswersByUserID.php";
                            [self.navigationController pushViewController:ultvc animated:YES];
                        }
                        
                        break;
                        
                    case 2:
                        if (true)
                        {
                            allListTableViewController* ultvc=[main instantiateViewControllerWithIdentifier:@"allListTableViewController"];
                            ultvc.user_id=userInstance.shareInstance.user_id;
                            ultvc.classify=@"Question";
                            ultvc.url=@"studyNote/API/getQuestionByUserID.php";
                            [self.navigationController pushViewController:ultvc animated:YES];
                        }
                        break;
                        
                    case 3:
                        if (true)
                        {
                            allListTableViewController* ultvc=[main instantiateViewControllerWithIdentifier:@"allListTableViewController"];
                            ultvc.user_id=userInstance.shareInstance.user_id;
                            ultvc.classify=@"Note";
                            ultvc.url=@"studyNote/API/getCollectionNote.php";
                            [self.navigationController pushViewController:ultvc animated:YES];
                        }
                        break;
                        
                    default:
                        break;
                }
            }
            else
            {
                UIAlertController *c=[UIAlertController alertControllerWithTitle:@"未登陆" message:@"请先登录" preferredStyle:UIAlertControllerStyleAlert];
                __weak typeof(c) weakAlert = c;
                [c addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                    [weakAlert dismissViewControllerAnimated:YES completion:^{
                        
                    }];
                }]];
                [self presentViewController:c animated:YES completion:nil];
            }
            break;
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
            
        case 1:
            return 4;
            break;
            
        case 2:
            return 1;
            break;
            
        default:
            return 0;
            break;
    }
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
