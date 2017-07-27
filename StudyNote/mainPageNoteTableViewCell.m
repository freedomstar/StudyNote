//
//  mainPageNoteTableViewCell.m
//  StudyNote
//
//  Created by 辉仔 on 2017/4/7.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import "mainPageNoteTableViewCell.h"

@implementation mainPageNoteTableViewCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc]initWithTarget:self     action:@selector(toUserPage:)];
    tap.numberOfTapsRequired =1;
    tap.numberOfTouchesRequired =1;
    [self.avatar addGestureRecognizer:tap];
}

- (void)toUserPage:(id)sender
{
    self.callBackBlock(self.avatar.tag);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
