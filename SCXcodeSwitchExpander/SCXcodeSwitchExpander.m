//
//  SCXcodeSwitchExpander.m
//  SCXcodeSwitchExpander
//
//  Created by Stefan Ceriu on 13/03/2014.
//  Copyright (c) 2014 Stefan Ceriu. All rights reserved.
//

#import "SCXcodeSwitchExpander.h"
#import "IDEIndex.h"

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
    }
    
	return self;
}

- (void)indexDidChange:(NSNotification *)sender
{
    self.index = sender.object;
}

@end
