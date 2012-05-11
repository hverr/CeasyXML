/*
 *  CSXXMLWriter.h
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
#import <objc/runtime.h>
#import <libxml/xmlwriter.h>

#import "CSXDocumentLayout.h"
#import "CSXElementLayout.h"
#import "CSXElementLayout.h"
#import "CSXElementList.h"

#import "NSString+CSXLibXMLConversion.h"

extern NSString * const CSXXMLWriterErrorDomain;

extern NSString * const CSXXMLWriterNoRootInstanceException;
extern NSString * const CSXXMLWriterNoDocumentLayoutException;
extern NSString * const CSXXMLWriterInvalidAttributeTypeException;

enum {
    kCSXXMLWriterTextWriterCreationError = 1,
    kCSXXMLWriterTextWriterWriteError
};

@interface CSXXMLWriter : NSObject {
    
    struct {
        BOOL isWritingToFile;
        xmlTextWriterPtr textWriter;
        NSInteger indentationLevel;
    } _state;
}
/* MARK: Init */
- (id)initWithDocumentLayout:(CSXDocumentLayout *)layout;
+ (id)XMLWriterWithDocumentLayout:(CSXDocumentLayout *)layout;

- (id)initWithLayoutDocument:(NSString *)f error:(NSError **)err;
+ (id)XMLWriterWithLayoutDocument:(NSString *)f error:(NSError **)err;

/* MARK: Properties */
@property (nonatomic, retain) CSXDocumentLayout *documentLayout;
@property (nonatomic, retain) id rootInstance;

@property (nonatomic, retain) NSString *XMLVersion;
@property (nonatomic, retain) NSString *encoding;
@property (nonatomic, assign) int compression;

/* MARK: Writing */
- (BOOL)writeToFile:(NSString *)file error:(NSError **)errptr;
@end

