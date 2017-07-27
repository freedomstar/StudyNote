//
//  newNoteViewController.h
//  StudyNote
//
//  Created by 辉仔 on 2017/4/22.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import "ZSSRichTextEditor.h"
#import "note.h"
#import "ReadNotePageTableViewController.h"

@interface newNoteViewController : ZSSRichTextEditor
@property(strong,nonatomic)note* Note;
@property (strong,nonatomic)ReadNotePageTableViewController* rnptvc;
@end
