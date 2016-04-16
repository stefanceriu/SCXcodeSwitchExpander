//
//  DVTTextCompletionSession+SCXcodeSwitchExpander.m
//  SCXcodeSwitchExpander
//
//  Created by Tomohiro Kumagai on 4/11/16.
//  Copyright © 2016 Stefan Ceriu. All rights reserved.
//

#import "DVTTextCompletionSession+SCXcodeSwitchExpander.h"
#import "IDEWorkspace.h"

@implementation DVTTextCompletionSession (SCXcodeSwitchExpander)

- (IDEWorkspace *)switchExpander_currentWorkspace
{
    return [self.currentCompletionContext valueForKey:@"IDETextCompletionContextWorkspaceKey"];
}

@end
