//
//  ZSSDemoPickerViewController.h
//  ZSSRichTextEditor
//
//  Created by Nicholas Hubbard on 1/30/14.
//  Copyright (c) 2014 Zed Said Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RichTextEditorViewController.h"

@interface ZSSDemoPickerViewController : UIViewController

@property (nonatomic, strong) RichTextEditorViewController *demoView;
@property (nonatomic) BOOL isInsertImagePicker;

@end
