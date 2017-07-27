//
//  userPageNoteModel.h
//  StudyNote
//
//  Created by 辉仔 on 2017/4/24.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface userPageNoteModel : NSObject
@property(strong,nonatomic)NSString* note_id;
@property(strong,nonatomic)NSString* content;
@property(strong,nonatomic)NSString* create_time;
@property(strong,nonatomic)NSString* creator_id;
@property(strong,nonatomic)NSString* category_id;
@property(strong,nonatomic)NSString* title;
@property(strong,nonatomic)NSString* public;
@property(strong,nonatomic)NSString* introduction;
@property(strong,nonatomic)NSString* cover;
@property(strong,nonatomic)NSString* category;
@end
