//
//  DVTTextCompletionController+SCXcodeSwitchExpander.m
//  SCXcodeSwitchExpander
//
//  Created by Stefan Ceriu on 13/03/2014.
//  Copyright (c) 2014 Stefan Ceriu. All rights reserved.
//

#import "DVTTextCompletionController+SCXcodeSwitchExpander.h"

#import "SCXcodeSwitchExpander.h"

#import "DVTSourceTextView.h"

#import "IDEIndex.h"
#import "IDEIndexCollection.h"
#import "IDEIndexCompletionItem.h"
#import "IDEIndexContainerSymbol.h"
#import "DVTSourceCodeSymbolKind.h"

#import "DVTTextCompletionSession.h"

#import <objc/objc-class.h>

@interface DVTTextCompletionListWindowController (SCXcodeSwitchExpander)

- (void)tryExpandingSwitchStatement;

@end

@implementation DVTTextCompletionController (SCXcodeSwitchExpander)

+ (void)load
{
    Method originalMethod = class_getInstanceMethod(self, @selector(acceptCurrentCompletion));
    Method swizzledMethod = class_getInstanceMethod(self, @selector(scSwizzledAcceptCurrentCompletion));
    
    if ((originalMethod != nil) && (swizzledMethod != nil)) {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (BOOL)scSwizzledAcceptCurrentCompletion
{
    [self.currentSession.listWindowController tryExpandingSwitchStatement];
    return [self scSwizzledAcceptCurrentCompletion];
}

@end

@implementation DVTTextCompletionListWindowController (SCXcodeSwitchExpander)

- (void)tryExpandingSwitchStatement
{
    IDEIndex *index = [[SCXcodeSwitchExpander sharedSwitchExpander] index];
    
    if(index == nil) {
        return;
    }
    
    IDEIndexCompletionItem *item = [self _selectedCompletionItem];
    
    // Fetch all symbols matching the autocomplete item type
    IDEIndexCollection *collection = [index allSymbolsMatchingName:item.displayType kind:nil];
    
    // Find the first one of them that is a container
    for(IDEIndexSymbol *symbol in collection.allObjects) {
        
        DVTSourceCodeSymbolKind *symbolKind = symbol.symbolKind;
        
        if(symbolKind.isContainer) {
            
            DVTSourceTextView *textView = (DVTSourceTextView *)self.session.textView;
            if(self.session.wordStartLocation == NSNotFound) {
                return;
            }
            
            // Fetch the previous new line
            NSRange newLineRange = [textView.string rangeOfString:@"\n" options:NSBackwardsSearch range:NSMakeRange(0, self.session.wordStartLocation)];
            if(newLineRange.location == NSNotFound) {
                return;
            }
            
            // See if the current line has a switch statement
            NSRange switchRange = [textView.string rangeOfString:@"\\s+switch\\s*\\\(" options:NSRegularExpressionSearch range:NSMakeRange(newLineRange.location, self.session.wordStartLocation - newLineRange.location)];
            if(switchRange.location == NSNotFound) {
                return;
            }
            
            // Insert the selected autocomplete item
            [self.session insertCurrentCompletion];
            
            // Fetch the opening bracket for that switch statement
            NSRange openingBracketRange = [textView.string rangeOfString:@"{" options:0 range:NSMakeRange(self.session.wordStartLocation, textView.string.length - self.session.wordStartLocation)];
            if(openingBracketRange.location == NSNotFound) {
                return;
            }
            
            // Fetch the closing bracket for that switch statement
            NSUInteger closingBracketLocation = [self matchingBracketLocationForOpeningBracketLocation:openingBracketRange.location inString:self.session.textView.string];
            if(closingBracketLocation == NSNotFound) {
                return;
            }
            
            NSString *switchStatementContents = [self.session.textView.string substringWithRange:NSMakeRange(openingBracketRange.location, closingBracketLocation - openingBracketRange.location)];
            
            // Get rid of the default autocompletion if necessary
            NSRange defaultAutocompletionRange = [self.session.textView.string rangeOfString:@"\\s*case <#constant#>:\\s*<#statements#>\\s*break;" options:NSRegularExpressionSearch];
            
            if(defaultAutocompletionRange.location != NSNotFound) {
                // remove it from the switch
                [textView insertText:@"" replacementRange:defaultAutocompletionRange];
            }
            
            // Generate the items to insert
            NSMutableString *replacementString = [NSMutableString string];
            for(IDEIndexSymbol *child in [((IDEIndexContainerSymbol*)symbol).children allObjects]) {
                
                if([switchStatementContents rangeOfString:child.displayName].location == NSNotFound)
                {
                    [replacementString appendString:[NSString stringWithFormat:@"\ncase %@:\n<#statement#>\nbreak;", child.displayName]];
                }
            }
        
            // Insert the generated items
            [textView insertText:replacementString replacementRange:NSMakeRange(openingBracketRange.location + 1, 1)];
            
            // Re-indent everything
            [textView _indentInsertedTextIfNecessaryAtRange:NSMakeRange(openingBracketRange.location + 1, replacementString.length)];
        }
        
        break;
    }
}

- (NSUInteger)matchingBracketLocationForOpeningBracketLocation:(NSUInteger)location inString:(NSString *)string
{
    const char *cString = [self.session.textView.string cStringUsingEncoding:NSUTF8StringEncoding];
    
    NSInteger matchingLocation = location;
    NSInteger counter = 1;
    while (counter > 0) {
        matchingLocation ++;
        
        if(matchingLocation == string.length - 1) {
            return NSNotFound;
        }
        
        char character = cString[matchingLocation];
        
        if (character == '{') {
            counter++;
        }
        else if (character == '}') {
            counter--;
        }
    }
    
    return matchingLocation;
}

@end
