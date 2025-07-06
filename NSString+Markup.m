//
//  StringHelper.m
//  PDXBusCore
//
//  Created by Andrew Wallace on 11/7/15.
//  Copyright © 2015 Andrew Wallace
//

// Copyright 2015 Andrew Wallace
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

#define DEBUG_LEVEL_FOR_FILE LogMarkup

#import "DebugLogging.h"
#import "NSString+Markup.h"
#import "UIColor+HTML.h"

#define IOS_DARK_MODE                                                          \
    ([UIScreen mainScreen].traitCollection.userInterfaceStyle ==               \
     UIUserInterfaceStyleDark)

static NSString *markupEscape = @"#";
static NSString *newl = @"\n";

@interface UIColor (DarkMode)

+ (UIColor *)modeAwareText;
+ (UIColor *)modeAwareBlue;

@end

@implementation UIColor (DarkMode)

+ (UIColor *)modeAwareText {
    if (@available(iOS 13.0, *)) {
        return [UIColor labelColor];
    }
    return [UIColor blackColor];
}

+ (UIColor *)modeAwareBlue {
    if (@available(iOS 13.0, *)) {
        if (IOS_DARK_MODE) {
            // These colors are based in the "information icon" (i) color
            return [UIColor colorWithHTMLColor:0x0099FF];
        }
    }
    return [UIColor colorWithHTMLColor:0x0066FF];
}

@end

@implementation NSString (Helper)

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
    return [self
        stringByTrimmingCharactersInSet:[NSCharacterSet
                                            whitespaceAndNewlineCharacterSet]];
}

- (NSString *)stringWithTrailingSpaceIfNeeded {
    if (self.length == 0) {
        return self;
    }

    return [self stringByAppendingString:@" "];
}

