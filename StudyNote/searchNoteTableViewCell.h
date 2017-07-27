//
//  searchNoteTableViewCell.h
//  StudyNote
//
//  Created by 辉仔 on 2017/4/13.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^CallBackBlcok) (int indexPath);
@interface searchNoteTableViewCell : UITableViewCell
@property (nonatomic,copy)CallBackBlcok callBackBlock;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coverHeight;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIImageView *cover;
@property (weak, nonatomic) IBOutlet UILabel *introduction;
@property (weak, nonatomic) IBOutlet UILabel *categoryName;
@property (weak, nonatomic) IBOutlet UILabel *likeCount;
@property (weak, nonatomic) IBOutlet UILabel *commentCount;
@end
