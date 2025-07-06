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

@end
