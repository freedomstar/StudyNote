//
//  userListTableViewController.m
//  StudyNote
//
//  Created by 辉仔 on 2017/4/24.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import "userListTableViewController.h"
#import <AFNetworking.h>
#import <JMRoundedCorner/JMRoundedCorner.h>
#import <MJRefresh.h>
#import <MJExtension.h>
#import "userListTableViewCell.h"
#import "userListModel.h"
#import "userPageTableViewController.h"


@interface userListTableViewController ()
@property(strong,nonatomic)AFHTTPSessionManager*manager;
@property(strong,nonatomic) NSMutableArray* userListModelArray;
@property NSInteger page;
@end

@implementation userListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight=300;
    self.tableView.rowHeight=UITableViewAutomaticDimension;
    self.userListModelArray=[[NSMutableArray alloc]init];
    self.page=1;
    self.manager = [AFHTTPSessionManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.tableView.mj_footer=[MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loaduser)];
    [self.tableView.mj_footer beginRefreshing];
}

-(void)loaduser
{
    NSDictionary *parameters=[[NSDictionary alloc] initWithObjectsAndKeys:self.user_id,@"user_id",[NSString stringWithFormat:@"%ld",(long)self.page] ,@"page",nil];
    __weak typeof(self) weakself=self;
    [self.manager POST:[NSString stringWithFormat:@"%@%@", urlPrefix,self.url] parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress)
     {
         
     }
               success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         __strong __typeof(weakself)strongSelf = weakself;
         NSArray* data=responseObject[@"data"];
    
         if (data.count>0)
         {
             for (int i=0; i<data.count; i++)
             {
                 userListModel* ulm=[userListModel mj_objectWithKeyValues:data[i]];
                 [self.userListModelArray addObject:ulm];
             }
             [strongSelf.tableView reloadData];
             strongSelf.page++;
             [strongSelf.tableView.mj_footer endRefreshing];
         }
         else
         {
             [strongSelf.tableView.mj_footer endRefreshingWithNoMoreData];
         }
     }
               failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         NSLog(@"%@",error);
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
  
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.userListModelArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    userListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userListTableViewCell" forIndexPath:indexPath];
    if (cell==nil)
    {
        cell=[[userListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"userListTableViewCell"];
    }
    userListModel* ulm=self.userListModelArray[indexPath.row];
    cell.username.text=ulm.username;
    [cell.avatar jm_setImageWithCornerRadius:cell.avatar.frame.size.width/2 imageURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",ulm.avatar]] placeholder:nil size:cell.avatar.frame.size];
    return cell;
}


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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    userPageTableViewController* uptvc=[segue destinationViewController];
    userListModel* ulm=self.userListModelArray[self.tableView.indexPathForSelectedRow.row];
    uptvc.user_id=ulm.user_id;
}


@end
