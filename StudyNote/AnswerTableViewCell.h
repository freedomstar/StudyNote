//
//  AnswerTableViewCell.h
//  StudyNote
//
//  Created by 辉仔 on 2017/4/19.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^CallBackBlcok) (int indexPath);
@interface AnswerTableViewCell : UITableViewCell
@property (nonatomic,copy)CallBackBlcok callBackBlock;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UIImageView *cover;
@property (weak, nonatomic) IBOutlet UILabel *introduction;
@property (weak, nonatomic) IBOutlet UILabel *likeCount;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coverHeight;
@property (weak, nonatomic) IBOutlet UILabel *commentCount;
@end
