//
//  SCXcodeSwitchExpander.h
//  SCXcodeSwitchExpander
//
//  Created by Stefan Ceriu on 13/03/2014.
//  Copyright (c) 2014 Stefan Ceriu. All rights reserved.
//

@class IDEIndex;
@class IDEWorkspace;

@interface SCXcodeSwitchExpander : NSObject

+ (instancetype)sharedSwitchExpander;

/// This property is unavailable because index will be get from IDEWorkspace directly.
@property (nonatomic, weak, readonly) IDEIndex *index NS_UNAVAILABLE;

/// This property is unavailable because language will be get from IDEEditor directly.
@property (nonatomic, assign) BOOL isSwift NS_UNAVAILABLE;

/// Returns current workspace.
@property(readonly) IDEWorkspace *currentWorkspace;

@end
