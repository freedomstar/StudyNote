//
//  answerAndQuestionTableViewCell.h
//  StudyNote
//
//  Created by 辉仔 on 2017/4/9.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^CallBackBlcok) (int indexPath);
@interface answerAndQuestionTableViewCell : UITableViewCell
@property (nonatomic,copy)CallBackBlcok callBackBlock;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coverH;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UIImageView *cover;
@property (weak, nonatomic) IBOutlet UILabel *introduction;
@property (weak, nonatomic) IBOutlet UILabel *questionTitle;
@property (weak, nonatomic) IBOutlet UILabel *commentCount;
@property (weak, nonatomic) IBOutlet UILabel *likeCount;
@end
