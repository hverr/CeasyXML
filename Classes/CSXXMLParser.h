/*
 *  CSXXMLParser.h
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
#import <libxml/parser.h>

#import "CSXDocumentLayout.h"
#import "CSXElementLayout.h"
#import "CSXElementList.h"

extern NSString * const CSXXMLParserErrorDomain;
extern NSString * const CSXXMLLibXMLErrorDomain;

extern NSString * const CSXXMLParserDocumentClassNullException;
extern NSString * const CSXXMLParserElementClassNullException;

extern NSString * const CSXXMLParserElementNameStackKey;

enum {
    kCSXXMLParserUnkownDocumentTypeError = 1
};

@interface CSXXMLParser : NSObject {
    NSError *_parseError;
    NSArray *_warnings;
    id _result;
    
    struct {
        BOOL errorOccurred;
        BOOL parsing;
        BOOL parsingDocument;
        
        /* this array contains the path to the current element */
        NSMutableArray *elementNameStack;
        /* this array contains the layouts of the elements in the path to 
         the current element or +[NSNull null] */
        NSMutableArray *elementLayoutStack;
        /* this array contains the instances of the elements in the the path to 
         the current element or + [NSNull null] */
        NSMutableArray *elementInstanceStack;
    } _state;
}
/* MARK: Init */
- (id)initWithDocumentLayouts:(NSArray *)docLayouts;
+ (id)XMLParserWithDocumentLayouts:(NSArray *)docLayouts;

/* MARK: Properties */
@property (nonatomic, retain) NSArray *documentLayouts;
@property (nonatomic, retain) NSString *file;
@property (nonatomic, retain) NSData *data;

@property (nonatomic, retain, readonly) NSError *error;
@property (nonatomic, retain, readonly) NSArray *warnings;
@property (nonatomic, retain, readonly) id result;
@end

