//
//  NoteConfigureTableViewController.h
//  StudyNote
//
//  Created by 辉仔 on 2017/4/22.
//  Copyright © 2017年 freestar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "newNoteViewController.h"
#import "ReadNotePageTableViewController.h"

@interface NoteConfigureTableViewController : UITableViewController
@property(strong,nonatomic) NSMutableDictionary *parameters;
@property (strong,nonatomic)NSString* url;
@property (strong,nonatomic)ReadNotePageTableViewController* rnptvc;
@end
