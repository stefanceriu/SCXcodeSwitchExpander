//
//  IDEIndexSymbol.h
//  SCXcodeSwitchExpander
//
//  Created by Stefan Ceriu on 17/03/2014.
//  Copyright (c) 2014 Stefan Ceriu. All rights reserved.
//

@class DVTSourceCodeSymbolKind;

@interface IDEIndexSymbol : NSObject

@property(readonly, nonatomic) NSString *resolution;
@property(readonly, nonatomic) NSString *name;
@property(readonly, nonatomic) DVTSourceCodeSymbolKind *symbolKind;

- (id)displayName;

@end
