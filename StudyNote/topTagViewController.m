//
//  topTagViewController.m
//  StudyNote
//
//  Created by 辉仔 on 2017/4/7.
//  Copyright © 2017年 freestar. All rights reserved.
//
#import "TopCategoryModel.h"
#import "topTagViewController.h"
#import <AFNetworking.h>
#import <MJRefresh.h>
#import <MJExtension.h>
#import <UIImageView+WebCache.h>
#import "advertisementViewController.h"
#import "searchNoteViewController.h"
#import "searchNavigationController.h"

@interface topTagViewController ()
@property(nonatomic,strong) NSMutableArray*TopCategoryModelArray;
@property(strong,nonatomic)AFHTTPSessionManager*manager;
@end

@implementation topTagViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    int tagCount=5;
    int buttonW=65;
    int buttonH=26;
    int wSpacing=12;
    int hSpacing=7;
    self.manager = [AFHTTPSessionManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.TopCategoryModelArray=[[NSMutableArray alloc]init];
    self.buttonArray=[[NSMutableArray alloc]init];
    [self.scrollView setContentSize:CGSizeMake(tagCount*(buttonW+wSpacing), 0)];
    for (int i=0; i<tagCount; i++)
    {
        UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake((wSpacing+buttonW)*i+wSpacing/2, hSpacing, buttonW, buttonH)];
        [btn addTarget:self action:@selector(searchTag) forControlEvents:UIControlEventTouchUpInside];
        [btn setTintColor:[UIColor whiteColor]];
        btn.tag=i;
        btn.titleLabel.font=[UIFont systemFontOfSize:14];
        switch (i)
        {
            case 0:
                [btn setBackgroundColor:[UIColor redColor]];
                break;
            case 1:
                [btn setBackgroundColor:[UIColor grayColor]];
                break;
            case 2:
                [btn setBackgroundColor:[[UIColor alloc]initWithRed:171.0f/255.0f green:71.0f/255.0f blue:188.0f/255.0f alpha:1]];
                break;
            case 3:
                [btn setBackgroundColor:[[UIColor alloc]initWithRed:41.0f/255.0f green:182.0f/255.0f blue:246.0f/255.0f alpha:1]];
                break;
            case 4:
                [btn setBackgroundColor:[[UIColor alloc]initWithRed:1 green:96.0f/255.0f blue:145.0f/255.0f alpha:1]];
                break;
            default:
                break;
        }
        UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc]initWithTarget:self    action:@selector(tapAction:)];
        tap.numberOfTapsRequired =1;
        tap.numberOfTouchesRequired =1;
        [btn addGestureRecognizer:tap];
        [self.scrollView addSubview:btn];
        [self.buttonArray addObject:btn];
    }
    __weak typeof(self) weakself=self;
    [self.manager POST:[NSString stringWithFormat:@"%@studyNote/API/getTopCategory.php", urlPrefix] parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         __strong __typeof(weakself)strongSelf = weakself;
         NSArray* response=(NSArray*)responseObject[@"data"];
         for (int i=0; i<response.count; i++)
         {
             TopCategoryModel* topCategoryModel=[TopCategoryModel mj_objectWithKeyValues:response[i]];
             UIButton*btn=strongSelf.buttonArray[i];
             [btn setTitle:topCategoryModel.name forState:UIControlStateNormal];
             [strongSelf.TopCategoryModelArray addObject:topCategoryModel];
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         NSLog(@"%@",error);
     }];
}


-(void)tapAction:(UITapGestureRecognizer*) sender
{
    UITapGestureRecognizer* s=sender;
    UIButton* u=self.buttonArray[s.view.tag];
    UIStoryboard*main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    searchNavigationController* nv=[main instantiateViewControllerWithIdentifier:@"searchnvcv"];
    searchNoteViewController* vc=nv.childViewControllers[0];
    vc.searchTag=u.titleLabel.text;
    [self presentViewController:nv animated:YES completion:nil];
}


-(void)searchTag
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

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
