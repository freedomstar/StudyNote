//
//  readQuestionTableViewController.h
//  StudyNote
//
//  Created by 辉仔 on 2017/4/17.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface readQuestionTableViewController : UITableViewController
@property(strong,nonatomic)NSString* question_id;
@property(strong,nonatomic)NSString* htmlString;
-(void)loadQuestion;
@end
