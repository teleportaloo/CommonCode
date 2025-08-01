//
//  UIColor+HTML.h
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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (HTML)

+ (UIColor *)colorWithHTMLColor:(long)col;

/// Returns the HTML hex string representation of the color (e.g., "#FF5733").
- (NSString *)hexString;

/// Creates and returns a UIColor from an HTML hex string (e.g., "#FF5733" or
/// "FF5733"). Returns nil if the string is not valid.
+ (nullable UIColor *)colorWithHexString:(NSString *)hexString;

@end

NS_ASSUME_NONNULL_END
