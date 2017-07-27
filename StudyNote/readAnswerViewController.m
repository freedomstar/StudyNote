//
//  readAnswerViewController.m
//  StudyNote
//
//  Created by 辉仔 on 2017/4/19.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import "userInstance.h"
#import <AFNetworking.h>
#import <MJRefresh.h>
#import <MJExtension.h>
#import <UIImageView+WebCache.h>
#import <JMRoundedCorner/JMRoundedCorner.h>
#import "readAnswerViewController.h"
#import "Answer.h"
#import "answerComment.h"
#import "answerCommentTableViewCell.h"
#import "answerCommentViewController.h"
#import "readQuestionTableViewController.h"
#import "userPageTableViewController.h"
#import "NewAnswerViewController.h"
#import <MBProgressHUD.h>


@interface readAnswerViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *hotlabel;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property CGPoint LastOffset;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(strong,nonatomic) NSMutableArray* answerCommentModelArray;
@property (weak, nonatomic) IBOutlet UILabel *create_time;
@property (weak, nonatomic) IBOutlet UILabel *author_name;
@property (weak, nonatomic) IBOutlet UILabel *questionTitle;
@property (weak, nonatomic) IBOutlet UIImageView *author_avatar;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UILabel *content;
@property(strong,nonatomic)Answer* answer;
@property(strong,nonatomic)AFHTTPSessionManager*manager;
@property NSInteger page;
@property BOOL finshedLoad;
@end

@implementation readAnswerViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.translucent = YES;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.answer_id==NULL)
    {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    self.finshedLoad=NO;
    self.commentButton.layer.masksToBounds = YES;
    self.commentButton.layer.cornerRadius = 5;
    self.commentButton.layer.borderWidth = 1.0;
    self.commentButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.answerCommentModelArray=[[NSMutableArray alloc]init];
    self.tableView.estimatedRowHeight=300;
    self.tableView.rowHeight=UITableViewAutomaticDimension;
    self.tabBarController.tabBar.hidden=YES;
    self.manager = [AFHTTPSessionManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.page=1;
    self.tableView.mj_header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(reloadAnswerComment)];
    self.tableView.mj_footer=[MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadNoteComment)];
    [self.tableView.mj_footer beginRefreshing];
    [self loadAnswer];
}


-(void)loadAnswer
{
    NSDictionary *parameters=[[NSDictionary alloc] initWithObjectsAndKeys:userInstance.shareInstance.user_id,@"user_id",self.answer_id,@"answer_id",nil];
    __weak typeof(self) weakself=self;
    [self.manager POST:[NSString stringWithFormat:@"%@studyNote/API/getAnswers.php", urlPrefix] parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress)
     {
         
     }
               success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         __strong __typeof(weakself)strongSelf = weakself;
         NSDictionary* data=responseObject[@"data"];
         strongSelf.answer=[Answer mj_objectWithKeyValues:data];
         strongSelf.htmlString=[NSString stringWithFormat:@"%@",strongSelf.answer.content];
         strongSelf.htmlString=[strongSelf adoptImageSize:strongSelf.htmlString];
         NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[strongSelf.htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
         strongSelf.content.attributedText = attrStr;
         strongSelf.hotlabel.text=[NSString stringWithFormat:@"%@℃",strongSelf.answer.hot];
         strongSelf.questionTitle.text=strongSelf.answer.questionTitle;
         strongSelf.author_name.text=strongSelf.answer.username;
         strongSelf.create_time.text=strongSelf.answer.create_time;
         [strongSelf.author_avatar jm_setImageWithCornerRadius:strongSelf.author_avatar.frame.size.width/2 imageURL:[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@",strongSelf.answer.avatar]] placeholder:nil size:strongSelf.author_avatar.frame.size];
         if ([strongSelf.answer.isLike isEqualToString:@"0"])
         {
             [self.likeButton setBackgroundImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
         }
         else
         {
             [self.likeButton setBackgroundImage:[UIImage imageNamed:@"beLike"] forState:UIControlStateNormal];
         }
         if (![userInstance.shareInstance.user_id isEqualToString:strongSelf.answer.answerer_id])
         {
             self.navigationItem.rightBarButtonItem=nil;
         }
         self.finshedLoad=YES;
         [strongSelf.tableView.mj_header endRefreshing];
         [strongSelf.headView layoutIfNeeded];
         [strongSelf.headView setFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width,strongSelf.separatorView.frame.origin.y+strongSelf.separatorView.frame.size.height)];
         [strongSelf.tableView reloadData];
     }
               failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         
     }];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    answerComment*answer=self.answerCommentModelArray[indexPath.row];
    if ([userInstance.shareInstance.user_id isEqualToString:answer.user_id])
        return YES;
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle ==UITableViewCellEditingStyleDelete)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [hud setDimBackground:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.label.text = @"删除中";
        answerComment*answer=self.answerCommentModelArray[indexPath.row];
        NSDictionary *parameters=[[NSDictionary alloc] initWithObjectsAndKeys:answer.answer_comment_id,@"answer_comment_id",nil];
        __weak typeof(self) weakself=self;
        [self.manager POST:[NSString stringWithFormat:@"%@studyNote/API/deleteAnswerComment.php", urlPrefix] parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress)
         {
             
         }
                   success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
         {
             __strong __typeof(weakself)strongSelf = weakself;
             NSString* state=[NSString stringWithFormat:@"%@",responseObject[@"state"]];
             if ([state isEqualToString:@"200"])
             {
                 [self.answerCommentModelArray removeObjectAtIndex:indexPath.row];
                 [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                 hud.label.text = @"删除成功";
                 hud.mode = MBProgressHUDModeText;
                 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
                 dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                     [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
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
                 [MBProgressHUD hideHUDForView:weakself.view animated:YES];
             });
         }];
    }
    else if (editingStyle ==UITableViewCellEditingStyleInsert)
    {
        
    }
}



