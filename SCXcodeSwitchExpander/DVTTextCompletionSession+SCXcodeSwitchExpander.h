//
//  DVTTextCompletionSession+SCXcodeSwitchExpander.h
//  SCXcodeSwitchExpander
//
//  Created by Tomohiro Kumagai on 4/11/16.
//  Copyright © 2016 Stefan Ceriu. All rights reserved.
//

#import "DVTTextCompletionSession.h"

@class IDEWorkspace;

@interface DVTTextCompletionSession (SCXcodeSwitchExpander)

@property (readonly) IDEWorkspace *switchExpander_currentWorkspace;

@end
