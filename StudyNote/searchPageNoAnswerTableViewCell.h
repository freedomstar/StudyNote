//
//  searchPageNoAnswerTableViewCell.h
//  StudyNote
//
//  Created by 辉仔 on 2017/4/16.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface searchPageNoAnswerTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coverHeight;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIImageView *cover;
@property (weak, nonatomic) IBOutlet UILabel *introduction;
@end
