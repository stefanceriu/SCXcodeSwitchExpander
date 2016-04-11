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

//@property (nonatomic, weak) IDEIndex *index;

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
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(indexDidChange:) name:@"IDEIndexDidChangeNotification" object:nil];
//		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editorDidDidFinishSetup:) name:@"IDESourceCodeEditorDidFinishSetup" object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(any:) name:nil object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(any:) name:@"IDEIndexDidIndexWorkspaceNotification" object:nil];
	}
	
	return self;
}

- (void)any:(NSNotification*)sender
{
    NSLog(@"Received: %@ %@", sender, sender.object);
//    self.index = sender.object;
}

//- (void)editorDidDidFinishSetup:(NSNotification *)sender
//{
//	IDEEditor * editor = sender.object;
//	IDEFileTextSettings *fileSettings = editor.fileTextSettings;
//	IDEFileReference *fileReference = fileSettings.fileReference;
//	
//    NSLog(@"DEBUG : File Reference = %@", fileReference);
//	NSString *fileReferenceStringBulk = [NSString stringWithFormat:@"%@",fileReference];
//	self.isSwift = [fileReferenceStringBulk rangeOfString:@".swift"].location != NSNotFound;
//}

- (void)indexDidChange:(NSNotification *)sender
{
//    NSLog(@"Index Did Change : %@", self.index);
//	self.index = sender.object;
}

- (void)indexNeedsUpdate:(IDEIndex *)index
{
//    NSLog(@"DEBUG: Update Index");
//    [[NSNotificationCenter defaultCenter] postNotificationName:SCXcodeSwitchExpanderIndexDidChangeNotification object:index];
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
