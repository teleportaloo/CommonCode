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
#import "TaskDispatch.h"

@implementation UIColor (HTML)

+ (UIColor *)colorWithHTMLColor:(uint32_t)col {
    static NSCache<NSNumber *, UIColor *> *colorCache;
    
    DoOnce(^{
      colorCache = [NSCache new];
    });

    UIColor *color = [colorCache objectForKey:@(col)];

    if (color == nil) {
        color = [UIColor colorWithRed:COL_HTML_R(col)
                                green:COL_HTML_G(col)
                                 blue:COL_HTML_B(col)
                                alpha:COL_HTML_A(col)];
        [colorCache setObject:color forKey:@(col)];
    }

    return color;
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

    return [UIColor colorWithHTMLColor:(uint32_t)rgbValue];
}

@end
