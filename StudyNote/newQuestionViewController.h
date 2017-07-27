//
//  newQuestionViewController.h
//  StudyNote
//
//  Created by 辉仔 on 2017/4/26.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import "ZSSRichTextEditor.h"
#import "readQuestionTableViewController.h"
#import "userInstance.h"
#import "questionModel.h"

@interface newQuestionViewController : ZSSRichTextEditor
@property(strong,nonatomic)questionModel*QuestionModel;
@property(strong,nonatomic)readQuestionTableViewController*rqtvc;
@end
