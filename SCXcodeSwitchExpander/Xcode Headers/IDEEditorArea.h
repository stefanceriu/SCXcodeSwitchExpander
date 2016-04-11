//
//  IDEEditorArea.h
//  SCXcodeSwitchExpander
//
//  Created by Tomohiro Kumagai on 4/11/16.
//  Copyright © 2016 Stefan Ceriu. All rights reserved.
//

@class IDEEditorContext;

@interface IDEEditorArea : NSObject

@property(retain, nonatomic) IDEEditorContext *lastActiveEditorContext;

@end
