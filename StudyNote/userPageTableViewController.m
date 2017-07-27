//
//  userPageTableViewController.m
//  StudyNote
//
//  Created by 辉仔 on 2017/4/24.
//  Copyright © 2017年 freestar. All rights reserved.
//
#import "userPageNoteTableViewCell.h"
#import "userPageTableViewController.h"
#import <AFNetworking.h>
#import <JMRoundedCorner/JMRoundedCorner.h>
#import <UIImageView+WebCache.h>
#import <MJRefresh.h>
#import <MJExtension.h>
#import "userPageNoteModel.h"
#import "userListTableViewController.h"
#import "allListTableViewController.h"
#import "ReadNotePageTableViewController.h"
#import "userInstance.h"

@interface userPageTableViewController ()
@property (weak, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet UILabel *lastLable;
@property(strong,nonatomic) NSMutableArray* userPageNoteModelArray;
@property (weak, nonatomic) IBOutlet UIButton *careButton;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UIImageView *sex;
@property (weak, nonatomic) IBOutlet UILabel *introduction;
@property (weak, nonatomic) IBOutlet UILabel *noteCount;
@property (weak, nonatomic) IBOutlet UILabel *questionCount;
@property (weak, nonatomic) IBOutlet UILabel *answerCount;
@property (weak, nonatomic) IBOutlet UILabel *fansCount;
@property (weak, nonatomic) IBOutlet UILabel *careUsersCount;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property(strong,nonatomic)AFHTTPSessionManager*manager;
@property NSInteger page;
@end

@implementation userPageTableViewController


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.translucent = YES;
    [self.tabBarController.tabBar setHidden:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.careButton.layer.cornerRadius=self.careButton.frame.size.height/2;
    self.careButton.layer.masksToBounds=YES;
    self.tableView.estimatedRowHeight=300;
    self.tableView.rowHeight=UITableViewAutomaticDimension;
    self.userPageNoteModelArray=[[NSMutableArray alloc]init];
    self.manager = [AFHTTPSessionManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.page=1;
    self.tableView.mj_footer=[MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadNote)];
    [self.tableView.mj_footer beginRefreshing];
    [self getUser];
    if ([self.user_id isEqualToString:userInstance.shareInstance.user_id])
    {
        self.careButton.hidden=YES;
    }
}

-(void)getUser
{
    NSDictionary *parameters=[[NSDictionary alloc] initWithObjectsAndKeys:userInstance.shareInstance.user_id,@"loginUser",self.user_id ,@"user_id",nil];
    __weak typeof(self) weakself=self;
    [self.manager POST:[NSString stringWithFormat:@"%@studyNote/API/getUser.php", urlPrefix] parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress)
    {
        
    }
               success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         __strong __typeof(weakself)strongSelf = weakself;
          NSDictionary* data=responseObject[@"data"];
         [strongSelf.avatar jm_setImageWithCornerRadius:strongSelf.avatar.frame.size.width/2 imageURL:[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@",data[@"avatar"]]] placeholder:nil size:strongSelf.avatar.frame.size];
         strongSelf.noteCount.text=[NSString stringWithFormat:@"%@",data[@"noteCount"]];
         strongSelf.questionCount.text=[NSString stringWithFormat:@"%@",data[@"questionCount"]];
         strongSelf.answerCount.text=[NSString stringWithFormat:@"%@",data[@"answerCount"]];
         strongSelf.careUsersCount.text=[NSString stringWithFormat:@"%@",data[@"careUsersCount"]];
         strongSelf.fansCount.text=[NSString stringWithFormat:@"%@",data[@"fansCount"]];
         strongSelf.username.text=[NSString stringWithFormat:@"%@",data[@"username"]];
         if([[NSString stringWithFormat:@"%@",data[@"introduction"]] isEqualToString:@"<null>"])
         {
             strongSelf.introduction.text=@"该用户未填写任何简介";
         }
         else
         {
              strongSelf.introduction.text=[NSString stringWithFormat:@"%@",data[@"introduction"]];
         }
         if ([[NSString stringWithFormat:@"%@",data[@"sex"]] isEqualToString:@"男"])
         {
             [self.sex setImage:[UIImage imageNamed:@"man"]];
         }
         else if([[NSString stringWithFormat:@"%@",data[@"sex"]] isEqualToString:@"女"])
         {
             [self.sex setImage:[UIImage imageNamed:@"woman"]];
         }
         else
         {
              [self.sex setImage:[UIImage imageNamed:@"sex"]];
         }
         
         if ([[NSString stringWithFormat:@"%@",data[@"isCare"]] isEqualToString:@"0"])
         {
             [strongSelf.careButton setBackgroundColor:[UIColor redColor]];
             [strongSelf.careButton setTitle:@"关注" forState:UIControlStateNormal];
         }
         else
         {
             [strongSelf.careButton setBackgroundColor:[UIColor lightGrayColor]];
             [strongSelf.careButton setTitle:@"已关注" forState:UIControlStateNormal];
         }
         [strongSelf.view layoutIfNeeded];
         [strongSelf.headView setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, strongSelf.lastLable.frame.origin.y+strongSelf.lastLable.frame.size.height)];
    }
               failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
        
    }];
}

