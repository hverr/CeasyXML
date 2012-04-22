/*
 *  CSXDocumentLayout.m
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

#import "CSXDocumentLayout.h"

NSString * const CSXDocumentLayoutInvalidClassException =
    @"CSXDocumentLayoutInvalidClassException";

/* =========================================================================== 
 MARK: -
 MARK: Public Implementation
 =========================================================================== */
@implementation CSXDocumentLayout
- (void)dealloc {
    self.name = nil;
    self.attributes = nil;
    self.elements = nil;
    
    [super dealloc];
}

/* MARK: Properties */
@synthesize name, attributes, elements, documentClass;

- (NSString *)documentClassString {
    if(self.documentClass == NULL) {
        return nil;
    }
    return NSStringFromClass(self.documentClass);
}

- (void)setDocumentClassString:(NSString *)s {
    Class myClass;
    
    myClass = NSClassFromString(s);
    if(myClass == NULL) {
        NSString *excName, *excReason;
        
        excName = CSXDocumentLayoutInvalidClassException;
        excReason = [NSString stringWithFormat:
                     @"Class not found: %s", s];
        [[NSException exceptionWithName:excName reason:excReason userInfo:nil]
         raise];
        return;
    }
    
    self.documentClass = myClass;
}
@end

