//
//  advertisementViewController.m
//  StudyNote
//
//  Created by 辉仔 on 2017/4/6.
//  Copyright © 2017年 freestar. All rights reserved.
//
#import "mainPageTopNoteModel.h"
#import <AFNetworking.h>
#import <MJRefresh.h>
#import <MJExtension.h>
#import <UIImageView+WebCache.h>
#import "advertisementViewController.h"
#import "ReadNotePageTableViewController.h"

@interface advertisementViewController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property(strong,nonatomic) NSMutableArray* topCoverNoteModelArray;
@property(nonatomic,strong)NSTimer*timer;
@property(strong,nonatomic)AFHTTPSessionManager*manager;
@end

@implementation advertisementViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.timer=[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(cutPage) userInfo:nil repeats:YES];
}


-(void)viewDidDisappear:(BOOL)animated
{
    [self.timer invalidate];
    self.timer=nil;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageArray=[[NSMutableArray alloc]init];
    self.titleArray=[[NSMutableArray alloc]initWithObjects:@"???", @"???", @"???", @"???", nil];
    self.topCoverNoteModelArray=[[NSMutableArray alloc]init];
    self.scrollView.delegate=self;
    self.scrollView.userInteractionEnabled=YES;
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setPagingEnabled:YES];
    [self.scrollView setContentSize:CGSizeMake(UIScreen.mainScreen.bounds.size.width*4, 0)];
    for (int i=0; i<4; i++)
    {
        UIImageView*ImageView=[[UIImageView alloc]init];
        ImageView.tag=i;
        [ImageView setFrame:CGRectMake(UIScreen.mainScreen.bounds.size.width*i, 0,UIScreen.mainScreen.bounds.size.width,self.scrollView.frame.size.height)];
        UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc]initWithTarget:self    action:@selector(tapAction:)];
        tap.numberOfTapsRequired =1;
        tap.numberOfTouchesRequired =1;
        [ImageView addGestureRecognizer:tap];
        [self.scrollView addSubview:ImageView];
        [self.imageArray addObject:ImageView];
    }
    self.manager = [AFHTTPSessionManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    __weak typeof(self) weakself=self;
    [self.manager POST:[NSString stringWithFormat:@"%@studyNote/API/getTopCoverNote.php", urlPrefix] parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         __strong __typeof(weakself)strongSelf = weakself;
         NSArray* response=(NSArray*)responseObject[@"data"];
         for (int i=0; i<response.count; i++)
         {
             mainPageTopNoteModel* topCoverNoteModel=[mainPageTopNoteModel mj_objectWithKeyValues:response[i]];
             UIImageView*iv=strongSelf.imageArray[i];
             [iv sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",topCoverNoteModel.cover]]];
             NSString*str=[NSString stringWithFormat:@"%@",topCoverNoteModel.title];
             strongSelf.titleArray[i]=str;
             [strongSelf.topCoverNoteModelArray addObject:topCoverNoteModel];
         }
         for (int i=0; i<self.imageArray.count; i++)
         {
             UIImageView*ImageView=self.imageArray[i];
             ImageView.userInteractionEnabled=YES;
         }
         strongSelf.titleLable.text=strongSelf.titleArray[0];
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         NSLog(@"%@",error);
     }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

-(void)tapAction:(UITapGestureRecognizer*) sender
{
    UITapGestureRecognizer* s=sender;
    mainPageTopNoteModel* topCoverNoteModel=self.topCoverNoteModelArray[s.view.tag];
    UIStoryboard*main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ReadNotePageTableViewController* vc=[main instantiateViewControllerWithIdentifier:@"ReadNotePageTableViewController"];
    vc.note_id=topCoverNoteModel.note_id;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)cutPage
{
    if (self.scrollView.contentOffset.x != self.scrollView.frame.size.width*3)
    {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x+UIScreen.mainScreen.bounds.size.width, 0) animated:YES];
    }
    else
    {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int index=self.scrollView.contentOffset.x/self.scrollView.frame.size.width+0.5;
    [self.pageControl setCurrentPage:index];
    if (index <= self.titleArray.count-1)
    {
        self.titleLable.text=self.titleArray[index];
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.timer invalidate];
    self.timer=nil;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
     self.timer=[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(cutPage) userInfo:nil repeats:YES];
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
