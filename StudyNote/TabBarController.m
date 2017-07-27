//
//  TabBarController.m
//  StudyNote
//
//  Created by 辉仔 on 2017/4/22.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import "TabBarController.h"
#import "XJTabBar.h"
#import "newNoteViewController.h"
#import "userInstance.h"

@interface TabBarController ()<XJTabBarDelegate>

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    XJTabBar *tabBar = [[XJTabBar alloc] init];
    tabBar.delegate = self;
    [self setValue:tabBar forKeyPath:@"tabBar"];
    [self.tabBar setTintColor:[UIColor darkGrayColor]];
    self.tabBar.translucent=NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tabBarDidPulsBtnClick:(XJTabBar *)tabBar
{
    if (userInstance.shareInstance.isLogin)
    {
        UIStoryboard* main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *nnvc=[main instantiateViewControllerWithIdentifier:@"newNoteNavigationController"];
        [self presentViewController:nnvc animated:YES completion:nil];
    }
    else
    {
        UIAlertController *c=[UIAlertController alertControllerWithTitle:@"未登陆" message:@"请先登录" preferredStyle:UIAlertControllerStyleAlert];
        __weak typeof(c) weakAlert = c;
        [c addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [weakAlert dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:c animated:YES completion:nil];
    }
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
