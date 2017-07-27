//
//  XJTabBar.m
//  StudyNote
//
//  Created by 辉仔 on 2017/4/22.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import "XJTabBar.h"

@interface XJTabBar ()

/** 加号按钮 */
@property (nonatomic, weak) UIButton *pulsBtn;
@end

@implementation XJTabBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        //添加中间加号按钮
        UIButton *pulsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [pulsBtn setBackgroundImage:[UIImage imageNamed:@"pen"] forState:UIControlStateNormal];
//        [pulsBtn setBackgroundImage:[UIImage imageNamed:@"search"] forState:UIControlStateHighlighted];
        
        [pulsBtn sizeToFit];
        self.pulsBtn = pulsBtn;
//        self.pulsBtn.layer.cornerRadius=self.pulsBtn.frame.size.width/2;
//        self.pulsBtn.layer.borderWidth=1;
//        self.pulsBtn.layer.masksToBounds=YES;
        [self addSubview:pulsBtn];
        
        [pulsBtn addTarget:self action:@selector(pulsBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
    
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSInteger count = self.items.count + 1;
    
    CGFloat w = self.bounds.size.width / count;
    CGFloat h = self.bounds.size.height;
    CGFloat x = 0;
    CGFloat y = 0;
    
    int i = 0;
    for(UIView *btn in self.subviews) {
        
        if ([btn isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            
            if (i == 2) {
                
                i += 1;
            }
            x = i * w;
            
            btn.frame = CGRectMake(x, y, w, h);
            i++;
        }
        
        //设置加号按钮尺寸
        self.pulsBtn.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
//        [self.pulsBtn setFrame:CGRectMake(self.pulsBtn.frame.origin.x, self.pulsBtn.frame.origin.y, self.pulsBtn.frame.size.width*2, self.pulsBtn.frame.size.height*2)];
    }
}

- (void)pulsBtnClick
{
    if ([self.delegate respondsToSelector:@selector(tabBarDidPulsBtnClick:)]) {
        
        [self.delegate tabBarDidPulsBtnClick:self];
    }
}

@end
