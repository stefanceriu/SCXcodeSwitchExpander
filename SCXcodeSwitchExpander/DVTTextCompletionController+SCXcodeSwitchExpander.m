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

- (BOOL)tryExpandingSwitchStatement;

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
	if([self.currentSession.listWindowController tryExpandingSwitchStatement]) {
		return YES;
	}
	
	return [self scSwizzledAcceptCurrentCompletion];
}

@end

@implementation DVTTextCompletionListWindowController (SCXcodeSwitchExpander)

- (BOOL)tryExpandingSwitchStatement
{
    IDEIndex *index = [[SCXcodeSwitchExpander sharedSwitchExpander] index];
    
    if(index == nil) {
        return NO;
    }
    
    IDEIndexCompletionItem *item = [self _selectedCompletionItem];
    
    // Fetch all symbols matching the autocomplete item type
	NSString *symbolName = (item.displayType.length ? item.displayType : item.displayText);
	symbolName = [[symbolName componentsSeparatedByString:@"::"] lastObject]; // Remove C++ namespaces
	symbolName = [[symbolName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lastObject]; // Remove enum keyword

	IDEIndexCollection *collection = [index allSymbolsMatchingName:symbolName kind:nil];
	
    // Find the first one of them that is a container
    for(IDEIndexSymbol *symbol in collection.allObjects) {
        
        DVTSourceCodeSymbolKind *symbolKind = symbol.symbolKind;
		
        BOOL isSymbolKindEnum = NO;
        for(DVTSourceCodeSymbolKind  *conformingSymbol in symbolKind.allConformingSymbolKinds) {
            isSymbolKindEnum = [self isSymbolKindEnum:conformingSymbol];
        }
        
        if (!isSymbolKindEnum) {
			return NO;
        }
        
        if(symbolKind.isContainer) {
            
            DVTSourceTextView *textView = (DVTSourceTextView *)self.session.textView;
            if(self.session.wordStartLocation == NSNotFound) {
                return NO;
            }
            
            // Fetch the previous new line
            NSRange newLineRange = [textView.string rangeOfString:@"\n" options:NSBackwardsSearch range:NSMakeRange(0, self.session.wordStartLocation)];
            if(newLineRange.location == NSNotFound) {
                return NO;
            }
            
            // See if the current line has a switch statement
            NSRange switchRange = [textView.string rangeOfString:@"\\s+switch\\s*\\\(" options:NSRegularExpressionSearch range:NSMakeRange(newLineRange.location, self.session.wordStartLocation - newLineRange.location)];
            if(switchRange.location == NSNotFound) {
                return NO;
            }
			
            // Fetch the opening bracket for that switch statement
            NSUInteger openingBracketLocation = [textView.string rangeOfString:@"{" options:0 range:NSMakeRange(self.session.wordStartLocation, textView.string.length - self.session.wordStartLocation)].location;
			if(openingBracketLocation == NSNotFound) {
                return NO;
            }
			
			// Insert the selected autocomplete item
			[self.session insertCurrentCompletion];
			
			NSRange selectedRange = textView.selectedRange;
			
            // Fetch the closing bracket for that switch statement
			NSUInteger closingBracketLocation = [self matchingBracketLocationForOpeningBracketLocation:openingBracketLocation
																							  inString:textView.string];
            if(closingBracketLocation == NSNotFound) {
                return NO;
            }
			
            NSRange defaultAutocompletionRange;
            // Get rid of the default autocompletion if necessary
            if ([[SCXcodeSwitchExpander sharedSwitchExpander] isSwift]) {
                defaultAutocompletionRange = [textView.string rangeOfString:@"\\s*case .<#constant#>:\\s*<#statements#>\\s*break\\s*default:\\s*break\\s*" options:NSRegularExpressionSearch range:NSMakeRange(openingBracketLocation, closingBracketLocation - openingBracketLocation)];
            } else {
                defaultAutocompletionRange = [textView.string rangeOfString:@"\\s*case <#constant#>:\\s*<#statements#>\\s*break;\\s*default:\\s*break;\\s*" options:NSRegularExpressionSearch range:NSMakeRange(openingBracketLocation, closingBracketLocation - openingBracketLocation)];
            }
			
            if(defaultAutocompletionRange.location != NSNotFound) {
                [textView insertText:@"" replacementRange:defaultAutocompletionRange];
				closingBracketLocation -= defaultAutocompletionRange.length;
            }
			
			NSRange switchContentRange = NSMakeRange(openingBracketLocation + 1, closingBracketLocation - openingBracketLocation - 1);
			NSString *switchContent = [textView.string substringWithRange:switchContentRange];
			
            // Generate the items to insert and insert them at the end
            NSMutableString *replacementString = [NSMutableString string];
			
			if([switchContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
				[replacementString appendString:@"\n"];
			}
			
            for(IDEIndexSymbol *child in [((IDEIndexContainerSymbol*)symbol).children allObjects]) {
                if([switchContent rangeOfString:child.displayName].location == NSNotFound) {
                    if ([[SCXcodeSwitchExpander sharedSwitchExpander] isSwift]) {
                        NSString *childDisplayName = [self correctEnumConstantIfFromCocoa:[NSString stringWithFormat:@"%@",symbol] symbolName:symbolName cocoaEnumName:child.displayName];
                        [replacementString appendString:[NSString stringWithFormat:@"case .%@: \n<#statement#>\nbreak\n\n", childDisplayName]];
                    } else {
                        [replacementString appendString:[NSString stringWithFormat:@"case %@: {\n<#statement#>\nbreak;\n}\n", child.displayName]];
                    }
                }
            }
			
            [textView insertText:replacementString replacementRange:NSMakeRange(switchContentRange.location + switchContentRange.length, 0)];
			
			closingBracketLocation += replacementString.length;
			switchContentRange = NSMakeRange(openingBracketLocation + 1, closingBracketLocation - openingBracketLocation - 1);
			switchContent = [textView.string substringWithRange:switchContentRange];
			
            // Insert the default case if necessary
            if([switchContent rangeOfString:@"default"].location == NSNotFound) {
                if ([[SCXcodeSwitchExpander sharedSwitchExpander] isSwift]) {
                    replacementString = [NSMutableString stringWithString:@"default: \nbreak\n\n"];
                } else {
                    replacementString = [NSMutableString stringWithString:@"default: {\nbreak;\n}\n"];
                }
                [textView insertText:replacementString replacementRange:NSMakeRange(switchContentRange.location + switchContentRange.length, 0)];
                closingBracketLocation += replacementString.length;
            }
            // Re-indent everything
			NSRange reindentRange = NSMakeRange(openingBracketLocation, closingBracketLocation - openingBracketLocation + 2);
            [textView _indentInsertedTextIfNecessaryAtRange:reindentRange];
			
			// Preserve the selected range
			[textView setSelectedRange:selectedRange];
			
			return YES;
        }
        
        break;
    }
	
	return NO;
}

- (NSString *)correctEnumConstantIfFromCocoa:(NSString *)symbol symbolName:(NSString *)symbolName cocoaEnumName:(NSString *)enumName
{
	if ([symbol rangeOfString:@"c:@E@"].location != NSNotFound) {
		return [enumName stringByReplacingOccurrencesOfString:symbolName withString:@""];
	}
	
	return enumName;
}

- (BOOL)isSymbolKindEnum:(DVTSourceCodeSymbolKind *)symbol
{
	return [symbol.identifier isEqualToString:@"Xcode.SourceCodeSymbolKind.Enum"];
}

- (NSUInteger)matchingBracketLocationForOpeningBracketLocation:(NSUInteger)location inString:(NSString *)string
{
	if(string.length == 0) {
		return NSNotFound;
	}
    
    NSInteger matchingLocation = location;
    NSInteger counter = 1;
    while (counter > 0) {
        matchingLocation ++;
        
        if(matchingLocation == string.length - 1) {
            return NSNotFound;
        }
        
        NSString *character = [string substringWithRange:NSMakeRange(matchingLocation, 1)];
        
		if ([character isEqualToString:@"{"]) {
            counter++;
        }
        else if ([character isEqualToString:@"}"]) {
            counter--;
        }
    }
    
    return matchingLocation;
}

@end
