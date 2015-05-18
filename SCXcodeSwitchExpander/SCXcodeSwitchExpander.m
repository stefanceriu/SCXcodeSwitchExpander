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

static SCXcodeSwitchExpander *sharedExpander = nil;

@interface SCXcodeSwitchExpander ()

@property (nonatomic, weak) NSDocument *editorDocument;
@property (nonatomic, assign) NSTextView *editorTextView;

@property (nonatomic, weak) IDEIndex *index;

@end

@implementation SCXcodeSwitchExpander

+ (void)pluginDidLoad:(NSBundle *)plugin
{
	[self sharedSwitchExpander];
}

+ (instancetype)sharedSwitchExpander
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedExpander = [[self alloc] init];
	});
	
	return sharedExpander;
}

- (id)init
{
	if (self = [super init]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(indexDidChange:) name:@"IDEIndexDidChangeNotification" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editorDidDidFinishSetup:) name:@"IDESourceCodeEditorDidFinishSetup" object:nil];
	}
	
	return self;
}

- (void)editorDidDidFinishSetup:(NSNotification *)sender
{
	IDEEditor * editor = sender.object;
	IDEFileTextSettings *fileSettings = editor.fileTextSettings;
	IDEFileReference *fileReference = fileSettings.fileReference;
	
	/*
	 Since I've got this on Console:<Xcode3FileReference, 0x7fcde7977580 (Represents: <PBXFileReference:0x7fcdeb1018e0:18990B3518D2529C007A8756:name='SCXcodeSwitchExpander.m'>)>
	 Yes, lazy, and I'm sorry but its 2am and importing XCode Header files is a pain in the ass :P
	 */
	NSString *fileReferenceStringBulk = [NSString stringWithFormat:@"%@",fileReference];
	
	self.isSwift = [fileReferenceStringBulk rangeOfString:@".swift"].location != NSNotFound;
}

- (void)indexDidChange:(NSNotification *)sender
{
	self.index = sender.object;
}

@end
