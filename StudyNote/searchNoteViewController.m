//
//  searchNoteViewController.m
//  StudyNote
//
//  Created by 辉仔 on 2017/4/12.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import <AFNetworking.h>
#import <MJRefresh.h>
#import <MJExtension.h>
#import <UIImageView+WebCache.h>
#import <JMRoundedCorner/JMRoundedCorner.h>
#import "mainPageTopNoteModel.h"
#import "searchNoteViewController.h"
#import "mainPageNoteTableViewCell.h"
#import "sortTableViewCell.h"
#import "ReadNotePageTableViewController.h"
#import "userPageTableViewController.h"

@interface searchNoteViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchDisplayDelegate,UIScrollViewDelegate>
@property CGPoint LastOffset;
@property (weak, nonatomic) IBOutlet UIButton *sortButton;
@property (weak, nonatomic) IBOutlet UIButton *educationButton;
@property (weak, nonatomic) IBOutlet UITableView *conditionTableView;
@property(strong,nonatomic) NSArray* educations;
@property(strong,nonatomic) NSArray* sort;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property(strong,nonatomic)AFHTTPSessionManager*manager;
@property(strong,nonatomic)NSMutableArray* searchNoteModelArray;
@property(strong,nonatomic)NSString* searchKeyWord;
@property(strong,nonatomic)NSString* order;
@property(strong,nonatomic)NSString* education;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewH;
@property NSInteger page;
@end

@implementation searchNoteViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.conditionTableView.layer.borderWidth=1;
    self.conditionTableView.layer.borderColor=[[UIColor lightGrayColor] CGColor];
    self.conditionTableView.layer.masksToBounds=YES;
    self.LastOffset=CGPointMake(0, 0);
    self.searchBar.showsCancelButton=YES;
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"deployList" ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    self.educations=data[@"education"];
    self.sort=[[NSArray alloc]initWithObjects:@"按时间排序",@"按热度排序", nil];
    self.searchNoteModelArray=[[NSMutableArray alloc]init];
    self.education=@"0";
    self.order=@"0";
    self.page=1;
    [self.searchBar becomeFirstResponder];
    self.conditionTableView.estimatedRowHeight=300;
    self.conditionTableView.rowHeight=UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight=300;
    self.tableView.rowHeight=UITableViewAutomaticDimension;
    self.manager = [AFHTTPSessionManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    if (self.searchTag!=NULL)
    {
        self.searchBar.text=self.searchTag;
        self.searchKeyWord=self.searchTag;
        [self loadNewData];
    }
}

- (IBAction)dismiss:(id)sender
{
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadNewData
{
    NSString*KeyWord=[self.searchKeyWord stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (![KeyWord isEqualToString:@""])
    {
        NSDictionary *parameters=[[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)self.page] ,@"page",self.searchKeyWord,@"keyWord",self.order,@"order",self.education,@"education",nil];
        __weak typeof(self) weakself=self;
        [self.manager POST:[NSString stringWithFormat:@"%@studyNote/API/searchNote.php", urlPrefix] parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
         {
             __strong __typeof(weakself)strongSelf = weakself;
             NSArray* response=(NSArray*)responseObject[@"data"];
             if (response.count>0)
             {
                 for (int i=0; i<response.count; i++)
                 {
                     mainPageTopNoteModel* topNoteModel=[mainPageTopNoteModel mj_objectWithKeyValues:response[i]];
                     [strongSelf.searchNoteModelArray addObject:topNoteModel];
                 }
                 strongSelf.page++;
                 [strongSelf.tableView.mj_footer endRefreshing];
                 [strongSelf.tableView reloadData];
             }
             else
             {
                 [strongSelf.tableView.mj_footer endRefreshingWithNoMoreData];
             }

         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"%@",error);
             [weakself.tableView.mj_header endRefreshing];
         }];
    }
}

