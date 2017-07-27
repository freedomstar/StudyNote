//
//  allListTableViewController.m
//  StudyNote
//
//  Created by 辉仔 on 2017/4/25.
//  Copyright © 2017年 freestar. All rights reserved.
//
#import "ReadNotePageTableViewController.h"
#import "allListTableViewController.h"
#import "readAnswerViewController.h"
#import "allListModel.h"
#import "allListTableViewCell.h"
#import "readQuestionTableViewController.h"
#import <AFNetworking.h>
#import <UIImageView+WebCache.h>
#import <MJRefresh.h>
#import <MJExtension.h>

@interface allListTableViewController ()
@property(strong,nonatomic)AFHTTPSessionManager*manager;
@property(strong,nonatomic) NSMutableArray* allListModelArray;
@property NSInteger page;
@end

@implementation allListTableViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.translucent = YES;
    [self.tabBarController.tabBar setHidden:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight=300;
    self.tableView.rowHeight=UITableViewAutomaticDimension;
    self.allListModelArray=[[NSMutableArray alloc]init];
    self.page=1;
    self.manager = [AFHTTPSessionManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.tableView.mj_footer=[MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadNoteComment)];
    [self.tableView.mj_footer beginRefreshing];
}

-(void)loadNoteComment
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
                 allListModel* alm=[allListModel mj_objectWithKeyValues:data[i]];
                 [self.allListModelArray addObject:alm];
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

#pragma mark - Tableview deleage
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UIStoryboard*main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    allListModel* m=self.allListModelArray[indexPath.row];
    if ([self.classify isEqualToString:@"Note"])
    {
        ReadNotePageTableViewController* vc=[main instantiateViewControllerWithIdentifier:@"ReadNotePageTableViewController"];
        vc.note_id=m.note_id;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([self.classify isEqualToString:@"Question"])
    {
        readQuestionTableViewController* vc=[main instantiateViewControllerWithIdentifier:@"readQuestionTableViewController"];
        vc.question_id=m.question_id;
         [self.navigationController pushViewController:vc animated:YES];
    }
    
    else if ([self.classify isEqualToString:@"Answer"])
    {
        readAnswerViewController* vc=[main instantiateViewControllerWithIdentifier:@"readAnswerViewController"];
        vc.answer_id=m.answer_id;
        [self.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.allListModelArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    allListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"allListTableViewCell" forIndexPath:indexPath];
    if (cell==nil)
    {
        cell=[[allListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"allListTableViewCell"];
    }
    allListModel* ulm=self.allListModelArray[indexPath.row];
    cell.title.text=ulm.title;
    
    if ([ulm.cover isEqualToString:@""])
    {
        cell.coverW.constant=0;
        cell.coverH.constant=0;
        cell.cover.image=nil;
    }
    else
    {
        cell.coverH.constant=90;
        cell.coverW.constant=90;
        [cell.cover sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",ulm.cover]]];
    }
    cell.introduction.text=ulm.introduction;
    
    if ([self.url isEqualToString:@"studyNote/API/getQuestionByUserID.php"])
    {
        if ([ulm.state isEqualToString:@"1"])
        {
            cell.publicTag.hidden=NO;
            cell.publicTag.text=@"未关闭";
        }else if ([ulm.state isEqualToString:@"0"])
        {
            cell.publicTag.hidden=NO;
            cell.publicTag.text=@"已关闭";
        }
    }
    else if (![self.url isEqualToString:@"studyNote/API/getCollectionNote.php"])
    {
        if ([ulm.public isEqualToString:@"1"])
        {
            cell.publicTag.hidden=NO;
            cell.publicTag.text=@"公开";
        }else if ([ulm.public isEqualToString:@"0"])
        {
            cell.publicTag.hidden=NO;
            cell.publicTag.text=@"私密";
        }
        else
        {
            cell.publicTag.hidden=YES;
        }
    }
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
