//
//  DVTSourceCodeLanguage+SCXCodeSwitchExpander.h
//  SCXcodeSwitchExpander
//
//  Created by Tomohiro Kumagai on 4/11/16.
//  Copyright © 2016 Stefan Ceriu. All rights reserved.
//

#import "DVTSourceCodeLanguage.h"

typedef NS_ENUM(NSInteger, DVTSourceCodeLanguageKind)
{
    DVTSourceCodeLanguageKindObjectiveC,
    DVTSourceCodeLanguageKindSwift,
    DVTSourceCodeLanguageKindOthers
};

@interface DVTSourceCodeLanguage (SCXCodeSwitchExpander)

/// Returns a kind of language which this instance means.
@property (readonly) DVTSourceCodeLanguageKind kind;

@end
