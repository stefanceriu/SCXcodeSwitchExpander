//
//  SCXcodeSwitchExpander.m
//  SCXcodeSwitchExpander
//
//  Created by Stefan Ceriu on 13/03/2014.
//  Copyright (c) 2014 Stefan Ceriu. All rights reserved.
//

#import "SCXcodeSwitchExpander.h"
#import "IDEIndex.h"
#import "IDEEditor.h"
#import "IDEFileTextSettings.h"
#import "IDEWorkspace.h"

static SCXcodeSwitchExpander *sharedExpander = nil;

@interface SCXcodeSwitchExpander ()

@property (nonatomic, weak) NSDocument *editorDocument;
@property (nonatomic, assign) NSTextView *editorTextView;

/// This property is unavailable because index will be get from IDEWorkspace directly.
@property (nonatomic, weak) IDEIndex *index NS_UNAVAILABLE;

@end

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

- (id)init
{
	if (self = [super init]) {
	}
	
	return self;
}

/// Remove this method because other (not current) editor's notification may be received.
- (void)editorDidDidFinishSetup:(NSNotification *)sender NS_UNAVAILABLE
{
}

/// Remove this method because index will get from current workspace directly.
- (void)indexDidChange:(NSNotification *)sender NS_UNAVAILABLE
{
}

- (IDEWorkspace *)currentWorkspace
{
    NSWindowController *currentWindowController = [[NSApp keyWindow] windowController];
    if ([currentWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        return [currentWindowController valueForKey:@"_workspace"];
    }
    else {
        return nil;
    }
}

@end
