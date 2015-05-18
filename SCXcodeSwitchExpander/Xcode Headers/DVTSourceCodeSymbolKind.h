//
//  DVTSourceCodeSymbolKind.h
//  SCXcodeSwitchExpander
//
//  Created by Stefan Ceriu on 13/03/2014.
//  Copyright (c) 2014 Stefan Ceriu. All rights reserved.
//

@class NSArray, NSString;

@interface DVTSourceCodeSymbolKind : NSObject <NSCopying>

@property(readonly) NSString *identifier;
@property(readonly, getter=isContainer) BOOL container;
@property(readonly) NSArray *allConformingSymbolKinds;

@end