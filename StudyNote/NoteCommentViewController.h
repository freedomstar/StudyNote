//
//  NoteCommentViewController.h
//  StudyNote
//
//  Created by 辉仔 on 2017/4/11.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReadNotePageTableViewController.h"

@interface NoteCommentViewController : UIViewController
@property(strong,nonatomic)NSString*note_id;
@property(strong,nonatomic)ReadNotePageTableViewController* readNotePageTableViewController;
@end
