//
//  note.h
//  StudyNote
//
//  Created by 辉仔 on 2017/4/11.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface note : NSObject
@property(strong,nonatomic)NSString* note_id;
@property(strong,nonatomic)NSString* content;
@property(strong,nonatomic)NSString* create_time;
@property(strong,nonatomic)NSString* author_name;
@property(strong,nonatomic)NSString* author_avatar;
@property(strong,nonatomic)NSString* author_id;
@property(strong,nonatomic)NSString* category_id;
@property(strong,nonatomic)NSString* category;
@property(strong,nonatomic)NSString* title;
@property(strong,nonatomic)NSString* public;
@property(strong,nonatomic)NSString* education_id;
@property(strong,nonatomic)NSString* introduction;
@property(strong,nonatomic)NSString* cover;
@property (strong,nonatomic)NSString* isLike;
@property (strong,nonatomic)NSString* isCollection;
@property (strong,nonatomic)NSString* hot;
@end
