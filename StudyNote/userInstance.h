//
//  userInstance.h
//  StudyNote
//
//  Created by 辉仔 on 2017/5/5.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface userInstance : NSObject
@property(strong,nonatomic)NSString* user_id;
@property(strong,nonatomic)NSString* avatar;
@property(strong,nonatomic)NSString* username;
@property BOOL isLogin;
+(instancetype) shareInstance;
-(void)initUser;
@end
