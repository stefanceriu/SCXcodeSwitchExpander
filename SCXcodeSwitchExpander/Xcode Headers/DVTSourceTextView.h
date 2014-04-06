//
//  DVTSourceTextView.h
//  SCXcodeSwitchExpander
//
//  Created by Stefan Ceriu on 13/03/2014.
//  Copyright (c) 2014 Stefan Ceriu. All rights reserved.
//

#import "DVTCompletingTextView.h"

@interface DVTSourceTextView : DVTCompletingTextView

- (struct _NSRange)_indentInsertedTextIfNecessaryAtRange:(struct _NSRange)arg1;

@end

