//
//  NoteComment.h
//  StudyNote
//
//  Created by 辉仔 on 2017/4/11.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NoteComment : NSObject
@property(strong,nonatomic)NSString* note_comment_id;
@property(strong,nonatomic)NSString* content;
@property(strong,nonatomic)NSString* note_id;
@property(strong,nonatomic)NSString* user_id;
@property(strong,nonatomic)NSString* create_time;
@property(strong,nonatomic)NSString* username;
@property(strong,nonatomic)NSString* avatar;
@property(strong,nonatomic)NSString* self;
@end