- (IBAction)editAnswer:(id)sender
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
            UINavigationController *nnvc=[main instantiateViewControllerWithIdentifier:@"newAnswerNavigationController"];
            NewAnswerViewController* o=nnvc.childViewControllers[0];
            o.answer=strongSelf.answer;
            o.ravc=strongSelf;
            [strongSelf presentViewController:nnvc animated:YES completion:nil];
        }]];
        [c addAction:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action)
                      {
                          [weakAlert dismissViewControllerAnimated:YES completion:nil];
                          UIAlertController *cc=[UIAlertController alertControllerWithTitle:@"是否删除" message:@"是否删除该答案" preferredStyle:UIAlertControllerStyleAlert];
                          __weak typeof(cc) weakAlertc = cc;
                          [cc addAction:[UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                              __strong __typeof(weakself)strongSelf = weakself;
                              MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:strongSelf.view animated:YES];
                              [hud setDimBackground:YES];
                              hud.mode = MBProgressHUDModeIndeterminate;
                              hud.label.text = @"删除中";
                              NSDictionary *parameters=[[NSDictionary alloc] initWithObjectsAndKeys:self.answer_id,@"answer_id",nil];
                              [self.manager POST:[NSString stringWithFormat:@"%@studyNote/API/deleteAnswer.php", urlPrefix] parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress)
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
    vc.user_id=self.answer.answerer_id;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)reloadAnswerComment
{
    self.page=1;
    [self.answerCommentModelArray removeAllObjects];
    [self loadNoteComment];
}

-(void)loadNoteComment
{
    NSDictionary *parameters=[[NSDictionary alloc] initWithObjectsAndKeys:userInstance.shareInstance.user_id,@"user_id",self.answer_id,@"answer_id",[NSString stringWithFormat:@"%ld",(long)self.page] ,@"page",nil];
    __weak typeof(self) weakself=self;
    [self.manager POST:[NSString stringWithFormat:@"%@studyNote/API/getAnswerComments.php", urlPrefix] parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress)
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
                 answerComment*AnswerComment=[answerComment mj_objectWithKeyValues:data[i]];
                 [strongSelf.answerCommentModelArray addObject:AnswerComment];
             }
             strongSelf.page++;
             [strongSelf.tableView reloadData];
             [strongSelf.tableView.mj_footer endRefreshing];
         }
         else
         {
             [strongSelf.tableView.mj_footer endRefreshingWithNoMoreData];
         }
         [strongSelf.tableView.mj_header endRefreshing];
     }
               failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         NSLog(@"%@",error);
     }];
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

