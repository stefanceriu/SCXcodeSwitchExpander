//
//  IDEWorkspaceWindowController.h
//  SCXcodeSwitchExpander
//
//  Created by Tomohiro Kumagai on 4/11/16.
//  Copyright © 2016 Stefan Ceriu. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class IDEEditorArea;

@interface IDEWorkspaceWindowController : NSWindowController <NSWindowDelegate>

@property (readonly) IDEEditorArea *editorArea;

@end
