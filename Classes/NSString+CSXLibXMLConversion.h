/*
 *  NSString+CSXLibXMLConversion.h
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


#import <Foundation/Foundation.h>
#import <libxml/xmlstring.h>

/*!
 This category extends the functionallity of NSString with several methods to
 easily convert an NSString to an xmlChar* buffer and to create strings used
 when working with LibXML.
 */

@interface NSString (CSXLibXMLConversion)
/* MARK: Conversion */
/*!
 Copies the content of an NSString to an allocated buffer of xmlChar's.
 
 When you are done with the buffer you should use free(3) to
 free the allocated memory.
 */
- (xmlChar *)copyXMLCharacters;

/* MARK: Indentation */
/*!
 Creates a new string with the specified amount of new lines and the specified
 amount of tabs.
 
 Note that one tab is printed out as four spaces by default. By editing the
 source code and recompiling the project, you can change this behaviour.
 
 @param newlines The amount of newlines to append at the beginning of the
 string.
 
 @param level The number of tabs to append to the string.
 */
+ (id)indentationWithNewlines:(NSInteger)newlines level:(NSInteger)level;
@end

/*!
 Creates a new buffer by first calling indentationWithNewLines:level and then
 using -copyXMLCharacters to convert the string to an xmlChar* buffer.
 
 You must use free(3) to free the allocated memory returned by the function.
 */
xmlChar *NSStringCSXXMLCharIndentation(NSInteger newlines, NSInteger level);

