//
//  searchQuestionViewController.m
//  StudyNote
//
//  Created by 辉仔 on 2017/4/16.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import "searchQuestionViewController.h"
#import <AFNetworking.h>
#import <MJRefresh.h>
#import <MJExtension.h>
#import <UIImageView+WebCache.h>
#import <JMRoundedCorner/JMRoundedCorner.h>
#import "searchNoteViewController.h"
#import "sortTableViewCell.h"
#import "searchQuestionTableViewCell.h"
#import "searchQuestionModel.h"
#import "readQuestionTableViewController.h"
#import "answerAndQuestionModel.h"
#import "readAnswerViewController.h"


@interface searchQuestionViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchDisplayDelegate,UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *educationButton;
@property CGPoint LastOffset;
@property (weak, nonatomic) IBOutlet UIButton *sortButton;
@property (weak, nonatomic) IBOutlet UIButton *finshedButton;
@property (weak, nonatomic) IBOutlet UITableView *conditionTableView;
@property(strong,nonatomic) NSArray* finshedList;
@property(strong,nonatomic) NSArray* sort;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property(strong,nonatomic)AFHTTPSessionManager*manager;
@property(strong,nonatomic)NSMutableArray* searchQuestionModelArray;
@property(strong,nonatomic)NSArray* educations;
@property(strong,nonatomic)NSString* searchKeyWord;
@property(strong,nonatomic)NSString* order;
@property(strong,nonatomic)NSString* finshed;
@property(strong,nonatomic)NSString* education;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewH;
@property NSInteger page;
@end

