//
//  UIColor+HTML.m
//  Automata
//
//  Created by Andy Wallace on 7/6/25.
//

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
