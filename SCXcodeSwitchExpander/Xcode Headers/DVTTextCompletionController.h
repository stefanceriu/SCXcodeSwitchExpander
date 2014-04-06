//
//  DVTTextCompletionController.h
//  SCXcodeSwitchExpander
//
//  Created by Stefan Ceriu on 13/03/2014.
//  Copyright (c) 2014 Stefan Ceriu. All rights reserved.
//

@class DVTTextCompletionSession;

@interface DVTTextCompletionController : NSObject

@property(retain) DVTTextCompletionSession *currentSession;

- (BOOL)acceptCurrentCompletion;

@end

