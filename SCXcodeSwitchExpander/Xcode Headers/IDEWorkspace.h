//
//  IDEWorkspace.h
//  SCXcodeSwitchExpander
//
//  Created by Tomohiro Kumagai on 4/9/16.
//  Copyright © 2016 Stefan Ceriu. All rights reserved.
//

@class IDEIndex;

@interface IDEWorkspace : NSObject

@property (retain) IDEIndex *index;

- (void)_updateIndexableFiles:(id)arg1;

@end
