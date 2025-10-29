//
//  StringHelper.m
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
#import "NSString+Convenience.h"
#import "NSString+Markup.h"
#import "TaskDispatch.h"
#import "UIColor+DarkMode.h"
#import "UIColor+HTML.h"
#import <TargetConditionals.h>

#define MARKUP_ESCAPE @"#"
#define NEWL @"\n"

@implementation NSString (Markup)

- (UIFont *)updateFont:(UIFont *)font
             pointSize:(CGFloat)pointSize
                  bold:(bool)boldText
                italic:(bool)italicText {
    UIFontDescriptor *fontDescriptor = font.fontDescriptor;
    uint32_t traits =
        (boldText ? UIFontDescriptorTraitBold : 0) | (italicText ? UIFontDescriptorTraitItalic : 0);

    fontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:traits];
    font = [UIFont fontWithDescriptor:fontDescriptor size:pointSize];

    return font;
}

- (void)addSegmentToString:(UIFont *)font
                     style:(NSParagraphStyle *)style
                     color:(UIColor *)color
                      link:(NSString *)link
                    string:(NSMutableAttributedString *)string {
    // DEBUG_LOG_NSString(substring);
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
    static NSMutableParagraphStyle *centered;
    static NSMutableParagraphStyle *left;

    DO_ONCE(^{
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

    static NSCache<NSNumber *, NSParagraphStyle *> *indents;

    DO_ONCE(^{
      indents = [NSCache new];
    });

#define INDENT_KEY(S, T, B) ((S) + (T) * 0x10000 + ((B) ? 0x1000000 : 0))

    NSParagraphStyle *style = [indents objectForKey:@(INDENT_KEY(size, tabStop, indentToTab))];

    if (style == NULL) {
        NSMutableParagraphStyle *indentedStyle =
            [NSParagraphStyle defaultParagraphStyle].mutableCopy;

        [indentedStyle setTabStops:@[
            [[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentLeft
                                            location:size
                                             options:[NSDictionary dictionary]],
            [[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentLeft
                                            location:tabStop
                                             options:[NSDictionary dictionary]]
        ]];
        indentedStyle.defaultTabInterval = size;
        indentedStyle.firstLineHeadIndent = 0;
        indentedStyle.headIndent = indentToTab ? tabStop : size;
        indentedStyle.alignment = NSTextAlignmentLeft;

        style = indentedStyle;
        [indents setObject:style forKey:@INDENT_KEY(size, tabStop, indentToTab)];
    }
    return style;
}

- (NSString *)safeEscapeForMarkUp {
    if (![self containsString:MARKUP_ESCAPE]) {
        return self;
    }

    NSMutableString *string = [[NSMutableString alloc] init];
    NSScanner *escapeScanner = [NSScanner scannerWithString:self];

    escapeScanner.charactersToBeSkipped = nil;
    NSString *substring = nil;

    while (!escapeScanner.isAtEnd) {
        [escapeScanner scanUpToString:MARKUP_ESCAPE intoString:&substring];

        if (substring != nil) {
            [string appendString:substring];
            substring = nil;
        }

        if (!escapeScanner.isAtEnd) {
            [string appendString:MARKUP_ESCAPE];
            [string appendString:@"h"];
            escapeScanner.scanLocation++;
        }
    }

    return string;
}

#define FONT_DELTA_S (1.0)
#define FONT_DELTA_M (2.0)
#define FONT_DELTA_L (4.0)

- (NSMutableAttributedString *)attributedStringFromMarkUpWithFont:(UIFont *)font {
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

static SafeSystemImageBlock safeSystemImage =
    ^UIImage *(NSString *name, UIImageSymbolConfiguration *cfg) {
#if TARGET_OS_WATCH
      if (@available(watchOS 6.0, *)) {
#endif // TARGET_OS_WATCH
          return [UIImage systemImageNamed:name withConfiguration:cfg];
#if TARGET_OS_WATCH
      }
      return nil;
#endif // TARGET_OS_WATCH
    };

+ (void)setSystemImageAlternatives:(SafeSystemImageBlock)block {
    safeSystemImage = block;
}

- (NSAttributedString *)attributedStringFromNamedSymbolWithFont:(UIFont *)font
                                                          color:(UIColor *)color {
#if TARGET_OS_WATCH
    if (@available(watchOS 6.0, *)) {
#endif // TARGET_OS_WATCH
        UIImageSymbolConfiguration *config =
            [UIImageSymbolConfiguration configurationWithPointSize:font.pointSize
                                                            weight:UIImageSymbolWeightRegular];
        __block UIImage *symbolImage = safeSystemImage(self, config);

        symbolImage = [symbolImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

        // Render it with color using UIGraphicsImageRenderer
        if (color != nil) {
            symbolImage = [symbolImage imageWithTintColor:color
                                            renderingMode:UIImageRenderingModeAlwaysOriginal];
        }

        if (!symbolImage) {
            return @"?".attributedString;
        }

        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = symbolImage;

        // Target height = cap height (not full pointSize)
        CGFloat targetHeight = font.capHeight;
        CGFloat aspectRatio = symbolImage.size.width / symbolImage.size.height;
        CGFloat targetWidth = targetHeight * aspectRatio;

        // Vertical alignment tweak:
        // Center the image relative to the font’s baseline box
        CGFloat baselineOffset =
            (font.capHeight - targetHeight) / 2.0 - 1.0; // -1.0 empirically centers better

        attachment.bounds = CGRectMake(0, baselineOffset, targetWidth, targetHeight);

        return [NSAttributedString attributedStringWithAttachment:attachment];

#if TARGET_OS_WATCH
    } else {
        return @"?".attributedString;
    }
#endif // TARGET_OS_WATCH
}

- (NSAttributedString *)attributedStringFromImageWithFont:(UIFont *)font {
    UIImage *image = [UIImage imageNamed:self];

    if (!image) {
        return @"?".attributedString;
    }

    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = image;

    // Target height = cap height (not full pointSize)
    CGFloat targetHeight = font.capHeight + 1;
    CGFloat aspectRatio = image.size.width / image.size.height;
    CGFloat targetWidth = targetHeight * aspectRatio;

    // Vertical alignment tweak:
    // Center the image relative to the font’s baseline box
    CGFloat baselineOffset =
        (font.capHeight - targetHeight) / 2.0 - 1.0; // -1.0 empirically centers better

    attachment.bounds = CGRectMake(0, baselineOffset, targetWidth, targetHeight);

    return [NSAttributedString attributedStringWithAttachment:attachment];
}

// See header for formatting markup
- (NSMutableAttributedString *)attributedStringFromMarkUpWithFont:(UIFont *)font
                                                        fixedFont:(UIFont *)fixedFont {
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
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
            [escapeScanner scanUpToString:MARKUP_ESCAPE intoString:&substring];

            if (!escapeScanner.isAtEnd) {
                escapeScanner.scanLocation++;
            }

            if (!escapeScanner.isAtEnd) {
                c = [self characterAtIndex:escapeScanner.scanLocation];
                escapeScanner.scanLocation++;
                switch (c) {
                case 'h':
                case '#':
                    substring = addToSubstring(MARKUP_ESCAPE, substring);
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
                case 'K':
                    currentColor = [UIColor modeAwareGrayText];
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
                case 'S': {
                    NSString *symbolName = nil;
                    [escapeScanner scanUpToString:@" " intoString:&symbolName];

                    if (symbolName) {
                        if (fontChanged && currentFont) {
                            currentFont = [self updateFont:currentFont
                                                 pointSize:pointSize
                                                      bold:boldText
                                                    italic:italicText];
                            fontChanged = NO;
                        }

                        if (currentFont) {
                            [string appendAttributedString:
                                        [symbolName
                                            attributedStringFromNamedSymbolWithFont:currentFont
                                                                              color:currentColor]];
                        } else {
                            [string appendAttributedString:@"?".attributedString];
                        }
                    }

                    if (!escapeScanner.isAtEnd) {
                        escapeScanner.scanLocation++;
                    }
                    break;
                }
                case 'F': {
                    NSString *fileName = nil;
                    [escapeScanner scanUpToString:@" " intoString:&fileName];

                    if (fileName) {
                        if (fontChanged && currentFont) {
                            currentFont = [self updateFont:currentFont
                                                 pointSize:pointSize
                                                      bold:boldText
                                                    italic:italicText];
                            fontChanged = NO;
                        }

                        if (currentFont) {
                            [string appendAttributedString:
                                        [fileName attributedStringFromImageWithFont:currentFont]];
                        } else {
                            [string appendAttributedString:@"?".attributedString];
                        }
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
                        currentFont = [UIFont fontWithName:@"Menlo-Bold" size:pointSize];
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

- (NSString *)markDownToMarkUp {
    NSScanner *newlineScanner = [NSScanner scannerWithString:self];

    NSMutableString *newString = [[NSMutableString alloc] init];

    newlineScanner.charactersToBeSkipped = nil;

    NSString *substring = nil;

    bool indented = false;
    bool spaced = true;
    bool pre = false;

    while (!newlineScanner.isAtEnd) {
        [newlineScanner scanUpToString:NEWL intoString:&substring];

        DEBUG_LOG(@"Substring: %@", substring);

        if (!newlineScanner.isAtEnd) {
            newlineScanner.scanLocation++;
        }

        if (substring != nil && substring.stringByTrimmingWhitespace.length == 0) {
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
                [newString appendString:NEWL];
            } else if (c == '-' || c == '+') {
                if (!indented) {
                    if (!spaced) {
                        [newString appendString:NEWL];
                    }
                    [newString appendFormat:@"#>"];
                    indented = true;
                } else {
                    [newString appendString:NEWL];
                }
                [newString
                    appendFormat:@"•\t%@ ",
                                 [substring substringFromIndex:1].stringByTrimmingWhitespace];
                spaced = false;
            } else if (c == '#') {
                if (!spaced) {
                    [newString appendString:NEWL];
                }
                [newString
                    appendFormat:@"#b#)%@#b#(\n",
                                 [substring substringFromIndex:1].stringByTrimmingWhitespace];
                spaced = true;
            } else {
                [newString appendFormat:@"%@ ", substring.stringByTrimmingWhitespace];
                spaced = false;
            }
            substring = nil;
        } else {
            if (indented) {
                indented = false;
                [newString appendString:@"\n#<"];
                [newString appendString:NEWL];
                spaced = false;
            } else if (pre) {
                [newString appendString:NEWL];
            } else {
                if (!spaced) {
                    [newString appendString:NEWL];
                }
                [newString appendString:NEWL];
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
