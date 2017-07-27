//
//  ReadNotePageTableViewController.m
//  StudyNote
//
//  Created by 辉仔 on 2017/4/10.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import "ReadNotePageTableViewController.h"
#import <AFNetworking.h>
#import <MJRefresh.h>
#import <MJExtension.h>
#import <UIImageView+WebCache.h>
#import <JMRoundedCorner/JMRoundedCorner.h>
#import <MBProgressHUD.h>
#import "userInstance.h"
#import "noteCommentTableViewCell.h"
#import "note.h"
#import "NoteCommentViewController.h"
#import "NoteComment.h"
#import "userPageTableViewController.h"
#import "newNoteViewController.h"
#import <MBProgressHUD.h>

@interface ReadNotePageTableViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *hotLabel;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property CGPoint LastOffset;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(strong,nonatomic) NSMutableArray* NoteCommentModelArray;
@property (weak, nonatomic) IBOutlet UILabel *create_time;
@property (weak, nonatomic) IBOutlet UILabel *author_name;
@property (weak, nonatomic) IBOutlet UILabel *noteTitle;
@property (weak, nonatomic) IBOutlet UIImageView *author_avatar;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UIButton *collectionButton;
@property (weak, nonatomic) IBOutlet UILabel *content;
@property (weak, nonatomic) IBOutlet UILabel *category;
@property(strong,nonatomic)note* Note;
@property(nonatomic,strong) NSMutableArray*TopCategoryModelArray;
@property(strong,nonatomic)AFHTTPSessionManager*manager;
@property NSInteger page;
@property BOOL finshedLoad;
@end

@implementation ReadNotePageTableViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.translucent = YES;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.tabBarController.tabBar.hidden=YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.note_id==NULL)
    {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    self.finshedLoad=NO;
    self.commentButton.layer.masksToBounds = YES;
    self.commentButton.layer.cornerRadius = 5;
    self.commentButton.layer.borderWidth = 1.0;
    self.commentButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.NoteCommentModelArray=[[NSMutableArray alloc]init];
    self.tableView.estimatedRowHeight=300;
    self.tableView.rowHeight=UITableViewAutomaticDimension;
    self.manager = [AFHTTPSessionManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.page=1;
    self.tableView.mj_header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(reloadNoteComment)];
    self.tableView.mj_footer=[MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadNoteComment)];
    [self.tableView.mj_footer beginRefreshing];
    [self loadNote];
}



-(void)loadNote
{
    __weak typeof(self) weakself=self;
    [self.manager POST:[NSString stringWithFormat:@"%@studyNote/API/getNoteByID.php", urlPrefix] parameters:[[NSDictionary alloc] initWithObjectsAndKeys:userInstance.shareInstance.user_id,@"user_id",self.note_id,@"note_id",nil] progress:^(NSProgress * _Nonnull uploadProgress)
     {
         
     }
               success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         __strong __typeof(weakself)strongSelf = weakself;
         NSDictionary* data=responseObject[@"data"];
         strongSelf.Note=[note mj_objectWithKeyValues:data];
         strongSelf.htmlString=[NSString stringWithFormat:@"%@",strongSelf.Note.content];
         strongSelf.htmlString=[strongSelf adoptImageSize:strongSelf.htmlString];
         NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[strongSelf.htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
         strongSelf.content.attributedText = attrStr;
         strongSelf.hotLabel.text=[NSString stringWithFormat:@"%@℃",strongSelf.Note.hot];
         strongSelf.noteTitle.text=strongSelf.Note.title;
         strongSelf.author_name.text=strongSelf.Note.author_name;
         strongSelf.create_time.text=strongSelf.Note.create_time;
         strongSelf.category.text=[NSString stringWithFormat:@"标签:%@",strongSelf.Note.category];
         [strongSelf.author_avatar jm_setImageWithCornerRadius:strongSelf.author_avatar.frame.size.width/2 imageURL:[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@",strongSelf.Note.author_avatar]] placeholder:nil size:strongSelf.author_avatar.frame.size];
         if ([strongSelf.Note.isLike isEqualToString:@"0"])
         {
              [self.likeButton setBackgroundImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
         }
         else
         {
               [self.likeButton setBackgroundImage:[UIImage imageNamed:@"beLike"] forState:UIControlStateNormal];
         }
         if ([strongSelf.Note.isCollection isEqualToString:@"0"])
         {
             [self.collectionButton setBackgroundImage:[UIImage imageNamed:@"Collection-icon"] forState:UIControlStateNormal];
         }
         else
         {
             [self.collectionButton setBackgroundImage:[UIImage imageNamed:@"beCollection-icon"] forState:UIControlStateNormal];
         }
         if (![userInstance.shareInstance.user_id isEqualToString:strongSelf.Note.author_id])
         {
             self.navigationItem.rightBarButtonItem=nil;
         }
         self.finshedLoad=YES;
         [strongSelf.headView layoutIfNeeded];
         [strongSelf.headView setFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width,strongSelf.separatorView.frame.origin.y+strongSelf.separatorView.frame.size.height)];
         [strongSelf.tableView reloadData];
     }
               failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         
     }];
}

-(void)reloadNoteComment
{
    self.page=1;
    [self.NoteCommentModelArray removeAllObjects];
    [self loadNoteComment];
}

-(void)loadNoteComment
{
    NSDictionary *parameters=[[NSDictionary alloc] initWithObjectsAndKeys:userInstance.shareInstance.user_id,@"user_id",self.note_id,@"note_id",[NSString stringWithFormat:@"%ld",(long)self.page] ,@"page",nil];
    __weak typeof(self) weakself=self;
    [self.manager POST:[NSString stringWithFormat:@"%@studyNote/API/getNoteComments.php", urlPrefix] parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress)
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
                 NoteComment*noteComment=[NoteComment mj_objectWithKeyValues:data[i]];
                 [strongSelf.NoteCommentModelArray addObject:noteComment];
             }
             strongSelf.page++;
             [strongSelf.tableView reloadData];
             [strongSelf.tableView.mj_footer endRefreshing];
             [strongSelf.tableView.mj_header endRefreshing];
         }
         else
         {
             [strongSelf.tableView.mj_footer endRefreshingWithNoMoreData];
             [strongSelf.tableView.mj_header endRefreshing];
         }
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
        NoteCommentViewController* ncvc=[story instantiateViewControllerWithIdentifier:@"NoteCommentViewController"];
        ncvc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [ncvc.view setBackgroundColor:[UIColor clearColor]];
        ncvc.note_id=self.note_id;
        ncvc.readNotePageTableViewController=self;
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


