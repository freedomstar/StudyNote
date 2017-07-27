//
//  readAnswerViewController.h
//  StudyNote
//
//  Created by 辉仔 on 2017/4/19.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface readAnswerViewController : UIViewController
@property (strong,nonatomic)NSString* answer_id;
@property (strong,nonatomic)NSString* htmlString;
-(void)reloadAnswerComment;
-(void)loadAnswer;
@end
