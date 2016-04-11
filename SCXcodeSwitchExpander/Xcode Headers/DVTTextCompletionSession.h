//
//  DVTTextCompletionSession.h
//  SCXcodeSwitchExpander
//
//  Created by Stefan Ceriu on 13/03/2014.
//  Copyright (c) 2014 Stefan Ceriu. All rights reserved.
//

@class DVTTextCompletionListWindowController;
@class DVTCompletingTextView;

@interface DVTTextCompletionSession : NSObject

@property(readonly, nonatomic) NSDictionary *currentCompletionContext;
@property(readonly) unsigned long long wordStartLocation;
@property(readonly) DVTTextCompletionListWindowController *listWindowController;
@property(readonly) DVTCompletingTextView *textView;

- (BOOL)insertCurrentCompletion;

@end