- (IBAction)CommentNote:(id)sender
{
    if (userInstance.shareInstance.isLogin)
    {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        self.definesPresentationContext = YES;
        UIStoryboard *story = [UIStoryboard  storyboardWithName:@"Main"   bundle:nil];
        answerCommentViewController* ncvc=[story instantiateViewControllerWithIdentifier:@"answerCommentViewController"];
        ncvc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [ncvc.view setBackgroundColor:[UIColor clearColor]];
        ncvc.answer_id=self.answer_id;
        ncvc.ReadAnswerViewController=self;
        [self presentViewController:ncvc animated:YES completion:nil];
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

- (IBAction)likeAnswer:(id)sender
{
    NSString*url;
    if ([self.answer.isLike isEqualToString:@"1"])
    {
        url=@"studyNote/API/unLikeAnswers.php";
    }
    else
    {
        url=@"studyNote/API/likeAnswers.php";
    }
    NSDictionary *parameters=[[NSDictionary alloc] initWithObjectsAndKeys:userInstance.shareInstance.user_id ,@"user_id",self.answer_id,@"answer_id",nil];
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
             if ([strongSelf.answer.isLike isEqualToString:@"1"])
             {
                 strongSelf.answer.isLike=@"0";
                 [self.likeButton setBackgroundImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
             }
             else
             {
                 strongSelf.answer.isLike=@"1";
                 [self.likeButton setBackgroundImage:[UIImage imageNamed:@"beLike"] forState:UIControlStateNormal];
             }
         }
         else
         {
             
         }
     }
               failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         NSLog(@"%@",error);
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toQuestion:(id)sender
{
    UIStoryboard*main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    readQuestionTableViewController* vc=[main instantiateViewControllerWithIdentifier:@"readQuestionTableViewController"];
    vc.question_id=self.answer.question_id;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.tag==0)
    {
        CGPoint offset = scrollView.contentOffset;
        if(offset.y>0&&scrollView.contentSize.height-offset.y>1000)
        {
            if(offset.y<self.LastOffset.y)
            {
                [self.navigationController setNavigationBarHidden:NO animated:YES];
            }
            else
            {
                [self.navigationController setNavigationBarHidden:YES animated:YES];
            }
        }
        self.LastOffset=offset;
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.answerCommentModelArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    answerCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"answerCommentTableViewCell" forIndexPath:indexPath];
    if (cell==nil) {
        cell=[[answerCommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"answerCommentTableViewCell"];
    }
    answerComment*AnswerComment=self.answerCommentModelArray[indexPath.row];
    [cell.avatar jm_setImageWithCornerRadius:cell.avatar.frame.size.width/2 imageURL:[[NSURL alloc] initWithString: AnswerComment.avatar] placeholder:nil size:cell.avatar.frame.size];
    cell.avatar.tag=indexPath.row;
    __weak typeof(self) weakself=self;
    cell.callBackBlock = ^(int indexPath)
    {
        __strong __typeof(weakself)strongSelf = weakself;
        UIStoryboard*main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        userPageTableViewController* vc=[main instantiateViewControllerWithIdentifier:@"userPageTableViewController"];
        answerComment* cm=strongSelf.self.answerCommentModelArray[indexPath];
        vc.user_id=cm.user_id;
        [strongSelf.navigationController pushViewController:vc animated:YES];
    };
//    cell.callBackBlock = ^(int indexPath)
//    {
//        UIStoryboard*main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        userPageTableViewController* vc=[main instantiateViewControllerWithIdentifier:@"userPageTableViewController"];
//        answerComment* cm=self.answerCommentModelArray[indexPath];
//        vc.user_id=cm.user_id;
//        [self.navigationController pushViewController:vc animated:YES];
//    };
    cell.username.text=AnswerComment.username;
    cell.create_time.text=AnswerComment.create_time;
    cell.content.text=AnswerComment.content;
    return cell;
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
