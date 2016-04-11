//
//  SCXcodeSwitchExpander.h
//  SCXcodeSwitchExpander
//
//  Created by Stefan Ceriu on 13/03/2014.
//  Copyright (c) 2014 Stefan Ceriu. All rights reserved.
//

@class IDEIndex;
@class IDEWorkspace;

//#define SCXcodeSwitchExpanderIndexDidChangeNotification @"SCXcodeSwitchExpanderIndexDidChangeNotification"

@interface SCXcodeSwitchExpander : NSObject

+ (instancetype)sharedSwitchExpander;

//@property (nonatomic, weak, readonly) IDEIndex *index;
//@property (nonatomic, assign)  isSwift;
@property(readonly) IDEWorkspace *currentWorkspace;

- (void)indexNeedsUpdate:(IDEIndex*)index;

@end
