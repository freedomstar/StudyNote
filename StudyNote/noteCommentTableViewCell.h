//
//  noteCommentTableViewCell.h
//  StudyNote
//
//  Created by 辉仔 on 2017/4/11.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^CallBackBlcok) (int indexPath);

@interface noteCommentTableViewCell : UITableViewCell
@property (nonatomic,copy)CallBackBlcok callBackBlock;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *create_time;
@property (weak, nonatomic) IBOutlet UILabel *content;
@end
