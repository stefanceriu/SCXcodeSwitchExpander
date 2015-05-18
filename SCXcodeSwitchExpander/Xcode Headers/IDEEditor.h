//
//  IDEEditor.h
//  SCXcodeSwitchExpander
//
//  Created by Stefan Ceriu on 16/05/2015.
//  Copyright (c) 2015 Stefan Ceriu. All rights reserved.
//

#import "DVTViewController.h"

@class IDEFileTextSettings;

@interface IDEEditor : DVTViewController

@property(retain, nonatomic) IDEFileTextSettings *fileTextSettings;

@end

