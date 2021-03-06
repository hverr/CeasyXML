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

#import "CSXXMLParser.h"
#import "CSXDocumentLayout+CSXLayoutObject.h"

NSString * const CSXDocumentLayoutInvalidClassException =
    @"CSXDocumentLayoutInvalidClassException";

/* =========================================================================== 
 MARK: -
 MARK: Private Interface
 =========================================================================== */
@interface CSXDocumentLayout (Private)
/* MARK: Reading in Layouts */
- (NSError *)readLayoutDocument:(NSString *)fpath;
@end

/* =========================================================================== 
 MARK: -
 MARK: Public Implementation
 =========================================================================== */
@implementation CSXDocumentLayout
/* MARK: Init */
- (id)initWithLayoutDocument:(NSString *)doc error:(NSError **)errptr {
    self = [super init];
    
    if(self != nil) {
        NSError *err;
        
        err = [self readLayoutDocument:doc];
        if(err != nil) {
            if(errptr) *errptr = err;
            
            [self release];
            return nil;
        }
    }
    return self;
}

+ (id)documentLayoutWithLayoutDocument:(NSString *)doc error:(NSError **)err {
    id inst;
    inst = [[self alloc] initWithLayoutDocument:doc error:err];
    return [inst autorelease];
}

+ (NSArray *)documentLayoutsWithDocumentDocument:(NSString *)doc {
    return nil;
}

- (void)dealloc {
    self.name = nil;
    self.attributes = nil;
    self.subelements = nil;
    
    [super dealloc];
}

/* MARK: Properties */
@synthesize name, attributes, subelements, documentClass;

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
                     @"Class not found: %@", s];
        [[NSException exceptionWithName:excName reason:excReason userInfo:nil]
         raise];
        return;
    }
    
    self.documentClass = myClass;
}


- (CSXElementLayout *)subelementWithName:(NSString *)nam {
    CSXElementLayout *layout;
    
    for(layout in self.subelements) {
        if([layout.name isEqualToString:nam]) {
            return layout;
        }
    }
    return nil;
}

- (CSXNodeLayout *)attributeWithName:(NSString *)nam {
    CSXNodeLayout *layout;
    
    for(layout in self.attributes) {
        if([layout.name isEqualToString:nam]) {
            return layout;
        }
    }
    return nil;
}

/* MARK: Description */
- (NSString *)description {
    return [NSString stringWithFormat:
            @"%@: %@ (class %@)",
            [super description], self.name, 
            self.documentClass];
}
@end

/* =========================================================================== 
 MARK: -
 MARK: Private Implementation
 =========================================================================== */
@implementation CSXDocumentLayout (Private)
/* MARK: Reading in Layouts */
- (NSError *)readLayoutDocument:(NSString *)fpath {
    CSXDocumentLayout *layout, *result;
    CSXXMLParser *parser;
    BOOL state;
    
    layout = [CSXDocumentLayout layoutDocumentLayout];
    
    parser = [[CSXXMLParser alloc] initWithDocumentLayouts:
              [NSArray arrayWithObject:layout]];
    parser.file = fpath;
    
    state = [parser parse];
    
    if(state == NO || parser.error != nil) {
        NSError *err;
        err = [parser.error retain];
        [parser release];
        return [err autorelease];
    }
    
    result = (CSXDocumentLayout *)parser.result;
    
    self.name = result.name;
    self.attributes = result.attributes;
    self.subelements = result.subelements;
    self.documentClass = result.documentClass;
    
    [parser release];
    return nil;
}
@end
