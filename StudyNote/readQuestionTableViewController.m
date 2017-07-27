//
//  readQuestionTableViewController.m
//  StudyNote
//
//  Created by 辉仔 on 2017/4/17.
//  Copyright © 2017年 freestar. All rights reserved.
//


#import "AnswerTableViewCell.h"
#import "AnswerModel.h"
#import "readQuestionTableViewController.h"
#import <AFNetworking.h>
#import <MJRefresh.h>
#import <MJExtension.h>
#import <UIImageView+WebCache.h>
#import <JMRoundedCorner/JMRoundedCorner.h>
#import "questionModel.h"
#import "NewAnswerViewController.h"
#import "userPageTableViewController.h"
#import "readAnswerViewController.h"
#import "userInstance.h"
#import "newQuestionViewController.h"
#import <MBProgressHUD.h>

@interface readQuestionTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *questionTitle;
@property (weak, nonatomic) IBOutlet UIView *headView;
@property(strong,nonatomic) NSMutableArray*answerModelArray;
@property (weak, nonatomic) IBOutlet UIButton *changeHeadSizeButton;
@property (weak, nonatomic) IBOutlet UILabel *content;
@property(strong,nonatomic)AFHTTPSessionManager*manager;
@property(strong,nonatomic)questionModel*QuestionModel;
@property NSInteger page;
@property BOOL isAnswer;
@property BOOL finshedLoad;
@end

