//
//  questionConfigureTableViewController.h
//  StudyNote
//
//  Created by 辉仔 on 2017/5/4.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "readQuestionTableViewController.h"
#import "userInstance.h"


@interface questionConfigureTableViewController : UITableViewController
@property(strong,nonatomic) NSMutableDictionary *parameters;
@property(strong,nonatomic)readQuestionTableViewController*rqtvc;
@property(strong,nonatomic) NSString *url;
@end
