//
//  IDEWorkspace+SCXCodeSwitchExpander.m
//  SCXcodeSwitchExpander
//
//  Created by Tomohiro Kumagai on 4/9/16.
//  Copyright © 2016 Stefan Ceriu. All rights reserved.
//

#import "IDEWorkspace+SCXCodeSwitchExpander.h"
#import "SCXcodeSwitchExpander.h"
#import <objc/objc-class.h>

@implementation IDEWorkspace (SCXCodeSwitchExpander)

+ (void)load
{
    Method originalMethod = class_getInstanceMethod(self, @selector(_updateIndexableFiles:));
    Method swizzledMethod = class_getInstanceMethod(self, @selector(scSwizzled_updateIndexableFiles:));
    
    if ((originalMethod != nil) && (swizzledMethod != nil)) {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)scSwizzled_updateIndexableFiles:(id)arg1
{
    [self scSwizzled_updateIndexableFiles:arg1];
    
    NSLog(@"Update Index : %@", [self performSelector:@selector(index)]);
    [[SCXcodeSwitchExpander sharedSwitchExpander] indexNeedsUpdate: self.index];
}

@end
