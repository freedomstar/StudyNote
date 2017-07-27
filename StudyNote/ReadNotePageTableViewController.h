//
//  ReadNotePageTableViewController.h
//  StudyNote
//
//  Created by 辉仔 on 2017/4/10.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReadNotePageTableViewController : UIViewController
@property (strong,nonatomic)NSString* note_id;
@property (strong,nonatomic)NSString* htmlString;
-(void)reloadNoteComment;
-(void)loadNote;
@end


