//
//  allListTableViewCell.h
//  StudyNote
//
//  Created by 辉仔 on 2017/4/25.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface allListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *introduction;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coverW;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coverH;
@property (weak, nonatomic) IBOutlet UILabel *publicTag;
@property (weak, nonatomic) IBOutlet UIImageView *cover;
@end
