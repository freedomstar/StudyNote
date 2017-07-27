//
//  allListModel.h
//  StudyNote
//
//  Created by 辉仔 on 2017/4/25.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface allListModel : NSObject
@property(strong,nonatomic) NSString*title;
@property(strong,nonatomic) NSString*introduction;
@property(strong,nonatomic) NSString*cover;
@property(strong,nonatomic) NSString*note_id;
@property(strong,nonatomic) NSString*answer_id;
@property(strong,nonatomic) NSString*question_id;
@property(strong,nonatomic) NSString*public;
@property(strong,nonatomic) NSString* state;
@end