@implementation readQuestionTableViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self.answerModelArray removeAllObjects];
    self.page=1;
    [self.tableView.mj_footer endEditing:NO];
    [self.tableView.mj_footer beginRefreshing];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.question_id==NULL)
    {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    self.isAnswer=NO;
    self.answerModelArray=[[NSMutableArray alloc]init];
    self.finshedLoad=NO;
    self.tableView.estimatedRowHeight=600;
    self.tableView.rowHeight=UITableViewAutomaticDimension;
    self.manager = [AFHTTPSessionManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [self loadQuestion];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self  refreshingAction:@selector(loadNewData)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)loadQuestion
{
    NSDictionary *parameters=[[NSDictionary alloc] initWithObjectsAndKeys:self.question_id,@"question_id",nil];
    __weak typeof(self) weakself=self;
    [self.manager POST:[NSString stringWithFormat:@"%@studyNote/API/getQuestion.php", urlPrefix] parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         __strong __typeof(weakself)strongSelf = weakself;
         NSDictionary* response=(NSDictionary*)responseObject[@"data"];
         strongSelf.QuestionModel=[questionModel mj_objectWithKeyValues:response];
         strongSelf.htmlString=[NSString stringWithFormat:@"%@",strongSelf.QuestionModel.content];
         strongSelf.htmlString=[strongSelf adoptImageSize:strongSelf.htmlString];
         NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[strongSelf.htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
         strongSelf.content.attributedText = attrStr;
         [strongSelf.content sizeToFit];
         if (strongSelf.content.frame.size.height<=40)
         {
             strongSelf.changeHeadSizeButton.hidden=YES;
         }
         strongSelf.questionTitle.text=strongSelf.QuestionModel.title;
         [strongSelf.avatar jm_setImageWithCornerRadius:strongSelf.avatar.frame.size.width/2 imageURL:[[NSURL alloc] initWithString:strongSelf.QuestionModel.avatar] placeholder:nil size:strongSelf.avatar.frame.size];
         strongSelf.username.text=strongSelf.QuestionModel.username;
         if (![userInstance.shareInstance.user_id isEqualToString:strongSelf.QuestionModel.creator_id])
         {
             self.navigationItem.rightBarButtonItem=nil;
         }
         self.finshedLoad=YES;
         [strongSelf.headView layoutIfNeeded];
         [strongSelf.tableView reloadData];
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         NSLog(@"%@",error);
         [weakself.tableView.mj_footer endRefreshing];
     }];
}

- (IBAction)editQuestion:(id)sender
{
    if (self.finshedLoad)
    {
        UIAlertController *c=[[UIAlertController alloc]init];
        __weak typeof(c) weakAlert = c;
        __weak typeof(self) weakself=self;
        [c addAction:[UIAlertAction actionWithTitle:@"修改" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [weakAlert dismissViewControllerAnimated:YES completion:nil];
            __strong __typeof(weakself)strongSelf = weakself;
            UIStoryboard* main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *nnvc=[main instantiateViewControllerWithIdentifier:@"newQuestionNavigationController"];
            newQuestionViewController* o=nnvc.childViewControllers[0];
            o.QuestionModel=strongSelf.QuestionModel;
            o.rqtvc=strongSelf;
            [strongSelf presentViewController:nnvc animated:YES completion:nil];
        }]];
        
        [c addAction:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action)
                      {
                          [weakAlert dismissViewControllerAnimated:YES completion:nil];
                          UIAlertController *cc=[UIAlertController alertControllerWithTitle:@"是否删除" message:@"是否删除该问题" preferredStyle:UIAlertControllerStyleAlert];
                          __weak typeof(cc) weakAlertc = cc;
                          [cc addAction:[UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                              __strong __typeof(weakself)strongSelf = weakself;
                              MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:strongSelf.view animated:YES];
                              [hud setDimBackground:YES];
                              hud.mode = MBProgressHUDModeIndeterminate;
                              hud.label.text = @"删除中";
                              NSDictionary *parameters=[[NSDictionary alloc] initWithObjectsAndKeys:self.question_id,@"question_id",nil];
                              [self.manager POST:[NSString stringWithFormat:@"%@studyNote/API/deleteQuestions.php", urlPrefix] parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress)
                               {
                                   
                               }
                                         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
                               {
                                   NSString* state=[NSString stringWithFormat:@"%@",responseObject[@"state"]];
                                   if ([state isEqualToString:@"200"])
                                   {
                                       hud.label.text = @"删除成功";
                                       hud.mode = MBProgressHUDModeText;
                                       dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
                                       dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                           [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
                                           [strongSelf.navigationController popViewControllerAnimated:YES];
                                       });
                                   }
                                   else
                                   {
                                       hud.label.text = @"删除失败";
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
                                   hud.label.text = @"服务器原因，删除失败";
                                   hud.mode = MBProgressHUDModeText;
                                   dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
                                   dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                       [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
                                   });
                                   [weakAlertc dismissViewControllerAnimated:YES completion:nil];
                               }];
                          }]];
                          
                          [cc addAction:[UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                              [weakAlertc dismissViewControllerAnimated:YES completion:nil];
                          }]];
                          [weakself presentViewController:cc animated:YES completion:nil];
                      }]];
        
        
        if ([self.QuestionModel.state isEqualToString:@"1"])
        {
            [c addAction:[UIAlertAction actionWithTitle:@"关闭问题" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action)
                          {
                              [weakAlert dismissViewControllerAnimated:YES completion:nil];
                              UIAlertController *cc=[UIAlertController alertControllerWithTitle:@"是否关闭问题" message:@"一旦问题被关闭后，将无法恢复,是否关闭该问题?" preferredStyle:UIAlertControllerStyleAlert];
                              __weak typeof(cc) weakAlertc = cc;
                              [cc addAction:[UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                  __strong __typeof(weakself)strongSelf = weakself;
                                  MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:strongSelf.view animated:YES];
                                  [hud setDimBackground:YES];
                                  hud.mode = MBProgressHUDModeIndeterminate;
                                  hud.label.text = @"关闭中";
                                  NSDictionary *parameters=[[NSDictionary alloc] initWithObjectsAndKeys:self.question_id,@"question_id",nil];
                                  [self.manager POST:[NSString stringWithFormat:@"%@studyNote/API/closeQuestions.php", urlPrefix] parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress)
                                   {
                                       
                                   }
                                             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
                                   {
                                       NSString* state=[NSString stringWithFormat:@"%@",responseObject[@"state"]];
                                       if ([state isEqualToString:@"200"])
                                       {
                                           hud.label.text = @"关闭成功";
                                           hud.mode = MBProgressHUDModeText;
                                           dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
                                           dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                               [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
                                               [strongSelf.navigationController popViewControllerAnimated:YES];
                                           });
                                       }
                                       else
                                       {
                                           hud.label.text = @"关闭失败";
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
                                       hud.label.text = @"服务器原因，关闭失败";
                                       hud.mode = MBProgressHUDModeText;
                                       dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
                                       dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                           [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
                                       });
                                       [weakAlertc dismissViewControllerAnimated:YES completion:nil];
                                   }];
                              }]];
                              
                              [cc addAction:[UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                  [weakAlertc dismissViewControllerAnimated:YES completion:nil];
                              }]];
                              [weakself presentViewController:cc animated:YES completion:nil];
                          }]];
        }
        
        [c addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [weakAlert dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:c animated:YES completion:nil];
    }
}

