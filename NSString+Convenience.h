//
//  NSString+Convenience.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Convenience)

// General helper functions

- (NSString *_Nonnull)removeSingleLineBreaks;
- (NSMutableAttributedString *_Nonnull)mutableAttributedString;
- (NSAttributedString *_Nonnull)attributedString;
- (NSString *_Nonnull)stringWithTrailingSpaceIfNeeded;
- (NSString *_Nonnull)stringByTrimmingWhitespace;
- (unichar)firstUnichar;
- (unichar)lastUnichar;

// URL encoding helpers
- (NSString *_Nonnull)percentEncodeUrl;
- (NSString *_Nonnull)fullyPercentEncodeString;

// Search helpers
- (bool)hasCaseInsensitiveSubstring:(NSString *_Nonnull)search;

// UI helpers
- (NSString *_Nonnull)justNumbers;

// Breaking down into arrays and back

- (NSMutableArray<NSString *> *_Nonnull)mutableArrayFromCommaSeparatedString;
+ (NSMutableString *_Nonnull)commaSeparatedStringFromStringEnumerator:
    (id<NSFastEnumeration> _Nonnull)container;

+ (NSMutableString *_Nonnull)commaSeparatedStringFromEnumerator:
                                 (id<NSFastEnumeration> _Nonnull)container
                                                       selector:(SEL _Nonnull)selector;

+ (NSMutableString *_Nonnull)textSeparatedStringFromEnumerator:
                                 (id<NSFastEnumeration> _Nonnull)container
                                                      selector:(SEL _Nonnull)selector
                                                     separator:(NSString *_Nonnull)separator;

- (NSAttributedString *_Nonnull)attributedStringWithAttributes:
    (nullable NSDictionary<NSAttributedStringKey, id> *)attrs;

@end

NS_ASSUME_NONNULL_END