+ (NSMutableString *)textSeparatedStringFromEnumerator:
                         (id<NSFastEnumeration>)container
                                              selector:(SEL)selector
                                             separator:(NSString *)separator {
    NSMutableString *string = [NSMutableString string];

    static Class stringClass;

    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
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

+ (NSMutableString *)commaSeparatedStringFromStringEnumerator:
    (id<NSFastEnumeration>)container;
{
    return [NSString textSeparatedStringFromEnumerator:container
                                              selector:@selector(self)
                                             separator:@","];
}

+ (NSMutableString *)commaSeparatedStringFromEnumerator:
                         (id<NSFastEnumeration>)container
                                               selector:(SEL)selector;
{
    return [NSString textSeparatedStringFromEnumerator:container
                                              selector:selector
                                             separator:@","];
}

- (NSMutableArray<NSString *> *)mutableArrayFromCommaSeparatedString {
    NSCharacterSet *comma =
        [NSCharacterSet characterSetWithCharactersInString:@","];
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

- (UIFont *)updateFont:(UIFont *)font
             pointSize:(CGFloat)pointSize
                  bold:(bool)boldText
                italic:(bool)italicText {
    UIFontDescriptor *fontDescriptor = font.fontDescriptor;
    uint32_t traits = (boldText ? UIFontDescriptorTraitBold : 0) |
                      (italicText ? UIFontDescriptorTraitItalic : 0);

    fontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:traits];
    font = [UIFont fontWithDescriptor:fontDescriptor size:pointSize];

    return font;
}

- (void)addSegmentToString:(UIFont *)font
                     style:(NSParagraphStyle *)style
                     color:(UIColor *)color
                      link:(NSString *)link
                    string:(NSMutableAttributedString *)string {
    // DEBUG_LOGS(substring);
    if (font == nil) {
        NSAttributedString *segment = self.attributedString;
        [string appendAttributedString:segment];
        return;
    }

    NSAttributedString *segment = nil;
    NSMutableDictionary *attr = [NSMutableDictionary dictionary];

    attr[NSFontAttributeName] = font;
    attr[NSForegroundColorAttributeName] = color;

    if (style) {
        attr[NSParagraphStyleAttributeName] = style;
    }

    if (link) {
        attr[NSLinkAttributeName] = [NSURL URLWithString:link];
    }

    segment = [self attributedStringWithAttributes:attr];

    [string appendAttributedString:segment];
}

- (NSParagraphStyle *)centerStyle:(bool)center {
    static dispatch_once_t onceToken;

    static NSMutableParagraphStyle *centered;
    static NSMutableParagraphStyle *left;

    dispatch_once(&onceToken, ^{
      centered = [NSParagraphStyle defaultParagraphStyle].mutableCopy;
      [centered setFirstLineHeadIndent:0];
      [centered setHeadIndent:0];
      centered.alignment = NSTextAlignmentCenter;

      left = [NSParagraphStyle defaultParagraphStyle].mutableCopy;
      [left setFirstLineHeadIndent:0];
      [left setHeadIndent:0];
      left.alignment = NSTextAlignmentLeft;
    });

    if (center) {
        return centered;
    } else {
        return left;
    }
}

- (NSParagraphStyle *)indentStyleSize:(CGFloat)size
                              tabStop:(CGFloat)tabStop
                          indentToTab:(bool)indentToTab {
    if (size == 0) {
        return nil;
    }

    static dispatch_once_t onceToken;

    static NSMutableDictionary<NSNumber *, NSParagraphStyle *> *indents;

    dispatch_once(&onceToken, ^{
      indents = [NSMutableDictionary new];
    });

#define INDENT_KEY(S, T, B) ((S) + (T) * 0x10000 + ((B) ? 0x1000000 : 0))

    NSParagraphStyle *style =
        indents[@(INDENT_KEY(size, tabStop, indentToTab))];

    if (style == NULL) {
        @synchronized(indents) {
            NSMutableParagraphStyle *indentedStyle =
                [NSParagraphStyle defaultParagraphStyle].mutableCopy;

            [indentedStyle setTabStops:@[
                [[NSTextTab alloc]
                    initWithTextAlignment:NSTextAlignmentLeft
                                 location:size
                                  options:[NSDictionary dictionary]],
                [[NSTextTab alloc]
                    initWithTextAlignment:NSTextAlignmentLeft
                                 location:tabStop
                                  options:[NSDictionary dictionary]]
            ]];
            indentedStyle.defaultTabInterval = size;
            indentedStyle.firstLineHeadIndent = 0;
            indentedStyle.headIndent = indentToTab ? tabStop : size;
            indentedStyle.alignment = NSTextAlignmentLeft;

            style = indentedStyle;
            indents[@(INDENT_KEY(size, tabStop, indentToTab))] = style;
        }
    }
    return style;
}

- (NSString *)percentEncodeUrl {
    return [self stringByAddingPercentEncodingWithAllowedCharacters:
                     NSCharacterSet.URLPathAllowedCharacterSet];
}

- (NSString *)fullyPercentEncodeString {
    return [self stringByAddingPercentEncodingWithAllowedCharacters:
                     NSCharacterSet.alphanumericCharacterSet];
}

- (NSString *)safeEscapeForMarkUp {
    if (![self containsString:markupEscape]) {
        return self;
    }

    NSMutableString *string = [[NSMutableString alloc] init];
    NSScanner *escapeScanner = [NSScanner scannerWithString:self];

    escapeScanner.charactersToBeSkipped = nil;
    NSString *substring = nil;

    while (!escapeScanner.isAtEnd) {
        [escapeScanner scanUpToString:markupEscape intoString:&substring];

        if (substring != nil) {
            [string appendString:substring];
            substring = nil;
        }

        if (!escapeScanner.isAtEnd) {
            [string appendString:markupEscape];
            [string appendString:@"h"];
            escapeScanner.scanLocation++;
        }
    }

    return string;
}

- (NSMutableAttributedString *)smallAttributedStringFromMarkUp {
    return
        [self attributedStringFromMarkUpWithFont:nil]; // MainFonts.smallFont];
}

- (NSMutableAttributedString *)attributedStringFromMarkUp {
    return
        [self attributedStringFromMarkUpWithFont:nil]; // MainFonts.basicFont];
}

#define FONT_DELTA_S (1.0)
#define FONT_DELTA_M (2.0)
#define FONT_DELTA_L (4.0)

- (NSMutableAttributedString *)attributedStringFromMarkUpWithFont:
    (UIFont *)font {
    return [self attributedStringFromMarkUpWithFont:font fixedFont:NULL];
}

static inline NSString *addToSubstring(NSString *str, NSString *substring) {
    if (substring) {
        substring = [substring stringByAppendingString:str];
    } else {
        substring = str;
    }
    return substring;
}

// See header for formatting markup
- (NSMutableAttributedString *)
    attributedStringFromMarkUpWithFont:(UIFont *)font
                             fixedFont:(UIFont *)fixedFont {
    NSMutableAttributedString *string =
        [[NSMutableAttributedString alloc] init];
    NSScanner *escapeScanner = [NSScanner scannerWithString:self];
    CGFloat pointSize = font ? font.pointSize : 10;
    CGFloat indent = pointSize;
    CGFloat currentIndent = 0;
    CGFloat currentTabStop = pointSize;
    bool indentTo2ndTabStop = false;
    UIColor *currentColor = [UIColor modeAwareText];
    NSString *substring = nil;
    bool italicText = NO;
    bool boldText = NO;
    bool fontChanged = YES;
    bool center = NO;
    NSParagraphStyle *style = nil;
    unichar c;
    NSString *link = nil;
    UIFont *currentFont = font.copy;
    UIFont *cachedFont = nil;

    escapeScanner.charactersToBeSkipped = nil;

    while (!escapeScanner.isAtEnd) {
        @autoreleasepool {
            substring = nil;
            [escapeScanner scanUpToString:markupEscape intoString:&substring];

            if (!escapeScanner.isAtEnd) {
                escapeScanner.scanLocation++;
            }

            if (!escapeScanner.isAtEnd) {
                c = [self characterAtIndex:escapeScanner.scanLocation];
                escapeScanner.scanLocation++;
                switch (c) {
                case 'h':
                case '#':
                    substring = addToSubstring(markupEscape, substring);
                    break;
                case 't':
                    substring = addToSubstring(@"\t", substring);
                    break;
                case 'n':
                    substring = addToSubstring(@"\n", substring);
                    break;
                }

                if (substring && substring.length > 0) {
                    if (fontChanged && currentFont) {
                        currentFont = [self updateFont:currentFont
                                             pointSize:pointSize
                                                  bold:boldText
                                                italic:italicText];
                        fontChanged = NO;
                    }

                    [substring addSegmentToString:currentFont
                                            style:style
                                            color:currentColor
                                             link:link
                                           string:string];
                    substring = nil;
                }

                switch (c) {
                default:
                    break;

                case 'f':
                    break;

                case 'F':
                    break;

                case 'h':
                    break;

                case '#':
                    break;

                case 'b':
                    boldText = !boldText;
                    fontChanged = YES;
                    break;

                case 'i':
                    italicText = !italicText;
                    fontChanged = YES;
                    break;
                case '-':
                    if (pointSize > FONT_DELTA_S) {
                        pointSize -= FONT_DELTA_S;
                        fontChanged = YES;
                    }
                    break;
                case '+':
                    pointSize += FONT_DELTA_S;
                    fontChanged = YES;
                    break;
                case '(':
                    if (pointSize > FONT_DELTA_M) {
                        pointSize -= FONT_DELTA_M;
                        fontChanged = YES;
                    }
                    break;
                case ')':
                    pointSize += FONT_DELTA_M;
                    fontChanged = YES;
                    break;
                case '[':
                    if (pointSize > FONT_DELTA_L) {
                        pointSize -= FONT_DELTA_L;
                        fontChanged = YES;
                    }
                    break;
                case ']':
                    pointSize += FONT_DELTA_L;
                    fontChanged = YES;
                    break;
                case '0':
                    currentColor = [UIColor blackColor];
                    break;
                case 'O':
                    currentColor = [UIColor orangeColor];
                    break;
                case 'G':
                    currentColor = [UIColor greenColor];
                    break;
                case 'A':
                    currentColor = [UIColor grayColor];
                    break;
                case 'R':
                    currentColor = [UIColor redColor];
                    break;
                case 'B':
                    currentColor = [UIColor blueColor];
                    break;
                case 'C':
                    currentColor = [UIColor cyanColor];
                    break;
                case 'Y':
                    currentColor = [UIColor yellowColor];
                    break;
                case 'N':
                    currentColor = [UIColor brownColor];
                    break;
                case 'M':
                    currentColor = [UIColor magentaColor];
                    break;
                case 'W':
                    currentColor = [UIColor whiteColor];
                    break;
                case 'D':
                    currentColor = [UIColor modeAwareText];
                    break;
                case '!':
                    currentColor = [UIColor modeAwareText];
                    break;
                case 'U':
                    currentColor = [UIColor modeAwareBlue];
                    break;
                case 'E':
                    currentColor = [UIColor colorNamed:@"AccentColor"];
                    break;
                case '>': {
                    currentIndent += indent;
                    style = [self indentStyleSize:currentIndent
                                          tabStop:currentTabStop
                                      indentToTab:indentTo2ndTabStop];
                    break;
                }
                case '2':
                    indentTo2ndTabStop = !indentTo2ndTabStop;
                    style = [self indentStyleSize:currentIndent
                                          tabStop:currentTabStop
                                      indentToTab:indentTo2ndTabStop];
                    break;
                case '<': {
                    if (currentIndent > 0) {
                        currentIndent -= indent;
                    }
                    style = [self indentStyleSize:currentIndent
                                          tabStop:currentTabStop
                                      indentToTab:indentTo2ndTabStop];
                    break;
                }
                case '~': {
                    currentTabStop += indent * 5;
                    style = [self indentStyleSize:currentIndent
                                          tabStop:currentTabStop
                                      indentToTab:indentTo2ndTabStop];
                    break;
                }
                case '.': {
                    if (currentTabStop > 0) {
                        currentTabStop -= indent * 5;
                        style = [self indentStyleSize:currentIndent
                                              tabStop:currentTabStop
                                          indentToTab:indentTo2ndTabStop];
                    }
                    break;
                }
                case '|': {
                    center = !center;
                    style = [self centerStyle:center];
                    break;
                }
                case 'L': {
                    NSString *linkScan = nil;
                    [escapeScanner scanUpToString:@" " intoString:&linkScan];

                    if (linkScan) {
                        link = linkScan.stringByRemovingPercentEncoding;
                    } else {
                        link = nil;
                    }

                    if (!escapeScanner.isAtEnd) {
                        escapeScanner.scanLocation++;
                    }
                    break;
                }
                case 'T':
                    link = nil;
                    break;
                case 'X': {
                    if (currentFont != nil && cachedFont == nil) {
                        cachedFont = currentFont;
                        currentFont = [UIFont fontWithName:@"Menlo-Bold"
                                                      size:pointSize];
                        fontChanged = YES;
                    }
                    break;
                }
                case 'P': {
                    if (currentFont && cachedFont) {
                        currentFont = cachedFont;
                        fontChanged = YES;
                        cachedFont = nil;
                    }
                    break;
                }
                }
            } else if (substring != nil && substring.length > 0) {
                if (fontChanged && currentFont) {
                    currentFont = [self updateFont:currentFont
                                         pointSize:pointSize
                                              bold:boldText
                                            italic:italicText];
                    fontChanged = NO;
                }

                [substring addSegmentToString:currentFont
                                        style:style
                                        color:currentColor
                                         link:nil
                                       string:string];
                substring = nil;
            } else {
                substring = nil;
            }
        }
    }

    return string;
}

- (NSString *)removeMarkUp {
    return [self attributedStringFromMarkUpWithFont:nil].string;
}

- (bool)hasCaseInsensitiveSubstring:(NSString *)search {
    return
        [self rangeOfString:search options:NSCaseInsensitiveSearch].location !=
        NSNotFound;
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

- (NSString *)markedUpLinkToStopId {
    return [NSString stringWithFormat:@"Stop ID #Lid:%@ %@#T", self, self];
}

- (NSString *)removeSingleLineBreaks {
    // Replace single line breaks
    NSRegularExpression *regex =
        [NSRegularExpression regularExpressionWithPattern:@"(?<!\n)\n(?!\n)"
                                                  options:0
                                                    error:NULL];
    return [regex stringByReplacingMatchesInString:self
                                           options:0
                                             range:NSMakeRange(0, self.length)
                                      withTemplate:@" "];
}

- (NSString *)markDownToMarkUp {
    NSScanner *newlineScanner = [NSScanner scannerWithString:self];

    NSMutableString *newString = [[NSMutableString alloc] init];

    newlineScanner.charactersToBeSkipped = nil;

    NSString *substring = nil;

    bool indented = false;
    bool spaced = true;
    bool pre = false;

    while (!newlineScanner.isAtEnd) {
        [newlineScanner scanUpToString:newl intoString:&substring];

        DEBUG_LOG(@"Substring: %@", substring);

        if (!newlineScanner.isAtEnd) {
            newlineScanner.scanLocation++;
        }

        if (substring != nil &&
            substring.stringByTrimmingWhitespace.length == 0) {
            substring = nil;
        }

        if (substring != nil) {
            char c = [substring characterAtIndex:0];
            if ([substring isEqualToString:@"<pre>"]) {
                pre = true;
                [newString appendString:@"#X"];
            } else if ([substring isEqualToString:@"</pre>"]) {
                pre = false;
                [newString appendString:@"#P"];
            } else if (pre) {
                [newString appendString:substring];
                [newString appendString:newl];
            } else if (c == '-' || c == '+') {
                if (!indented) {
                    if (!spaced) {
                        [newString appendString:newl];
                    }
                    [newString appendFormat:@"#>"];
                    indented = true;
                } else {
                    [newString appendString:newl];
                }
                [newString
                    appendFormat:@"•\t%@ ", [substring substringFromIndex:1]
                                                .stringByTrimmingWhitespace];
                spaced = false;
            } else if (c == '#') {
                if (!spaced) {
                    [newString appendString:newl];
                }
                [newString appendFormat:@"#b#)%@#b#(\n",
                                        [substring substringFromIndex:1]
                                            .stringByTrimmingWhitespace];
                spaced = true;
            } else {
                [newString
                    appendFormat:@"%@ ", substring.stringByTrimmingWhitespace];
                spaced = false;
            }
            substring = nil;
        } else {
            if (indented) {
                indented = false;
                [newString appendString:@"\n#<"];
                [newString appendString:newl];
                spaced = false;
            } else if (pre) {
                [newString appendString:newl];
            } else {
                if (!spaced) {
                    [newString appendString:newl];
                }
                [newString appendString:newl];
                spaced = true;
            }
        }
    }

    [newString replaceOccurrencesOfString:@"**"
                               withString:@"#b"
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0, newString.length)];

    return newString;
}

@end
