//
//  userPageNoteTableViewCell.h
//  StudyNote
//
//  Created by 辉仔 on 2017/4/24.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface userPageNoteTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIImageView *cover;
@property (weak, nonatomic) IBOutlet UILabel *introduction;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coverHeight;

@end
