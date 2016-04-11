//
//  DVTSourceCodeLanguage.h
//  SCXcodeSwitchExpander
//
//  Created by Tomohiro Kumagai on 4/11/16.
//  Copyright © 2016 Stefan Ceriu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DVTSourceCodeLanguage : NSObject <NSCopying>

@property(readonly, copy) NSString *languageName;

- (BOOL)conformsToLanguage:(id)arg1;

@end
