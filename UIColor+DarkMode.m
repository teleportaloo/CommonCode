//
//  UIColor+DarkMode.m
//
//  Created by Andy Wallace on 7/7/25.
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

#import "UIColor+DarkMode.h"
#import "UIColor+HTML.h"

@implementation UIColor (DarkMode)

+ (bool)darkMode {
#if TARGET_OS_WATCH
    return false;
#else
    return ([UIScreen mainScreen].traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark);
#endif
}

+ (UIColor *)modeAwareText {
#if TARGET_OS_WATCH
    return [UIColor blackColor];
#else
    return [UIColor labelColor];
#endif
}

+ (UIColor *)modeAwareBlue {
    if (self.darkMode) {
        // These colors are based in the "information icon" (i) color
        return [UIColor colorWithHTMLColor:0x0099FF];
    }
    return [UIColor colorWithHTMLColor:0x0066FF];
}

+ (UIColor *)modeAwareGrayText {
    if (self.darkMode) {
        return [UIColor lightGrayColor];
    }
    return [UIColor grayColor];
}

+ (UIColor *)randomColor {
    CGFloat red = (double)(arc4random() % 256) / 255.0;
    CGFloat green = (double)(arc4random() % 256) / 255.0;
    CGFloat blue = (double)(arc4random() % 256) / 255.0;

    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

@end
