//
//  mainPageTopNoteModel.h
//  StudyNote
//
//  Created by 辉仔 on 2017/4/7.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface mainPageTopNoteModel : NSObject
@property (strong, nonatomic)  NSString *avatar;
@property (strong, nonatomic)  NSString *username;
@property (strong, nonatomic)  NSString *title;
@property (strong, nonatomic)  NSString *cover;
@property (strong, nonatomic)  NSString *introduction;
@property (strong, nonatomic)  NSString *categoryName;
@property (strong, nonatomic)  NSString *likeCount;
@property (strong, nonatomic)  NSString *commentCount;
@property (strong, nonatomic)  NSString *note_id;
@property (strong, nonatomic)  NSString *creator_id;
@property (strong, nonatomic)  NSString *category_id;
@property (strong, nonatomic)  NSString *education_id;
@property(strong,nonatomic) NSString*content;
@end