-(void)loadNote
{
    NSDictionary *parameters=[[NSDictionary alloc] initWithObjectsAndKeys:self.user_id,@"user_id",[NSString stringWithFormat:@"%ld",(long)self.page] ,@"page",nil];
    __weak typeof(self) weakself=self;
    [self.manager POST:[NSString stringWithFormat:@"%@studyNote/API/getNotesByOtherUserID.php", urlPrefix] parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress)
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
                 userPageNoteModel* upnm=[userPageNoteModel mj_objectWithKeyValues:data[i]];
                 [self.userPageNoteModelArray addObject:upnm];
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


- (IBAction)careAct:(id)sender
{
    if (!userInstance.shareInstance.isLogin)
    {
        UIAlertController *c=[UIAlertController alertControllerWithTitle:@"未登陆" message:@"请先登录" preferredStyle:UIAlertControllerStyleAlert];
        __weak typeof(c) weakAlert = c;
        [c addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [weakAlert dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:c animated:YES completion:nil];
    }
    else
    {
        NSString* url;
        if ([self.careButton.titleLabel.text isEqualToString:@"关注"])
        {
            url=@"studyNote/API/careUser.php";
        }
        else
        {
            url=@"studyNote/API/cancelCareUser.php";
        }
        NSDictionary *parameters=[[NSDictionary alloc] initWithObjectsAndKeys:self.user_id,@"user_be_cared",userInstance.shareInstance.user_id,@"user_care",nil];
        __weak typeof(self) weakself=self;
        [self.manager POST:[NSString stringWithFormat:@"%@%@", urlPrefix,url] parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress)
         {
             
         }
                   success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
         {
             __strong __typeof(weakself)strongSelf = weakself;
             NSString* state=[NSString stringWithFormat:@"%@",responseObject[@"state"]];
             if ([state isEqualToString:@"200"])
             {
                 if ([self.careButton.titleLabel.text isEqualToString:@"关注"])
                 {
                     [strongSelf.careButton setBackgroundColor:[UIColor lightGrayColor]];
                     [strongSelf.careButton setTitle:@"已关注" forState:UIControlStateNormal];
                 }
                 else
                 {
                     [strongSelf.careButton setBackgroundColor:[UIColor redColor]];
                     [strongSelf.careButton setTitle:@"关注" forState:UIControlStateNormal];
                 }
                 
             }
         }
                   failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
         {
             NSLog(@"%@",error);
         }];
    }
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
    
    return self.userPageNoteModelArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    userPageNoteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userPageNoteCell" forIndexPath:indexPath];
    if (cell==nil)
    {
        cell=[[userPageNoteTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"userPageNoteCell"];
    }
    userPageNoteModel* upnm=self.userPageNoteModelArray[indexPath.row];
    cell.introduction.text=upnm.introduction;
    cell.title.text=upnm.title;
    if (![upnm.cover isEqual:@""])
    {
        cell.coverHeight.constant=120;
        [cell.cover sd_setImageWithURL:[[NSURL alloc] initWithString: upnm.cover]];
    }
    else
    {
        cell.cover.image=nil;
        cell.coverHeight.constant=0;
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UIStoryboard*main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ReadNotePageTableViewController* vc=[main instantiateViewControllerWithIdentifier:@"ReadNotePageTableViewController"];
    userPageNoteModel* m=self.userPageNoteModelArray[indexPath.row];
    vc.note_id=m.note_id;
    [self.navigationController pushViewController:vc animated:YES];
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
    if ([segue.identifier isEqualToString:@"toFans"])
    {
        userListTableViewController*  ultvc=segue.destinationViewController;
        ultvc.user_id=self.user_id;
        ultvc.url=@"studyNote/API/getUserFans.php";
    }
    if ([segue.identifier isEqualToString:@"toUserCare"])
    {
        userListTableViewController*  ultvc=segue.destinationViewController;
        ultvc.user_id=self.user_id;
        ultvc.url=@"studyNote/API/getCareUser.php";
    }
    if ([segue.identifier isEqualToString:@"toNote"])
    {
        allListTableViewController*  ultvc=segue.destinationViewController;
        ultvc.user_id=self.user_id;
        ultvc.classify=@"Note";
        ultvc.url=@"studyNote/API/getNotesByOtherUserID.php";
    }
    if ([segue.identifier isEqualToString:@"toQuestion"])
    {
        allListTableViewController*  ultvc=segue.destinationViewController;
        ultvc.user_id=self.user_id;
        ultvc.classify=@"Question";
        ultvc.url=@"studyNote/API/getQuestionByUserID.php";
    }
    if ([segue.identifier isEqualToString:@"toAnswer"])
    {
        allListTableViewController*  ultvc=segue.destinationViewController;
        ultvc.user_id=self.user_id;
        ultvc.classify=@"Answer";
        ultvc.url=@"studyNote/API/getAnswersByUserID.php";
    }
}


@end
