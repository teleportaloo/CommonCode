//
//  NSString+Convenience.m
//  Automata
//
//  Created by Andy Wallace on 7/6/25.
//

// Copyright 2025 Andrew Wallace
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "DebugLogging.h"
#import "NSString+Convenience.h"
#import "TaskDispatch.h"

#define DEBUG_LEVEL_FOR_FILE LogMarkup

@implementation NSString (Convenience)

- (unichar)firstUnichar {
    if (self.length > 0) {
        // This used to be called firstCharacter but when that is called it
        // fails after creating a UIDocumentInteractionController.  Super weird.
        return [self characterAtIndex:0];
    }

    return 0;
}

- (unichar)lastUnichar {
    if (self.length > 0) {
        // This used to be called firstCharacter but when that is called it
        // fails after creating a UIDocumentInteractionController.  Super weird.
        return [self characterAtIndex:self.length - 1];
    }

    return 0;
}

- (NSMutableAttributedString *)mutableAttributedString {
    return [[NSMutableAttributedString alloc] initWithString:self];
}

- (NSString *)stringByTrimmingWhitespace {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)stringWithTrailingSpaceIfNeeded {
    if (self.length == 0) {
        return self;
    }

    return [self stringByAppendingString:@" "];
}

+ (NSMutableString *)textSeparatedStringFromEnumerator:(id<NSFastEnumeration>)container
                                              selector:(SEL)selector
                                             separator:(NSString *)separator {
    NSMutableString *string = [NSMutableString string];

    static Class stringClass;

    DO_ONCE(^{
      stringClass = [NSString class];
    });

    for (NSObject *obj in container) {
        if ([obj respondsToSelector:selector]) {
            IMP imp = [obj methodForSelector:selector];
            NSObject *(*func)(id, SEL) = (void *)imp;

            NSObject *item = func(obj, selector);

            // NSObject *item = [obj performSelector:selector];
            if (item != nil) {
                if ([item isKindOfClass:stringClass]) {
                    if (string.length > 0) {
                        [string appendString:separator];
                    }

                    [string appendString:(NSString *)item];
                } else {
                    ERROR_LOG(@"commaSeparatedStringFromEnumerator - selector "
                              @"did not return string %@\n",
                              NSStringFromSelector(selector));
                }
            }
        } else {
            ERROR_LOG(@"commaSeparatedStringFromEnumerator - item does not "
                      @"respond to selector %@\n",
                      NSStringFromSelector(selector));
        }
    }

    return string;
}

+ (NSMutableString *)commaSeparatedStringFromStringEnumerator:(id<NSFastEnumeration>)container;
{
    return [NSString textSeparatedStringFromEnumerator:container
                                              selector:@selector(self)
                                             separator:@","];
}

+ (NSMutableString *)commaSeparatedStringFromEnumerator:(id<NSFastEnumeration>)container
                                               selector:(SEL)selector;
{ return [NSString textSeparatedStringFromEnumerator:container selector:selector separator:@","]; }

- (NSMutableArray<NSString *> *)mutableArrayFromCommaSeparatedString {
    NSCharacterSet *comma = [NSCharacterSet characterSetWithCharactersInString:@","];
    NSMutableArray<NSString *> *array = [NSMutableArray array];
    NSScanner *scanner = [NSScanner scannerWithString:self];
    NSString *item;

    while ([scanner scanUpToCharactersFromSet:comma intoString:&item]) {
        [array addObject:item];

        if (!scanner.atEnd) {
            scanner.scanLocation++;
        }
    }
    return array;
}

- (NSString *)percentEncodeUrl {
    return
        [self stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet
                                                                     .URLPathAllowedCharacterSet];
}

- (NSString *)fullyPercentEncodeString {
    return [self
        stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.alphanumericCharacterSet];
}

- (bool)hasCaseInsensitiveSubstring:(NSString *)search {
    return [self rangeOfString:search options:NSCaseInsensitiveSearch].location != NSNotFound;
}

- (NSString *)justNumbers {
    NSMutableString *res = [NSMutableString string];

    int i = 0;
    unichar c;

    for (i = 0; i < self.length; i++) {
        c = [self characterAtIndex:i];

        if (isnumber(c)) {
            [res appendFormat:@"%C", c];
        }
    }
    return res;
}

- (NSAttributedString *)attributedString {
    return [[NSAttributedString alloc] initWithString:self];
}

- (NSAttributedString *)attributedStringWithAttributes:
    (nullable NSDictionary<NSAttributedStringKey, id> *)attrs {
    return [[NSAttributedString alloc] initWithString:self attributes:attrs];
}

- (NSString *)removeSingleLineBreaks {
    // Replace single line breaks
    NSRegularExpression *regex =
        [NSRegularExpression regularExpressionWithPattern:@"(?<!\n)\n(?!\n)" options:0 error:NULL];
    return [regex stringByReplacingMatchesInString:self
                                           options:0
                                             range:NSMakeRange(0, self.length)
                                      withTemplate:@" "];
}

@end
