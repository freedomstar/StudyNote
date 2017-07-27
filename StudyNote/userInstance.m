//
//  userInstance.m
//  StudyNote
//
//  Created by 辉仔 on 2017/5/5.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import "userInstance.h"

@interface userInstance()

@end;

@implementation userInstance

+(instancetype) shareInstance
{
    static userInstance *sharedUserInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedUserInstance = [[self alloc] init];
    });
    return sharedUserInstance;
}

-(void)initUser
{
    self.user_id=@"-5";
    self.isLogin=NO;
}

@end

