/*
 *  NSString+CSXLibXMLConversion.m
 *  ceasyxml
 *  http://code.google.com/p/ceasyxml/
 *
 *  Copyright (c) 2012 Henri Verroken
 *
 *  Permission is hereby granted, free of charge, to any person obtaining
 *  a copy of this software and associated documentation files (the
 *  "Software"), to deal in the Software without restriction, including
 *  without limitation the rights to use, copy, modify, merge, publish,
 *  distribute, sublicense, and/or sell copies of the Software, and to
 *  permit persons to whom the Software is furnished to do so, subject to
 *  the following conditions:
 *
 *  The above copyright notice and this permission notice shall be
 *  included in all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *  ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
 *  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 *  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 *  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 *  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 *  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

#import "NSString+CSXLibXMLConversion.h"

/* #define INDENT_CHAR (@"\t") */
/* #define INDENT_CHAR (@" ") */
#define INDENT_CHAR (@"    ")

#define NEWLINE_CHAR (@"\n")

/* =========================================================================== 
 MARK: -
 MARK: Public Implementation
 =========================================================================== */
@implementation NSString (CSXLibXMLConversion)
/* MARK: Conversion */
- (xmlChar *)copyXMLCharacters {
    xmlChar *buffer;
    const char *utf8string;
    
    utf8string = [self UTF8String];
    buffer = xmlCharStrdup(utf8string);
    
    return buffer;
}

/* MARK: Indentation */
+ (id)indentationWithNewlines:(NSInteger)n level:(NSInteger)l {
    NSMutableString *s;
    NSUInteger c;
    
    c = (n * [NEWLINE_CHAR length]) + (l * [INDENT_CHAR length]);
    s = [[NSMutableString alloc] initWithCapacity:c];

    for(c = 0; c < n; c++) {
        [s appendString:NEWLINE_CHAR];
    }
    
    for(c = 0; c < l; c++) {
        [s appendString:INDENT_CHAR];
    }
    
    return [s autorelease];
}

xmlChar *NSStringCSXXMLCharIndentation(NSInteger newlines, NSInteger level) {
    return [[NSString indentationWithNewlines:newlines level:level] 
            copyXMLCharacters];
}

@end
