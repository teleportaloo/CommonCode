//
//  NSString+Markup.h
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
@class UIColor;
@class UIImageSymbolConfiguration;
@class UIImage;


// Sometimes a system image may not be supported. The client can provide a block that will
// check and replace with another if it was not found. By default it will not replace anything

typedef UIImage *_Nullable (^SafeSystemImageBlock)(NSString *_Nonnull name,
                                                   UIImageSymbolConfiguration *_Nullable config);
 


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
// #X switch to fixed width font of the same size, caching original font
// #P pop back original font

// Colors:
// #D - dark mode aware text (black or white)
// #! - dark mode aware system-wide alert color (yellow or black)
// #U - dark mode aware blue.
// #K - mode aware gray
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
// #~ - increase 2nd tab stop by 5 times point size
// #. - decrease 2nd tab stop by 5 times point size
// #2 - toggle indent to 2nd tab stop
// #| - toggle center text

// Links
// Note there is a space after the URL to indicate the end
// #Lhttp://apple.com Text#T

// Images and SF symbols
// #Ssymbol insert SF symbol by name e.g. #Sbriefcase.fill
// #Fimage insert image from bundle by name e.g. #Lapple.png

- (NSMutableAttributedString *_Nonnull)attributedStringFromMarkUpWithFont:(UIFont *_Nullable)font;
- (NSMutableAttributedString *_Nonnull)attributedStringFromMarkUpWithFont:(UIFont *_Nullable)font
                                                                fixedFont:
                                                                    (UIFont *_Nullable)fixedFont;

// This function adds extra #s to a string so they will not be interpreted as
// markup
- (NSString *_Nonnull)safeEscapeForMarkUp;

// Removes the markup - usually for logging
- (NSString *_Nonnull)removeMarkUp;

// We support a very small subset of markdown
// Use a # for a heading - will just make bold and 2 points bigger. # must be
// first character Use ** for bold Start a line with - or + for bullets It
// assumes that lines are to be contatonated into a paragraph unless there are
// two line breaks between the lines. Start a line with <pre> for a fixed width
// font and no more formatting until... Start a line with </pre> to return to
// regular.
- (NSString *_Nonnull)markDownToMarkUp;

// We can add an SF Symbol or image into a string at the same size as the font
- (NSAttributedString *_Nonnull)attributedStringFromNamedSymbolWithFont:(UIFont *_Nonnull)font
                                                                  color:(UIColor *_Nullable)color;

- (NSAttributedString *_Nonnull)attributedStringFromImageWithFont:(UIFont *_Nonnull)font;

+ (void)setSystemImageAlternatives:(SafeSystemImageBlock _Nonnull )block;

@end