- (IBAction)toAuthorPage:(id)sender
{
    UIStoryboard*main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    userPageTableViewController* vc=[main instantiateViewControllerWithIdentifier:@"userPageTableViewController"];
    vc.user_id=self.Note.author_id;
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NoteComment*noteComment=self.NoteCommentModelArray[indexPath.row];
    if ([userInstance.shareInstance.user_id isEqualToString:noteComment.user_id])
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
        NoteComment*noteComment=self.NoteCommentModelArray[indexPath.row];
        NSDictionary *parameters=[[NSDictionary alloc] initWithObjectsAndKeys:noteComment.note_comment_id,@"note_comment_id",nil];
        __weak typeof(self) weakself=self;
        [self.manager POST:[NSString stringWithFormat:@"%@studyNote/API/deleteNoteComment.php", urlPrefix] parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress)
         {
             
         }
                   success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
         {
             __strong __typeof(weakself)strongSelf = weakself;
             NSString* state=[NSString stringWithFormat:@"%@",responseObject[@"state"]];
             if ([state isEqualToString:@"200"])
             {
                 [self.NoteCommentModelArray removeObjectAtIndex:indexPath.row];
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




- (IBAction)editNote:(id)sender
{
    if (self.finshedLoad)
    {
        UIAlertController *c=[[UIAlertController alloc]init];
        __weak typeof(c) weakAlert = c;
        __weak typeof(self) weakself=self;
        [c addAction:[UIAlertAction actionWithTitle:@"修改" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [weakAlert dismissViewControllerAnimated:YES completion:nil];
            __strong __typeof(weakself)strongSelf = weakself;
            UIStoryboard* main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *nnvc=[main instantiateViewControllerWithIdentifier:@"newNoteNavigationController"];
            newNoteViewController* o=nnvc.childViewControllers[0];
            o.Note=strongSelf.Note;
            o.rnptvc=strongSelf;
            [strongSelf presentViewController:nnvc animated:YES completion:nil];
        }]];
        
        [c addAction:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action)
                      {
                          [weakAlert dismissViewControllerAnimated:YES completion:nil];
                          UIAlertController *cc=[UIAlertController alertControllerWithTitle:@"是否删除" message:@"是否删除该文章" preferredStyle:UIAlertControllerStyleAlert];
                          __weak typeof(cc) weakAlertc = cc;
                          [cc addAction:[UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                              __strong __typeof(weakself)strongSelf = weakself;
                              MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:strongSelf.view animated:YES];
                              [hud setDimBackground:YES];
                              hud.mode = MBProgressHUDModeIndeterminate;
                              hud.label.text = @"删除中";
                              NSDictionary *parameters=[[NSDictionary alloc] initWithObjectsAndKeys:self.note_id,@"note_id",nil];
                              [self.manager POST:[NSString stringWithFormat:@"%@studyNote/API/deleteNote.php", urlPrefix] parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress)
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
        
        
        [c addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [weakAlert dismissViewControllerAnimated:YES completion:nil];
        }]];
        
        [self presentViewController:c animated:YES completion:nil];
    }
}

- (IBAction)likeNoteAct:(id)sender
{
    if (userInstance.shareInstance.isLogin)
    {
        NSString*url;
        if ([self.Note.isLike isEqualToString:@"1"])
        {
            url=@"studyNote/API/unLikeNote.php";
        }
        else
        {
            url=@"studyNote/API/likeNote.php";
        }
        NSDictionary *parameters=[[NSDictionary alloc] initWithObjectsAndKeys:userInstance.shareInstance.user_id ,@"user_id",self.note_id,@"note_id",nil];
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
                 if ([strongSelf.Note.isLike isEqualToString:@"1"])
                 {
                     strongSelf.Note.isLike=@"0";
                    [self.likeButton setBackgroundImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
                 }
                 else
                 {
                     strongSelf.Note.isLike=@"1";
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


- (IBAction)collectionNoteAct:(id)sender
{
    if (userInstance.shareInstance.isLogin)
    {
        NSString*url;
        if ([self.Note.isCollection isEqualToString:@"1"])
        {
            url=@"studyNote/API/unCollectionNote.php";
        }
        else
        {
            url=@"studyNote/API/collectionNote.php";
        }
        NSDictionary *parameters=[[NSDictionary alloc] initWithObjectsAndKeys:userInstance.shareInstance.user_id,@"user_id",self.note_id,@"note_id",nil];
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
                 if ([strongSelf.Note.isCollection isEqualToString:@"1"])
                 {
                     strongSelf.Note.isCollection=@"0";
                     [self.collectionButton setBackgroundImage:[UIImage imageNamed:@"Collection-icon"] forState:UIControlStateNormal];
                 }
                 else
                 {
                     strongSelf.Note.isCollection=@"1";
                     [self.collectionButton setBackgroundImage:[UIImage imageNamed:@"beCollection-icon"] forState:UIControlStateNormal];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.tag==0)
    {
//            CGPoint offset = scrollView.contentOffset;
//            if(offset.y>0&&scrollView.contentSize.height-offset.y>1000)
//            {
//                if(offset.y<self.LastOffset.y)
//                {
//                    [self.navigationController setNavigationBarHidden:NO animated:YES];
//                }
//                else
//                {
//                    [self.navigationController setNavigationBarHidden:YES animated:YES];
//                }
//            }
//            self.LastOffset=offset;
        }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.NoteCommentModelArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    noteCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"noteCommentCell" forIndexPath:indexPath];
    if (cell==nil) {
        cell=[[noteCommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"noteCommentCell"];
    }
    NoteComment*noteComment=self.NoteCommentModelArray[indexPath.row];
    cell.avatar.tag=indexPath.row;
    [cell.avatar jm_setImageWithCornerRadius:cell.avatar.frame.size.width/2 imageURL:[[NSURL alloc] initWithString: noteComment.avatar] placeholder:nil size:cell.avatar.frame.size];
     __weak typeof(self) weakself=self;
    cell.callBackBlock = ^(int indexPath)
    {
        __strong __typeof(weakself)strongSelf = weakself;
        UIStoryboard*main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        userPageTableViewController* vc=[main instantiateViewControllerWithIdentifier:@"userPageTableViewController"];
        NoteComment* cm=strongSelf.NoteCommentModelArray[indexPath];
        vc.user_id=cm.user_id;
        [strongSelf.navigationController pushViewController:vc animated:YES];
    };
//    cell.callBackBlock = ^(int indexPath)
//    {
//        UIStoryboard*main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        userPageTableViewController* vc=[main instantiateViewControllerWithIdentifier:@"userPageTableViewController"];
//        NoteComment* cm=self.NoteCommentModelArray[indexPath];
//        vc.user_id=cm.user_id;
//        [self.navigationController pushViewController:vc animated:YES];
//    };
    cell.username.text=noteComment.username;
    cell.create_time.text=noteComment.create_time;
    cell.content.text=noteComment.content;
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
