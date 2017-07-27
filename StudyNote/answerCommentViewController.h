//
//  answerCommentViewController.h
//  StudyNote
//
//  Created by 辉仔 on 2017/4/19.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "readAnswerViewController.h"
@interface answerCommentViewController : UIViewController
@property(strong,nonatomic)NSString*answer_id;
@property(strong,nonatomic)readAnswerViewController*ReadAnswerViewController;
@end
