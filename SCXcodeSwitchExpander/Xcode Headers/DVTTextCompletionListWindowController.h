//
//  DVTTextCompletionListWindowController.h
//  SCXcodeSwitchExpander
//
//  Created by Stefan Ceriu on 13/03/2014.
//  Copyright (c) 2014 Stefan Ceriu. All rights reserved.
//

@interface DVTTextCompletionListWindowController : NSWindowController

@property(readonly) DVTTextCompletionSession *session;

- (id)_selectedCompletionItem;

@end

