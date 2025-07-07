//
//  UIColor+DarkMode.m
//  Automata
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

#define IOS_DARK_MODE                                                          \
    ([UIScreen mainScreen].traitCollection.userInterfaceStyle ==               \
     UIUserInterfaceStyleDark)

@implementation UIColor (DarkMode)

+ (UIColor *)modeAwareText {
#if TARGET_OS_WATCH
#else
    if (@available(iOS 13.0, *)) {
        return [UIColor labelColor];
    }
#endif
    return [UIColor blackColor];
}

+ (UIColor *)modeAwareBlue {
#if TARGET_OS_WATCH
#else
    if (@available(iOS 13.0, *)) {
        if (IOS_DARK_MODE) {
            // These colors are based in the "information icon" (i) color
            return [UIColor colorWithHTMLColor:0x0099FF];
        }
    }
#endif
    return [UIColor colorWithHTMLColor:0x0066FF];
}

+ (UIColor *)modeAwareGrayText {
#if TARGET_OS_WATCH
#else
    if (IOS_DARK_MODE) {
        return [UIColor lightGrayColor];
    }
#endif
    return [UIColor grayColor];
}

@end
