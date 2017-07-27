//
//  mainPageTableViewController.m
//  StudyNote
//
//  Created by 辉仔 on 2017/4/7.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import "mainPageTableViewController.h"
#import "mainPageFirstTableViewCell.h"
#import "advertisementViewController.h"
#import "mainPageNoteTableViewCell.h"
#import "topTagViewController.h"
#import "mainPageTopNoteModel.h"
#import <AFNetworking.h>
#import <MJRefresh.h>
#import <MJExtension.h>
#import <UIImageView+WebCache.h>
#import <JMRoundedCorner/JMRoundedCorner.h>
#import "ReadNotePageTableViewController.h"
#import "userPageTableViewController.h"


@interface mainPageTableViewController ()
@property(strong,nonatomic)AFHTTPSessionManager*manager;
@property NSInteger page;
@property(strong,nonatomic)NSMutableArray* topNoteModelArray;
@end

@implementation mainPageTableViewController


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.translucent = NO;
    self.tabBarController.tabBar.hidden=NO;
    [self.tableView.mj_header beginRefreshing];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    self.page=1;
    self.tableView.estimatedRowHeight=300;
    self.tableView.rowHeight=UITableViewAutomaticDimension;
    self.topNoteModelArray=[[NSMutableArray alloc]init];
    self.manager = [AFHTTPSessionManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self  refreshingAction:@selector(loadNewData)];
//    [self.tableView.mj_footer beginRefreshing];
    self.tableView.mj_header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(RefreshData)];
//    [self.tableView.mj_header beginRefreshing];
}





-(void)RefreshData
{
    self.tableView.userInteractionEnabled=NO;
    [self.tableView.mj_footer endRefreshingWithNoMoreData];
    self.page=1;
    NSDictionary *parameters=[[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)self.page] ,@"page", nil];
    __weak typeof(self) weakself=self;
    [self.manager POST:[NSString stringWithFormat:@"%@studyNote/API/getTopNote.php", urlPrefix] parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         __strong __typeof(weakself)strongSelf = weakself;
         NSArray* response=(NSArray*)responseObject[@"data"];
         if (response.count>0)
         {
             [self.topNoteModelArray removeAllObjects];
             for (int i=0; i<response.count; i++)
             {
                 mainPageTopNoteModel* topNoteModel=[mainPageTopNoteModel mj_objectWithKeyValues:response[i]];
                 [strongSelf.topNoteModelArray addObject:topNoteModel];
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
    NSDictionary *parameters=[[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)self.page] ,@"page", nil];
    __weak typeof(self) weakself=self;
    [self.manager POST:[NSString stringWithFormat:@"%@studyNote/API/getTopNote.php", urlPrefix] parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
    {
        __strong __typeof(weakself)strongSelf = weakself;
        NSArray* response=(NSArray*)responseObject[@"data"];
        if (response.count>0)
        {
            for (int i=0; i<response.count; i++)
            {
                mainPageTopNoteModel* topNoteModel=[mainPageTopNoteModel mj_objectWithKeyValues:response[i]];
                [strongSelf.topNoteModelArray addObject:topNoteModel];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.topNoteModelArray.count+1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row==0)
    {
        mainPageFirstTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mainPageFirstCell" forIndexPath:indexPath];
        if (cell==nil) {
            cell=[[mainPageFirstTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"mainPageFirstCell"];
        }
        if (cell.advertisementView.subviews.count==0)
        {
            advertisementViewController* avc=[[advertisementViewController alloc]init];
            [avc.view setFrame:CGRectMake(0, 0, cell.advertisementView.frame.size.width, cell.advertisementView.frame.size.height)];
            [cell.advertisementView addSubview:avc.view];
            [self addChildViewController:avc];
            [avc.view layoutIfNeeded];
        }
        if (cell.topTagView.subviews.count==0)
        {
            topTagViewController*ttvc=[[topTagViewController alloc]init];
            [ttvc.view setFrame:CGRectMake(0, 0, cell.topTagView.frame.size.width, cell.topTagView.frame.size.height)];
            [cell.topTagView addSubview:ttvc.view];
            [self addChildViewController:ttvc];
        }
        cell.searchButton.layer.masksToBounds = YES;
        cell.searchButton.layer.cornerRadius = cell.searchButton.frame.size.height/2;
        cell.searchButton.layer.borderWidth = 1.0;
        cell.searchButton.layer.borderColor = [[UIColor whiteColor] CGColor];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone]; 
        return cell;
    }
    else
    {
        mainPageNoteTableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:@"mainPageNoteCell" forIndexPath:indexPath];
        if (cell==nil) {
            cell=[[mainPageNoteTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"mainPageNoteCell"];
        }
        mainPageTopNoteModel* topNoteModel=self.topNoteModelArray[indexPath.row-1];
        [cell.avatar jm_setImageWithCornerRadius:cell.avatar.frame.size.width/2 imageURL:[[NSURL alloc] initWithString: topNoteModel.avatar] placeholder:nil size:cell.avatar.frame.size];
        if (![topNoteModel.cover isEqual:@""])
        {
            cell.coverHeight.constant=120;
            [cell.cover sd_setImageWithURL:[[NSURL alloc] initWithString: topNoteModel.cover]];
        }
        else
        {
            cell.cover.image=nil;
            cell.coverHeight.constant=0;
        }
        cell.avatar.tag=indexPath.row-1;
        __weak typeof(self) weakself=self;
        cell.callBackBlock = ^(int indexPath)
        {
            __strong __typeof(weakself)strongSelf = weakself;
            UIStoryboard*main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
            userPageTableViewController* vc=[main instantiateViewControllerWithIdentifier:@"userPageTableViewController"];
            mainPageTopNoteModel* cm=strongSelf.topNoteModelArray[indexPath];
            vc.user_id=cm.creator_id;
            [strongSelf.navigationController pushViewController:vc animated:YES];
        };

        cell.username.text=topNoteModel.username;
        cell.title.text=topNoteModel.title;
        cell.categoryName.text=[NSString stringWithFormat:@"标签:%@",topNoteModel.categoryName];
        cell.introduction.text=topNoteModel.introduction;
        cell.likeCount.text=topNoteModel.likeCount;
        cell.commentCount.text=topNoteModel.commentCount;
        return cell;
    }
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toReadNote"])
    {
        ReadNotePageTableViewController* rnptvc=segue.destinationViewController;
        mainPageTopNoteModel* MainPageTopNoteModel=self.topNoteModelArray[self.tableView.indexPathForSelectedRow.row-1];
        rnptvc.note_id=MainPageTopNoteModel.note_id;
        rnptvc.htmlString=MainPageTopNoteModel.content;
    }
}


@end
