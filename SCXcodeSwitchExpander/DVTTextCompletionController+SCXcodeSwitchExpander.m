//
//  DVTTextCompletionController+SCXcodeSwitchExpander.m
//  SCXcodeSwitchExpander
//
//  Created by Stefan Ceriu on 13/03/2014.
//  Copyright (c) 2014 Stefan Ceriu. All rights reserved.
//

#import "DVTTextCompletionController+SCXcodeSwitchExpander.h"

#import "SCXcodeSwitchExpander.h"

#import "DVTSourceCodeLanguage+SCXcodeSwitchExpander.h"
#import "DVTSourceTextView.h"
#import "DVTTextStorage.h"

#import "IDEIndex.h"
#import "IDEIndexCollection.h"
#import "IDEIndexCompletionItem.h"
#import "IDEIndexContainerSymbol.h"
#import "IDEWorkspace.h"
#import "DVTSourceCodeSymbolKind.h"
#import "DVTSourceTextView.h"

#import "DVTTextCompletionSession+SCXcodeSwitchExpander.h"

#import <objc/objc-class.h>

@interface DVTTextCompletionListWindowController (SCXcodeSwitchExpander)

- (BOOL)tryExpandingSwitchStatementForLanguage:(DVTSourceCodeLanguageKind)language;

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
    if([self.currentSession.listWindowController tryExpandingSwitchStatementForLanguage:self.currentLanguage]) {
		return YES;
	}
	
	return [self scSwizzledAcceptCurrentCompletion];
}

- (DVTSourceCodeLanguageKind)currentLanguage
{
    DVTSourceTextView *textView = (DVTSourceTextView *)self.textView;
    DVTTextStorage *textStorage = (DVTTextStorage *)textView.textStorage;
    DVTSourceCodeLanguage *language = textStorage.language;

    return language.switchExpander_sourceCodeLanguageKind;
}

@end

@implementation DVTTextCompletionListWindowController (SCXcodeSwitchExpander)

