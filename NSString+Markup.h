//
//  NSString+Markup.h
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

#import <Foundation/Foundation.h>
#import <Foundation/NSEnumerator.h>

@class UIFont;

@interface NSString (Markup)

// A simple markup for basic text formatting.
// # is the escape character for formatting.
//
// Basic
// #b - toggle bold text
// #i - toggle italic text
// #h is used to escape - e.g. #h becomes #
// ## is also an escape
// #n - new line (used when a /n may be not allowed)
// #t - tab - to next tab stop /t also works

// Font size
// #+ increases font size by 1 point
// #( decreases font size by 2 points
// #[ decreases font size by 4 points
// #- decreases font size by 1 point
// #) increases font size by 2 points
// #] increases font size by 4 points
// #f small font
// #F larger font (basic font)
// #X switch to fixed width font of the same size, caching original font
// #P pop back original font

// Colors:
// #D - dark mode aware text (black or white)
// #! - dark mode aware system-wide alert color (yellow or black)
// #U - dark mode aware blue.
// #E - accent color
// #0 - black
// #O - orange
// #G - green
// #A - gray
// #R - red
// #B - blue
// #C - cyan
// #Y - yellow
// #N - brown
// #M - magenta
// #W - white

// Positioning
// #> - increase indent and first tab all by font point size
// #< - decrease indentatation
// #~ - increase 2nd tab stop by 5 time point size
// #. - decrease 2nd tab stop by 5 time point size
// #2 - toggle indent to 2nd tab stop
// #| - toggle center text

// Links - there is a space after the URL to indicate the end
// #Lhttp://apple.com Text#T

- (NSMutableAttributedString *_Nonnull)attributedStringFromMarkUpWithFont:
    (UIFont *_Nullable)font;
- (NSMutableAttributedString *_Nonnull)
    attributedStringFromMarkUpWithFont:(UIFont *_Nullable)font
                             fixedFont:(UIFont *_Nullable)fixedFont;
- (NSString *_Nonnull)safeEscapeForMarkUp;
- (NSString *_Nonnull)removeMarkUp;

// We support a very small subset of markdown
// Use a # for a heading - will just make bold and 2 points bigger. # must be
// first character Use ** for bold Start a line with - or + for bullets It
// assumes that lines are to be contatonated into a paragraph unless there are
// two line breaks between the lines. Start a line with <pre> for a fixed width
// font and no more formatting until... Start a line with </pre> to return to
// regular.
- (NSString *_Nonnull)markDownToMarkUp;


@end
