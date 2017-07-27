//
//  answerComment.h
//  StudyNote
//
//  Created by 辉仔 on 2017/4/19.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface answerComment : NSObject
@property(strong,nonatomic)NSString* answer_comment_id;
@property(strong,nonatomic)NSString* content;
@property(strong,nonatomic)NSString* answer_id;
@property(strong,nonatomic)NSString* user_id;
@property(strong,nonatomic)NSString* create_time;
@property(strong,nonatomic)NSString* username;
@property(strong,nonatomic)NSString* avatar;
//@property(strong,nonatomic)NSString* self;
@end
