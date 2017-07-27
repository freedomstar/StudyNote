//
//  questionModel.h
//  StudyNote
//
//  Created by 辉仔 on 2017/4/19.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface questionModel : NSObject
@property (strong, nonatomic)  NSString *avatar;
@property (strong, nonatomic)  NSString *username;
@property (strong, nonatomic)  NSString *cover;
@property (strong, nonatomic)  NSString *introduction;
@property (strong, nonatomic)  NSString *education_id;
@property (strong, nonatomic)  NSString *state;
@property (strong, nonatomic)  NSString *title;
@property (strong, nonatomic)  NSString *question_id;
@property (strong, nonatomic)  NSString *content;
@property (strong, nonatomic)  NSString *create_time;
@property (strong, nonatomic)  NSString *creator_id;
@end
