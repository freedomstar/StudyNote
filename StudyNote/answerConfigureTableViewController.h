//
//  answerConfigureTableViewController.h
//  StudyNote
//
//  Created by 辉仔 on 2017/4/26.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "readAnswerViewController.h"

@interface answerConfigureTableViewController : UITableViewController
@property(strong,nonatomic) NSMutableDictionary *parameters;
@property(strong,nonatomic)readAnswerViewController* ravc;
@property(strong,nonatomic)NSString* url;
@end
