/*
 *  CSXLayoutList.m
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

#import "CSXLayoutList.h"
#import "CSXLayoutList+CSXLayoutObject.h"

/* =========================================================================== 
 MARK: -
 MARK: Private Interface
 =========================================================================== */
@interface CSXLayoutList (Private)
/* MARK: Reading in Layouts */
- (NSError *)readLayoutDocument:(NSString *)fpath;
@end


/* =========================================================================== 
 MARK: -
 MARK: Public Implementation
 =========================================================================== */
@implementation CSXLayoutList
/* MARK: Init */
- (id)initWithDocument:(NSString *)doc error:(NSError **)errptr {
    self = [super init];
    
    if(self != nil) {
        NSError *err;
        
        err = [self readLayoutDocument:doc];
        if(err != nil) {
            if(errptr) *errptr = err;
            
#if !__has_feature(objc_arc)
            [self release];
#endif
            return nil;
        }
    }
    
    return self;
}

+ (id)layoutListWithDocument:(NSString *)doc error:(NSError **)err {
    id inst;
    inst = [[self alloc] initWithDocument:doc error:err];
#if !__has_feature(objc_arc)
    return [inst autorelease];
#else
    return inst;
#endif
}

- (void)dealloc {
    self.layouts = nil;
    
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

/* MARK: Properties */
@synthesize layouts;
@end
               
/* =========================================================================== 
 MARK: -
 MARK: Private Implementation
 =========================================================================== */
@implementation CSXLayoutList (Private)
/* MARK: Reading in Layouts */
- (NSError *)readLayoutDocument:(NSString *)fpath {
    CSXDocumentLayout *layout;
    CSXLayoutList *result;
    CSXXMLParser *parser;
    BOOL state;
    
    layout = [CSXLayoutList layoutListDocumentLayout];
    
    parser = [[CSXXMLParser alloc] initWithDocumentLayouts:
              [NSArray arrayWithObject:layout]];
    parser.file = fpath;
    
    state = [parser parse];
    
    if(state == NO || parser.error != nil) {
        NSError *err;
#if !__has_feature(objc_arc)
        err = [parser.error retain];
        [parser release];
#endif
        
#if !__has_feature(objc_arc)
        return [err autorelease];
#else
        return err;
#endif
    }
    
    result = (CSXLayoutList *)parser.result;
    
    self.layouts = result.layouts;
    
#if !__has_feature(objc_arc)
    [parser release];
#endif
    return nil;
}
@end

