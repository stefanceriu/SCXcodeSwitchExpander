//
//  DVTTextStorage.h
//  SCXcodeSwitchExpander
//
//  Created by Tomohiro Kumagai on 4/11/16.
//  Copyright © 2016 Stefan Ceriu. All rights reserved.
//

#import <AppKit/AppKit.h>

@class DVTSourceCodeLanguage;

@interface DVTTextStorage : NSTextStorage

@property(copy) DVTSourceCodeLanguage *language;

@end