- (BOOL)tryExpandingSwitchStatementForLanguage:(DVTSourceCodeLanguageKind)language
{
    IDEWorkspace *workspace = self.session.switchExpander_currentWorkspace;
    IDEIndex *index = workspace.index;
    
    if(index == nil) {
        return NO;
    }
    
    IDEIndexCompletionItem *item = [self _selectedCompletionItem];
    
    // Fetch all symbols matching the autocomplete item type
	NSString *symbolName = (item.displayType.length ? item.displayType : item.displayText);
    
    // Remove C++ namespaces
	symbolName = [[symbolName componentsSeparatedByString:@"::"] lastObject];
    
    // Remove enum keyword
	symbolName = [symbolName stringByReplacingOccurrencesOfString:@"^enum\\s+" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, symbolName.length)];
    
    // Remove Swift tuple (e.g. `(SomeClass.Result<T, E>)` to `SomeClass.Result<T, E>`). This occurs at the closure passed only single enum argument.
    symbolName = [symbolName stringByReplacingOccurrencesOfString:@"^\\((.*)\\)$" withString:@"$1" options:NSRegularExpressionSearch range: NSMakeRange(0, symbolName.length)];

    NSArray<IDEIndexSymbol*> *symbols = [self _getSymbolsByFullName:symbolName forLanguage:language fromIndex:index];
	
    // Find the first one of them that is a container
    for(IDEIndexSymbol *symbol in symbols) {
        
        DVTSourceCodeSymbolKind *symbolKind = symbol.symbolKind;
		
        BOOL isSymbolKindEnum = NO;
        for(DVTSourceCodeSymbolKind  *conformingSymbol in symbolKind.allConformingSymbolKinds) {
            isSymbolKindEnum = [self _isSymbolKindEnum:conformingSymbol];
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
            NSString *regPattern;
            switch (language) {
                case DVTSourceCodeLanguageKindObjectiveC:
                case DVTSourceCodeLanguageKindOther: {
                    regPattern = @"\\s+switch\\s*\\\(";
                    break;
                }
                case DVTSourceCodeLanguageKindSwift: {
                    regPattern = @"\\s+switch\\s*";
                    break;
                }
            }

            NSRange switchRange = [textView.string rangeOfString:regPattern options:NSRegularExpressionSearch range:NSMakeRange(newLineRange.location, self.session.wordStartLocation - newLineRange.location)];
            if(switchRange.location == NSNotFound) {
                return NO;
            }
            
            // Insert the selected autocomplete item
            [self.session insertCurrentCompletion];
			
            // Fetch the opening bracket for that switch statement
            NSUInteger openingBracketLocation = [textView.string rangeOfString:@"{" options:0 range:NSMakeRange(self.session.wordStartLocation, textView.string.length - self.session.wordStartLocation)].location;
			if(openingBracketLocation == NSNotFound) {
                return NO;
            }
			
			// Check if it's the opening bracket for the switch statement or something else
			NSString *remainingText = [textView.string substringWithRange:NSMakeRange(switchRange.location + switchRange.length, openingBracketLocation - switchRange.location - switchRange.length)];
			if([remainingText rangeOfString:@"}"].location != NSNotFound) {
				return NO;
			}
			
			NSRange selectedRange = textView.selectedRange;
			
            // Fetch the closing bracket for that switch statement
			NSUInteger closingBracketLocation = [self matchingBracketLocationForOpeningBracketLocation:openingBracketLocation inString:textView.string];
            if(closingBracketLocation == NSNotFound) {
                return NO;
            }
			
            NSRange defaultAutocompletionRange;
            // Get rid of the default autocompletion if necessary
            switch (language) {
                case DVTSourceCodeLanguageKindSwift: {
                    defaultAutocompletionRange = [textView.string rangeOfString:@"\\s*case .<#constant#>:\\s*<#statements#>\\s*break\\s*default:\\s*break\\s*" options:NSRegularExpressionSearch range:NSMakeRange(openingBracketLocation, closingBracketLocation - openingBracketLocation)];
                    break;
                }
                case DVTSourceCodeLanguageKindObjectiveC:
                case DVTSourceCodeLanguageKindOther: {
                    defaultAutocompletionRange = [textView.string rangeOfString:@"\\s*case <#constant#>:\\s*<#statements#>\\s*break;\\s*default:\\s*break;\\s*" options:NSRegularExpressionSearch range:NSMakeRange(openingBracketLocation, closingBracketLocation - openingBracketLocation)];
                    break;
                }
            }
			
            if(defaultAutocompletionRange.location != NSNotFound) {
                [textView insertText:@"" replacementRange:defaultAutocompletionRange];
				closingBracketLocation -= defaultAutocompletionRange.length;
            }
			
			NSRange switchContentRange = NSMakeRange(openingBracketLocation + 1, closingBracketLocation - openingBracketLocation - 1);
			NSString *switchContent = [textView.string substringWithRange:switchContentRange];
			
            // Generate the items to insert and insert them at the end
            NSMutableString *replacementString = [NSMutableString string];
			
			NSString *trimmedContent = [switchContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

			if(trimmedContent.length == 0) {
				// Remove extraneous empty lines if existing content is only whitespace
				if (switchContent.length > 0) {
					[textView insertText:@"" replacementRange:switchContentRange];
					closingBracketLocation -= switchContent.length;
					switchContentRange.length = 0;
					[replacementString appendString:@"\n"];
				} else {
					// Keep Swift code compact
					if (language != DVTSourceCodeLanguageKindSwift) {
						[replacementString appendString:@"\n"];
					}
				}
			}
			
            for(IDEIndexSymbol *child in [((IDEIndexContainerSymbol*)symbol).children allObjects]) {

                // Skip the `child` symbol if it is not a enum constant.
                if (![self _isSymbolKindEnumConstant:child.symbolKind])
                {
                    continue;
                }
                
                if([switchContent rangeOfString:child.displayName].location == NSNotFound) {
                    switch (language) {
                        case DVTSourceCodeLanguageKindSwift: {
                            NSString *childDisplayName = [self _correctEnumConstantIfFromCocoa:[NSString stringWithFormat:@"%@",symbol] symbolName:symbolName cocoaEnumName:child.displayName];
                            [replacementString appendString:[NSString stringWithFormat:@"case .%@: \n<#statement#>\n", childDisplayName]];
                            break;
                        }
                        case DVTSourceCodeLanguageKindObjectiveC:
                        case DVTSourceCodeLanguageKindOther: {
                            [replacementString appendString:[NSString stringWithFormat:@"case %@: {\n<#statement#>\nbreak;\n}\n", child.displayName]];
                            break;
                        }
                    }
                }
            }
			
            [textView insertText:replacementString replacementRange:NSMakeRange(switchContentRange.location + switchContentRange.length, 0)];
			
			closingBracketLocation += replacementString.length;
			switchContentRange = NSMakeRange(openingBracketLocation + 1, closingBracketLocation - openingBracketLocation - 1);
			switchContent = [textView.string substringWithRange:switchContentRange];
			
//          // Insert the default case if necessary
//          if([switchContent rangeOfString:@"default"].location == NSNotFound) {
//              if ([[SCXcodeSwitchExpander sharedSwitchExpander] isSwift]) {
//                  replacementString = [NSMutableString stringWithString:@"default: \nbreak\n\n"];
//              } else {
//                  replacementString = [NSMutableString stringWithString:@"default: {\nbreak;\n}\n"];
//              }
//              [textView insertText:replacementString replacementRange:NSMakeRange(switchContentRange.location + switchContentRange.length, 0)];
//              closingBracketLocation += replacementString.length;
//          }
            
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

#pragma mark - Private helpers

- (NSString *)_correctEnumConstantIfFromCocoa:(NSString *)symbol symbolName:(NSString *)symbolName cocoaEnumName:(NSString *)enumName
{
	if ([symbol rangeOfString:@"c:@E@"].location != NSNotFound) {
		return [enumName stringByReplacingOccurrencesOfString:symbolName withString:@""];
	}
	
	return enumName;
}

/// Returns a boolean value whether `symbolKind` means a enum type.
- (BOOL)_isSymbolKindEnum:(DVTSourceCodeSymbolKind *)symbol
{
	return [symbol.identifier isEqualToString:@"Xcode.SourceCodeSymbolKind.Enum"];
}

/// Returns a boolean value whether `symbolKind` means a enum constant.
- (BOOL)_isSymbolKindEnumConstant:(DVTSourceCodeSymbolKind *)symbolKind
{
    return [symbolKind.identifier isEqualToString:@"Xcode.SourceCodeSymbolKind.EnumConstant"];
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

- (NSArray<IDEIndexSymbol*>*)_getSymbolsByFullName:(NSString*)fullSymbolName forLanguage:(DVTSourceCodeLanguageKind)language fromIndex:(IDEIndex*)index
{
    NSArray<NSString*> *names = [self _symbolNamesFromFullSymbolName:fullSymbolName forLanguage:language];
    NSString *lastName = names.lastObject;
    
    NSArray<IDEIndexSymbol*> *symbols = [[index allSymbolsMatchingName:lastName kind:nil] allObjects];
    NSIndexSet *enumSymbolIndexes = [symbols indexesOfObjectsPassingTest:^BOOL(IDEIndexSymbol *symbol, NSUInteger idx, BOOL *stop) {
        return [self _isSymbolKindEnum:symbol.symbolKind];
    }];
    NSArray<IDEIndexSymbol*> *enumSymbols = [symbols objectsAtIndexes:enumSymbolIndexes];
    
    for (NSInteger nameIndex = names.count - 2; nameIndex != -1; --nameIndex) {
        if (enumSymbols.count <= 1) {
            break;
        }
        
        NSString *currentName = [names objectAtIndex:nameIndex];
        NSArray<IDEIndexSymbol*> *currentSymbols = [[index allSymbolsMatchingName:currentName kind:nil] allObjects];
        
        NSIndexSet *validEnumSymbolIndexes = [enumSymbols indexesOfObjectsPassingTest:^BOOL(IDEIndexSymbol *enumSymbol, NSUInteger idx, BOOL *stop) {
            NSString *enumSymbolNamespace = [self _namespaceForResolutionOfSymbol:enumSymbol];
            for (IDEIndexSymbol *currentSymbol in currentSymbols) {
                NSString *currentSymbolNamespace = [self _namespaceForResolutionOfSymbol:currentSymbol];
                if ([enumSymbolNamespace hasPrefix:currentSymbolNamespace]) {
                    return YES;
                }
            }
            return NO;
        }];
        
        enumSymbols = [enumSymbols objectsAtIndexes:validEnumSymbolIndexes];
    }
    
    return enumSymbols;
}

/// Returns namespace name by symbol's resolution.
- (NSString *)_namespaceForResolutionOfSymbol:(IDEIndexSymbol *)symbol
{
    NSString *resolution = symbol.resolution;
    return [resolution stringByReplacingOccurrencesOfString:@"^s:\\w+16" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, resolution.length)];
}

/// Returns symbol names from swift style full symbol name (e.g. from `Mirror.DisplayStyle` to `[Mirror, DisplayStyle]`).
- (NSArray<NSString*>*)_symbolNamesFromFullSymbolName:(NSString *)fullSymbolName forLanguage:(DVTSourceCodeLanguageKind)language
{
    NSMutableArray<NSString*> *names = [[fullSymbolName componentsSeparatedByString:@"."] mutableCopy];
    for (NSInteger nameIndex = 0; nameIndex != names.count; ++nameIndex) {
        names[nameIndex] = [self _normalizedSymbolName:names[nameIndex] forLanguage:language];
    }
    
    return [names copy];
}

/// Returns normalized symbol name for -[IDEIndex allSymbolsMatchingName:kind:].
- (NSString *)_normalizedSymbolName:(NSString *)symbolName forLanguage:(DVTSourceCodeLanguageKind)language
{
    NSString *result = symbolName;
    result = [self _symbolNameByRemovingGenericParameter:result forLanguage:language];
    result = [self _symbolNameByReplacingOptionalName:result forLanguage:language];
    
    return result;
}

/// Returns a symbol name removed swift generic parameter (e.g. `SomeType<T>` to `SomeType`).
- (NSString *)_symbolNameByRemovingGenericParameter:(NSString *)symbolName forLanguage:(DVTSourceCodeLanguageKind)language
{
    switch (language) {
        case DVTSourceCodeLanguageKindSwift: {
            return [symbolName stringByReplacingOccurrencesOfString:@"<[^>]+>$"
                                                         withString:@""
                                                            options:NSRegularExpressionSearch
                                                              range:NSMakeRange(0, symbolName.length)];
        }
        case DVTSourceCodeLanguageKindObjectiveC:
        case DVTSourceCodeLanguageKindOther: {
            return symbolName;
        }
    }
}

/// Returns a symbol name replaced syntax suggered optional to formal type name type in Swift (e.g. `Int?` to `Optional).
- (NSString *)_symbolNameByReplacingOptionalName:(NSString *)symbolName forLanguage:(DVTSourceCodeLanguageKind)language
{
    switch (language) {
        case DVTSourceCodeLanguageKindSwift: {
            if ([symbolName hasSuffix:@"?"]) {
                return @"Optional";
            }
            else if ([symbolName hasSuffix:@"!"]) {
                return @"ImplicitlyUnwrappedOptional";
            }
            else {
                return symbolName;
            }
        }
        case DVTSourceCodeLanguageKindObjectiveC:
        case DVTSourceCodeLanguageKindOther: {
            return symbolName;
        }
    }
}

@end