- (IBAction)toAuthorPage:(id)sender
{
    UIStoryboard*main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    userPageTableViewController* vc=[main instantiateViewControllerWithIdentifier:@"userPageTableViewController"];
    vc.user_id=self.QuestionModel.creator_id;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)loadNewData
{
    self.tableView.userInteractionEnabled=NO;
    NSDictionary *parameters=[[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)self.page] ,@"page", self.question_id,@"question_id",nil];
    __weak typeof(self) weakself=self;
    [self.manager POST:[NSString stringWithFormat:@"%@studyNote/API/getAnswersByQuestionID.php", urlPrefix] parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         __strong __typeof(weakself)strongSelf = weakself;
         NSArray* response=(NSArray*)responseObject[@"data"];
         if (response.count>0)
         {
             for (int i=0; i<response.count; i++)
             {
                 AnswerModel* answerModel=[AnswerModel mj_objectWithKeyValues:response[i]];
                 if ([answerModel.answerer_id isEqualToString:userInstance.shareInstance.user_id])
                 {
                     strongSelf.isAnswer=YES;
                 }
                 [strongSelf.answerModelArray addObject:answerModel];
             }
             strongSelf.page++;
             [strongSelf.tableView.mj_footer endRefreshing];
         }
         else
         {
             [strongSelf.tableView.mj_footer endRefreshingWithNoMoreData];
         }
         [strongSelf.tableView reloadData];
         self.tableView.userInteractionEnabled=YES;
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         NSLog(@"%@",error);
         [weakself.tableView.mj_footer endRefreshing];
         self.tableView.userInteractionEnabled=YES;
     }];
}

- (IBAction)changeHeadViewSize:(id)sender
{
    if (self.headView.frame.size.height>150)
    {
         [self.headView setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 150)];
        [self.changeHeadSizeButton setTitle:@"展开全部" forState:UIControlStateNormal];
    }
    else
    {
        [self.headView setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 90+self.content.frame.size.height)];
         [self.changeHeadSizeButton setTitle:@"收起" forState:UIControlStateNormal];
    }
    
    [self.tableView reloadData];
}