@implementation searchQuestionViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.conditionTableView.layer.borderWidth=1;
    self.conditionTableView.layer.borderColor=[[UIColor lightGrayColor] CGColor];
    self.conditionTableView.layer.masksToBounds=YES;
    self.LastOffset=CGPointMake(0, 0);
    self.searchBar.showsCancelButton=YES;
    self.finshedList=[[NSArray alloc]initWithObjects:@"未关闭", @"已关闭",nil];
    self.sort=[[NSArray alloc]initWithObjects:@"按时间排序",@"按热度排序", nil];
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"deployList" ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    self.educations=data[@"education"];
    self.searchQuestionModelArray=[[NSMutableArray alloc]init];
    self.education=@"0";
    self.finshed=@"0";
    self.order=@"0";
    self.page=1;
    [self.searchBar becomeFirstResponder];
    self.conditionTableView.estimatedRowHeight=300;
    self.conditionTableView.rowHeight=UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight=300;
    self.tableView.rowHeight=UITableViewAutomaticDimension;
    self.manager = [AFHTTPSessionManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismiss:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)loadNewData
{
    NSString*KeyWord=[self.searchKeyWord stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (![KeyWord isEqualToString:@""])
    {
        NSDictionary *parameters=[[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)self.page] ,@"page",self.searchKeyWord,@"keyWord",self.order,@"order",self.finshed,@"finshed",self.education,@"education",nil];
        __weak typeof(self) weakself=self;
        [self.manager POST:[NSString stringWithFormat:@"%@studyNote/API/searchQuestion.php", urlPrefix] parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
         {
             __strong __typeof(weakself)strongSelf = weakself;
             NSArray* response=(NSArray*)responseObject[@"data"];
             if (response.count>0)
             {
                 for (int i=0; i<response.count; i++)
                 {
                     searchQuestionModel* SearchQuestionModel=[searchQuestionModel mj_objectWithKeyValues:response[i]];
                     [strongSelf.searchQuestionModelArray addObject:SearchQuestionModel];
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

- (IBAction)finshedButton:(id)sender
{
    NSString*KeyWord=[self.searchKeyWord stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (![KeyWord isEqualToString:@""])
    {
        [self.view layoutIfNeeded];
        __weak typeof(self) weakself=self;
        [UIView animateWithDuration:0.3
                         animations:^{
                             __strong __typeof(weakself)strongSelf = weakself;
                             strongSelf.tableViewH.constant=30*strongSelf.finshedList.count;
                             [strongSelf.view layoutIfNeeded];
                         }];
        self.finshedButton.tag=1;
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
        self.finshedButton.tag=0;
        [self.conditionTableView reloadData];
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
        self.finshedButton.tag=2;
        [self.conditionTableView reloadData];
    }
}


#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchQuestionModelArray removeAllObjects];
    [self.view endEditing:YES];
    self.page=1;
    self.searchKeyWord=searchBar.text;
    [self.tableView reloadData];
    self.tableView.mj_footer=[MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    [self.tableView.mj_footer beginRefreshing];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
     __weak typeof(self) weakself=self;
    [self.view endEditing:YES];
    if (scrollView.tag==0)
    {
        [self.view layoutIfNeeded];
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
//        if ( self.searchQuestionModelArray.count>0)
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
        if (self.finshedButton.tag==1)
        {
            self.finshed=[NSString stringWithFormat:@"%ld",(long)indexPath.row];
            [self.finshedButton setTitle:self.finshedList[indexPath.row] forState:UIControlStateNormal];
        }
        else if(self.finshedButton.tag==0)
        {
            self.order=[NSString stringWithFormat:@"%ld",(long)indexPath.row];
            [self.sortButton setTitle:self.sort[indexPath.row] forState:UIControlStateNormal];
        }
        else
        {
            self.education=[NSString stringWithFormat:@"%ld",(long)indexPath.row];
            [self.educationButton setTitle:[NSString stringWithFormat:@"学历:%@",self.educations[indexPath.row]]  forState:UIControlStateNormal];
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
        [self.searchQuestionModelArray removeAllObjects];
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
        if (self.finshedButton.tag==1)
        {
            return self.finshedList.count;
        }
        else if(self.finshedButton.tag==0)
        {
            return self.sort.count;
        }
        else
        {
            return self.educations.count;
        }
    }
    else
    {
        return self.searchQuestionModelArray.count;
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
        if (self.finshedButton.tag==1)
        {
            cell.name.text=self.finshedList[indexPath.row];
        }
        else if(self.finshedButton.tag==0)
        {
            cell.name.text=self.sort[indexPath.row];
        }
        else
        {
            cell.name.text=self.educations[indexPath.row];
        }
        return cell;
    }
    else
    {
        searchQuestionModel* SearchQuestionModel=self.searchQuestionModelArray[indexPath.row];
        if ([SearchQuestionModel.answer isEqualToString:@"1"])
        {
            searchQuestionTableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:@"searchPageQuestionCell" forIndexPath:indexPath];
            if (cell==nil) {
                cell=[[searchQuestionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchPageQuestionCell"];
            }
            if (![SearchQuestionModel.cover isEqual:@""])
            {
                cell.coverHeight.constant=120;
                [cell.cover sd_setImageWithURL:[[NSURL alloc] initWithString: SearchQuestionModel.cover]];
            }
            else
            {
                cell.cover.image=nil;
                cell.coverHeight.constant=0;
            }
            cell.title.text= SearchQuestionModel.title;
            cell.introduction.text=[NSString stringWithFormat:@"%@:%@",SearchQuestionModel.username,SearchQuestionModel.introduction];
            cell.likeCount.text=SearchQuestionModel.likeCount;
            cell.commentCount.text=SearchQuestionModel.commentCount;
            return cell;
        }
        else
        {
            searchQuestionTableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:@"searchPageNoAnswerCell" forIndexPath:indexPath];
            if (cell==nil) {
                cell=[[searchQuestionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchPageNoAnswerCell"];
            }
            if (![SearchQuestionModel.cover isEqual:@""])
            {
                cell.coverHeight.constant=120;
                [cell.cover sd_setImageWithURL:[[NSURL alloc] initWithString: SearchQuestionModel.cover]];
            }
            else
            {
                cell.cover.image=nil;
                cell.coverHeight.constant=0;
            }
            cell.title.text= SearchQuestionModel.title;
            cell.introduction.text=SearchQuestionModel.introduction;
            return cell;
        }
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toReadQuestion"])
    {
        readQuestionTableViewController* rqtvc=segue.destinationViewController;
        searchQuestionModel* SearchQuestionModel=self.searchQuestionModelArray[self.tableView.indexPathForSelectedRow.row];
        rqtvc.question_id=SearchQuestionModel.question_id;
        rqtvc.htmlString=SearchQuestionModel.content;
    }
    if ([segue.identifier isEqualToString:@"toReadAnswer"])
    {
        answerAndQuestionModel* aaqm = self.searchQuestionModelArray[self.tableView.indexPathForSelectedRow.row];
        readAnswerViewController* ravc=segue.destinationViewController;
        ravc.answer_id=aaqm.answer_id;
    }
}
@end
