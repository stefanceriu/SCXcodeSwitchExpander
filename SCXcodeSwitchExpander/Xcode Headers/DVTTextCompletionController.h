//
//  DVTTextCompletionController.h
//  SCXcodeSwitchExpander
//
//  Created by Stefan Ceriu on 13/03/2014.
//  Copyright (c) 2014 Stefan Ceriu. All rights reserved.
//

@class DVTCompletingTextView;
@class DVTTextCompletionSession;

@interface DVTTextCompletionController : NSObject

@property(readonly) DVTCompletingTextView *textView;
@property(retain) DVTTextCompletionSession *currentSession;

- (BOOL)acceptCurrentCompletion;

@end