-(NSString*)adoptImageSize:(NSString*)htmlStr
{
    NSRange star=NSMakeRange(htmlStr.length, 2);
    NSRange mid;
    NSRange end;
    while (1)
    {
        star = [htmlStr rangeOfString:@"data-width=\"" options:NSBackwardsSearch range:NSMakeRange(0,star.location)];
        if (star.length==0)
            break;
        mid= [htmlStr rangeOfString:@"\" data-height=\"" options:NSCaseInsensitiveSearch range:NSMakeRange(star.location, htmlStr.length-star.location)];
        end=[htmlStr rangeOfString:@"\">" options:NSCaseInsensitiveSearch range:NSMakeRange(mid.location, htmlStr.length-mid.location)];
        float dataH=[[htmlStr substringWithRange:NSMakeRange(mid.location+mid.length, end.location-mid.location-mid.length)] floatValue];
        float dataW=[[htmlStr substringWithRange:NSMakeRange(star.location+star.length, mid.location-star.location-star.length)] floatValue];
        if (dataW>([UIScreen mainScreen].bounds.size.width-20))
        {
            float W=[UIScreen mainScreen].bounds.size.width-20;
            float H=dataH/dataW*W;
            htmlStr=[htmlStr stringByReplacingCharactersInRange:NSMakeRange(mid.location+mid.length, end.location-mid.location-mid.length) withString:[NSString stringWithFormat:@"%f",H]];
            htmlStr=[htmlStr stringByReplacingCharactersInRange:NSMakeRange(star.location+star.length, mid.location-star.location-star.length) withString:[NSString stringWithFormat:@"%f",W]];
        }
    }
    htmlStr=[htmlStr stringByReplacingOccurrencesOfString:@"data-width" withString:@"width"];
    htmlStr=[htmlStr stringByReplacingOccurrencesOfString:@"data-height" withString:@"height"];
    return htmlStr;
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.answerModelArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AnswerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AnswerCell" forIndexPath:indexPath];
    if (cell==nil) {
        cell=[[AnswerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AnswerCell"];
    }
    AnswerModel* answerModel=self.answerModelArray[indexPath.row];
    [cell.avatar jm_setImageWithCornerRadius:cell.avatar.frame.size.width/2 imageURL:[[NSURL alloc] initWithString: answerModel.avatar] placeholder:nil size:cell.avatar.frame.size];
    if (![answerModel.cover isEqual:@""])
    {
        cell.coverHeight.constant=120;
        [cell.cover sd_setImageWithURL:[[NSURL alloc] initWithString: answerModel.cover]];
    }
    else
    {
        cell.cover.image=nil;
        cell.coverHeight.constant=0;
    }
    cell.avatar.tag=indexPath.row;
//    cell.callBackBlock = ^(int indexPath)
//    {
//        UIStoryboard*main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        userPageTableViewController* vc=[main instantiateViewControllerWithIdentifier:@"userPageTableViewController"];
//        AnswerModel* cm=self.answerModelArray[indexPath];
//        vc.user_id=cm.answerer_id;
//        [self.navigationController pushViewController:vc animated:YES];
//    };
    __weak typeof(self) weakself=self;
    cell.callBackBlock = ^(int indexPath)
    {
        __strong __typeof(weakself)strongSelf = weakself;
        UIStoryboard*main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        userPageTableViewController* vc=[main instantiateViewControllerWithIdentifier:@"userPageTableViewController"];
        AnswerModel* cm=strongSelf.answerModelArray[indexPath];
        vc.user_id=cm.answerer_id;
        [strongSelf.navigationController pushViewController:vc animated:YES];
    };
    cell.username.text=answerModel.username;
    cell.introduction.text=answerModel.introduction;
    cell.likeCount.text=answerModel.likeCount;
    cell.commentCount.text=answerModel.commentCount;
    [cell.introduction sizeToFit];
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


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"toNewAnswer"])
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
        if ([self.QuestionModel.state isEqualToString:@"0"])
        {
            UIAlertController *c=[UIAlertController alertControllerWithTitle:@"问题已关闭" message:@"该问题已关闭，无法进行回答。" preferredStyle:UIAlertControllerStyleAlert];
            __weak typeof(c) weakAlert = c;
            [c addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [weakAlert dismissViewControllerAnimated:YES completion:nil];
            }]];
            [self presentViewController:c animated:YES completion:nil];
            return NO;
        }
        if([userInstance.shareInstance.user_id isEqualToString:self.QuestionModel.creator_id])
        {
            UIAlertController *c=[UIAlertController alertControllerWithTitle:@"不能回答自己的问题" message:@"您不能回答自己所提出的问题。" preferredStyle:UIAlertControllerStyleAlert];
            __weak typeof(c) weakAlert = c;
            [c addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [weakAlert dismissViewControllerAnimated:YES completion:nil];
            }]];
            [self presentViewController:c animated:YES completion:nil];
            return NO;
        }
        if (self.isAnswer)
        {
            UIAlertController *c=[UIAlertController alertControllerWithTitle:@"不能重复答问题" message:@"您不能重复回答同一个问题。" preferredStyle:UIAlertControllerStyleAlert];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toNewAnswer"])
    {
        UINavigationController*nvc=segue.destinationViewController;
        NewAnswerViewController* vc=nvc.viewControllers[0];
        vc.question_id=[NSString stringWithFormat:@"%@",self.question_id];
    }
    if ([segue.identifier isEqualToString:@"toReadAnswer"])
    {
        AnswerModel* aaqm = self.answerModelArray[self.tableView.indexPathForSelectedRow.row];
        readAnswerViewController* ravc=segue.destinationViewController;
        ravc.answer_id=aaqm.answer_id;
    }
}


@end
