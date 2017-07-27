//
//  answerAndQuestionTableViewController.m
//  StudyNote
//
//  Created by 辉仔 on 2017/4/9.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import "userInstance.h"
#import "answerAndQuestionTableViewController.h"
#import "answerAndQuestionTableViewCell.h"
#import <AFNetworking.h>
#import <MJRefresh.h>
#import <MJExtension.h>
#import <UIImageView+WebCache.h>
#import <JMRoundedCorner/JMRoundedCorner.h>
#import "answerAndQuestionModel.h"
#import "readAnswerViewController.h"
#import "userPageTableViewController.h"

@interface answerAndQuestionTableViewController ()
@property(strong,nonatomic) NSMutableArray*answerAndQuestionModelArray;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *askQuestionButton;
@property(strong,nonatomic)AFHTTPSessionManager*manager;
@property NSInteger page;
@end

@implementation answerAndQuestionTableViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.translucent = NO;
    self.tabBarController.tabBar.hidden=NO;
    [self RefreshData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight=300;
    self.tableView.rowHeight=UITableViewAutomaticDimension;
    self.searchButton.layer.masksToBounds = YES;
    self.searchButton.layer.cornerRadius = self.searchButton.frame.size.height/2;
    self.askQuestionButton.layer.borderWidth = 1.0;
    self.askQuestionButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.askQuestionButton.layer.masksToBounds = YES;
    self.askQuestionButton.layer.cornerRadius = 5;
    self.askQuestionButton.layer.borderWidth = 2.0;
    self.askQuestionButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.manager = [AFHTTPSessionManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.page=1;
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self  refreshingAction:@selector(loadNewData)];
//    [self.tableView.mj_footer beginRefreshing];
    self.tableView.mj_header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(RefreshData)];
//    [self.tableView.mj_header beginRefreshing];
    self.answerAndQuestionModelArray=[[NSMutableArray alloc]init];
}


-(void)RefreshData
{
    self.tableView.userInteractionEnabled=NO;
    [self.tableView.mj_footer endRefreshingWithNoMoreData];
    self.page=1;
    [self.answerAndQuestionModelArray removeAllObjects];
    NSDictionary *parameters=[[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)self.page] ,@"page", nil];
    __weak typeof(self) weakself=self;
    [self.manager POST:[NSString stringWithFormat:@"%@studyNote/API/getTopAnswer.php", urlPrefix] parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         __strong __typeof(weakself)strongSelf = weakself;
         NSArray* response=(NSArray*)responseObject[@"data"];
         if (response.count>0)
         {
             for (int i=0; i<response.count; i++)
             {
                 answerAndQuestionModel* AnswerAndQuestionModel=[answerAndQuestionModel mj_objectWithKeyValues:response[i]];
                 [strongSelf.answerAndQuestionModelArray addObject:AnswerAndQuestionModel];
             }
             strongSelf.page++;
             [strongSelf.tableView reloadData];
         }
         [strongSelf.tableView.mj_header endRefreshing];
         [strongSelf.tableView.mj_footer resetNoMoreData];
         [strongSelf.tableView reloadData];
           self.tableView.userInteractionEnabled=YES;
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         NSLog(@"%@",error);
         [weakself.tableView.mj_header endRefreshing];
         self.tableView.userInteractionEnabled=YES;
     }];
}


-(void)loadNewData
{
    [self.tableView.mj_header endRefreshing];
    NSDictionary *parameters=[[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)self.page] ,@"page", nil];
    __weak typeof(self) weakself=self;
    [self.manager POST:[NSString stringWithFormat:@"%@studyNote/API/getTopAnswer.php", urlPrefix] parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         __strong __typeof(weakself)strongSelf = weakself;
         NSArray* response=(NSArray*)responseObject[@"data"];
         if (response.count>0)
         {
             for (int i=0; i<response.count; i++)
             {
                 answerAndQuestionModel* AnswerAndQuestionModel=[answerAndQuestionModel mj_objectWithKeyValues:response[i]];
                 [strongSelf.answerAndQuestionModelArray addObject:AnswerAndQuestionModel];
             }
             strongSelf.page++;
             [strongSelf.tableView reloadData];
             [strongSelf.tableView.mj_footer endRefreshing];
         }
         else
         {
             [strongSelf.tableView.mj_footer endRefreshingWithNoMoreData];
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         NSLog(@"%@",error);
         [weakself.tableView.mj_footer endRefreshing];
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return self.answerAndQuestionModelArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    answerAndQuestionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"answerAndQuestionCell" forIndexPath:indexPath];
    if (cell==nil) {
        cell=[[answerAndQuestionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"answerAndQuestionCell"];
    }
    answerAndQuestionModel* AnswerAndQuestionModel=self.answerAndQuestionModelArray[indexPath.row];
    [cell.avatar jm_setImageWithCornerRadius:cell.avatar.frame.size.width/2 imageURL:[[NSURL alloc] initWithString: AnswerAndQuestionModel.avatar] placeholder:nil size:cell.avatar.frame.size];
    if (![AnswerAndQuestionModel.cover isEqual:@""])
    {
        cell.coverH.constant=120;
        [cell.cover sd_setImageWithURL:[[NSURL alloc] initWithString: AnswerAndQuestionModel.cover]];
    }
    else
    {
        cell.cover.image=nil;
        cell.coverH.constant=0;
    }
    cell.avatar.tag=indexPath.row;
    cell.callBackBlock = ^(int indexPath)
    {
        UIStoryboard*main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        userPageTableViewController* vc=[main instantiateViewControllerWithIdentifier:@"userPageTableViewController"];
        answerAndQuestionModel* cm=self.answerAndQuestionModelArray[indexPath];
        vc.user_id=cm.answerer_id;
        [self.navigationController pushViewController:vc animated:YES];
    };
    cell.username.text=AnswerAndQuestionModel.username;
    cell.questionTitle.text=AnswerAndQuestionModel.questionTitle;
    cell.introduction.text=AnswerAndQuestionModel.introduction;
    cell.likeCount.text=AnswerAndQuestionModel.likeCount;
    cell.commentCount.text=AnswerAndQuestionModel.commentCount;
    
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

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"toNewQuestion"])
    {
        if (!userInstance.shareInstance.isLogin)
        {
            UIAlertController *c=[UIAlertController alertControllerWithTitle:@"未登陆" message:@"请先登录" preferredStyle:UIAlertControllerStyleAlert];
            __weak typeof(c) weakAlert = c;
            [c addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [weakAlert dismissViewControllerAnimated:YES completion:nil];
            }]];
            [self presentViewController:c animated:YES completion:nil];
            return NO;
        }
    }
    return YES;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toReadAnswer"])
    {
       answerAndQuestionModel* aaqm = self.answerAndQuestionModelArray[self.tableView.indexPathForSelectedRow.row];
        readAnswerViewController* ravc=segue.destinationViewController;
        ravc.answer_id=aaqm.answer_id;
    }
}


@end
