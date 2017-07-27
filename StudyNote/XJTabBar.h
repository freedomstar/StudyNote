//
//  XJTabBar.h
//  StudyNote
//
//  Created by 辉仔 on 2017/4/22.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XJTabBar;
@protocol XJTabBarDelegate <NSObject>

@optional
//加号按钮的点击
- (void)tabBarDidPulsBtnClick:(XJTabBar *)tabBar;

@end


@interface XJTabBar : UITabBar

/**代理 */
@property (nonatomic, weak) id<XJTabBarDelegate> delegate;

@end
