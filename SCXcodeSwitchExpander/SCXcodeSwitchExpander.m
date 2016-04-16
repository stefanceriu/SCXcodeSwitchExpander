//
//  SCXcodeSwitchExpander.m
//  SCXcodeSwitchExpander
//
//  Created by Stefan Ceriu on 13/03/2014.
//  Copyright (c) 2014 Stefan Ceriu. All rights reserved.
//

#import "SCXcodeSwitchExpander.h"

static SCXcodeSwitchExpander *sharedExpander = nil;

@implementation SCXcodeSwitchExpander

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    BOOL isApplicationXcode = [[[NSBundle mainBundle] infoDictionary][@"CFBundleName"] isEqual:@"Xcode"];
    if (isApplicationXcode) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedExpander = [[self alloc] init];
        });
    }
}

+ (instancetype)sharedSwitchExpander
{
    return sharedExpander;
}

@end
