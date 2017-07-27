//
//  answerAndQuestionModel.h
//  StudyNote
//
//  Created by 辉仔 on 2017/4/9.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface answerAndQuestionModel : NSObject
@property (strong, nonatomic)  NSString *avatar;
@property (strong, nonatomic)  NSString *username;
@property (strong, nonatomic)  NSString *cover;
@property (strong, nonatomic)  NSString *introduction;
@property (strong, nonatomic)  NSString *questionTitle;
@property (strong, nonatomic)  NSString *commentCount;
@property (strong, nonatomic)  NSString *answer_id;
@property (strong, nonatomic)  NSString *question_id;
@property (strong, nonatomic)  NSString *content;
@property (strong, nonatomic)  NSString *create_time;
@property (strong, nonatomic)  NSString *likeCount;
@property (strong, nonatomic)  NSString *answerer_id;
@end
