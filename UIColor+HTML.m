//
//  UIColor+HTML.m
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

#import "UIColor+HTML.h"

#define COL_HTML_R(V) (((CGFloat)(((V) >> 16) & 0xFF)) / 255.0)
#define COL_HTML_G(V) (((CGFloat)(((V) >> 8) & 0xFF)) / 255.0)
#define COL_HTML_B(V) (((CGFloat)((V) & 0xFF)) / 255.0)

@implementation UIColor (HTML)

+ (UIColor *)colorWithHTMLColor:(long)col {
    return [UIColor colorWithRed:COL_HTML_R(col)
                           green:COL_HTML_G(col)
                            blue:COL_HTML_B(col)
                           alpha:1.0];
}

- (NSString *)hexString {
    CGFloat red, green, blue, alpha;

    // Try to extract RGBA components
    if ([self getRed:&red green:&green blue:&blue alpha:&alpha]) {
        int r = (int)(red * 255);
        int g = (int)(green * 255);
        int b = (int)(blue * 255);
        int a = (int)(alpha * 255);
        return [NSString stringWithFormat:@"#%02X%02X%02X%02X", r, g, b, a];
    }
    return @"#000000";
}

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    if (hexString == nil) {
        return nil;
    }
    // Trim whitespace and newlines, and uppercase the string
    NSMutableString *cleanString = [[hexString
        stringByTrimmingCharactersInSet:[NSCharacterSet
                                            whitespaceAndNewlineCharacterSet]]
        mutableCopy];
    [cleanString setString:[cleanString uppercaseString]];

    // Remove '#' prefix if present
    if ([cleanString hasPrefix:@"#"]) {
        [cleanString deleteCharactersInRange:NSMakeRange(0, 1)];
    }

    // The string should be exactly 6 characters for valid RGB
    // or 8 if it includes the alpha channel.
    if ([cleanString length] != 6 && [cleanString length] != 8) {
        return nil;
    }

    // Scan the hex value
    unsigned long long rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:cleanString];
    if (![scanner scanHexLongLong:&rgbValue]) {
        return nil;
    }

    CGFloat alpha = 1.0;

    if ([cleanString length] == 8) {
        alpha = (rgbValue & 0x000000FF) / 255.0;
        rgbValue = rgbValue >> 8;
    }

    CGFloat red = ((rgbValue & 0xFF0000) >> 16) / 255.0;
    CGFloat green = ((rgbValue & 0x00FF00) >> 8) / 255.0;
    CGFloat blue = (rgbValue & 0x0000FF) / 255.0;

    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
