//
//  NewAnswerViewController.h
//  StudyNote
//
//  Created by 辉仔 on 2017/4/25.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import "ZSSRichTextEditor.h"
#import "Answer.h"
#import "readAnswerViewController.h"

@interface NewAnswerViewController : ZSSRichTextEditor
@property(strong,nonatomic)NSString* question_id;
@property(strong,nonatomic)Answer* answer;
@property(strong,nonatomic)readAnswerViewController* ravc;
@end
