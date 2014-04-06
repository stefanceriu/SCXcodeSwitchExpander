//
//  IDEIndexCompletionItem.h
//  SCXcodeSwitchExpander
//
//  Created by Stefan Ceriu on 17/03/2014.
//  Copyright (c) 2014 Stefan Ceriu. All rights reserved.
//

@class DVTSourceCodeSymbolKind;

@interface IDEIndexCompletionItem : NSObject

@property(readonly) NSString *name;
@property(readonly) DVTSourceCodeSymbolKind *symbolKind;
@property(readonly) NSString *displayType;
@property(readonly) NSString *displayText;

@end
