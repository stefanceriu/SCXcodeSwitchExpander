//
//  SCXcodeSwitchExpander.h
//  SCXcodeSwitchExpander
//
//  Created by Stefan Ceriu on 13/03/2014.
//  Copyright (c) 2014 Stefan Ceriu. All rights reserved.
//

@class IDEIndex;

@interface SCXcodeSwitchExpander : NSObject

+ (instancetype)sharedSwitchExpander;

@property (nonatomic, weak, readonly) IDEIndex *index;

@end