- (IBAction)educationButton:(id)sender
{
    NSString*KeyWord=[self.searchKeyWord stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (![KeyWord isEqualToString:@""])
    {
        [self.view layoutIfNeeded];
         __weak typeof(self) weakself=self;
        [UIView animateWithDuration:0.3
                         animations:^{
                             __strong __typeof(weakself)strongSelf = weakself;
                             strongSelf.tableViewH.constant=30*strongSelf.educations.count;
                             [strongSelf.view layoutIfNeeded];
                         }];
        self.educationButton.tag=1;
        self.sortButton.tag=0;
        [self.conditionTableView reloadData];
    }
}

- (IBAction)sortButton:(id)sender
{
    NSString*KeyWord=[self.searchKeyWord stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (![KeyWord isEqualToString:@""])
    {
        [self.view layoutIfNeeded];
        __weak typeof(self) weakself=self;
        [UIView animateWithDuration:0.3
                         animations:^{
                             __strong __typeof(weakself)strongSelf = weakself;
                             strongSelf.tableViewH.constant=30*strongSelf.sort.count;
                             [strongSelf.view layoutIfNeeded];
                         }];
        self.educationButton.tag=0;
        self.sortButton.tag=1;
        [self.conditionTableView reloadData];
    }
}


#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchNoteModelArray removeAllObjects];
    [self.view endEditing:YES];
    self.page=1;
    self.searchKeyWord=searchBar.text;
    [self.tableView reloadData];
    self.tableView.mj_footer=[MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    [self.tableView.mj_footer beginRefreshing];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{

}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
    if (scrollView.tag==0)
    {
        [self.view layoutIfNeeded];
        __weak typeof(self) weakself=self;
        [UIView animateWithDuration:0.3
                         animations:^{
                             __strong __typeof(weakself)strongSelf = weakself;
                             strongSelf.tableViewH.constant=0;
                             [strongSelf.view layoutIfNeeded];
                         }];
    }
}


//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    if (scrollView.tag==0) {
//        if ( self.searchNoteModelArray.count>0)
//        {
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
//        }
//    }
//}



#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag==1)
    {
        if (self.educationButton.tag==1)
        {
            if (indexPath.row==0)
            {
                self.education=[NSString stringWithFormat:@"%ld",(long)indexPath.row];
            }
            else
            {
                self.education=[NSString stringWithFormat:@"%ld",(long)indexPath.row+1];
            }
            [self.educationButton setTitle:[NSString stringWithFormat:@"学历:%@",self.educations[indexPath.row]] forState:UIControlStateNormal];
        }
        else
        {
            self.order=[NSString stringWithFormat:@"%ld",(long)indexPath.row];
            [self.sortButton setTitle:[NSString stringWithFormat:@"%@",self.sort[indexPath.row]] forState:UIControlStateNormal];
        }
        [self.view layoutIfNeeded];
        __weak typeof(self) weakself=self;
        [UIView animateWithDuration:0.3
                         animations:^{
                             __strong __typeof(weakself)strongSelf = weakself;
                             strongSelf.tableViewH.constant=0;
                             [strongSelf.view layoutIfNeeded];
                         }];
        self.page=1;
        [self.searchNoteModelArray removeAllObjects];
        [self.tableView reloadData];
        [self.tableView.mj_footer beginRefreshing];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag==1)
    {
        if (self.educationButton.tag==1)
        {
            return self.educations.count;
        }
        else
        {
            return self.sort.count;
        }
    }
    else
    {
        return self.searchNoteModelArray.count;
    }
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (tableView.tag==1)
    {
        sortTableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:@"sortCell" forIndexPath:indexPath];
        if (cell==nil) {
            cell=[[sortTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sortCell"];
        }
        if (self.educationButton.tag==1)
        {
            cell.name.text=self.educations[indexPath.row];
        }
        else
        {
            cell.name.text=self.sort[indexPath.row];
        }
        return cell;
    }
    else
    {
        mainPageNoteTableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:@"searchPageNoteCell" forIndexPath:indexPath];
        if (cell==nil) {
            cell=[[mainPageNoteTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchPageNoteCell"];
        }
        mainPageTopNoteModel* searchNoteModel=self.searchNoteModelArray[indexPath.row];
        [cell.avatar jm_setImageWithCornerRadius:cell.avatar.frame.size.width/2 imageURL:[[NSURL alloc] initWithString: searchNoteModel.avatar] placeholder:nil size:cell.avatar.frame.size];
        if (![searchNoteModel.cover isEqual:@""])
        {
            cell.coverHeight.constant=120;
            [cell.cover sd_setImageWithURL:[[NSURL alloc] initWithString: searchNoteModel.cover]];
        }
        else
        {
            cell.cover.image=nil;
            cell.coverHeight.constant=0;
        }
        cell.avatar.tag=indexPath.row;
        __weak typeof(self) weakself=self;
        cell.callBackBlock = ^(int indexPath)
        {
            __strong __typeof(weakself)strongSelf = weakself;
            UIStoryboard*main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
            userPageTableViewController* vc=[main instantiateViewControllerWithIdentifier:@"userPageTableViewController"];
            mainPageTopNoteModel* cm=strongSelf.searchNoteModelArray[indexPath];
            vc.user_id=cm.creator_id;
            [strongSelf.navigationController pushViewController:vc animated:YES];
        };
        cell.username.text=searchNoteModel.username;
        cell.title.text=searchNoteModel.title;
        cell.categoryName.text=searchNoteModel.categoryName;
        cell.introduction.text=searchNoteModel.introduction;
        cell.likeCount.text=searchNoteModel.likeCount;
        cell.commentCount.text=searchNoteModel.commentCount;
        return cell;
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toReadNote"])
    {
        ReadNotePageTableViewController* rnptvc=segue.destinationViewController;
        mainPageTopNoteModel* searchNoteModel=self.searchNoteModelArray[self.tableView.indexPathForSelectedRow.row];
        rnptvc.note_id=searchNoteModel.note_id;
        rnptvc.htmlString=searchNoteModel.content;
    }
}


@end
