/*
 *  CSXXMLParser.m
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

#import "CSXXMLParser.h"

/* =========================================================================== 
 MARK: -
 MARK: Private Interface
 =========================================================================== */
@interface CSXXMLParser (Private)
/* MARK: Private Properties */
@property (nonatomic, retain) NSError *error;
@property (nonatomic, retain) NSArray *warnings;
@property (nonatomic, retain) id result;

/* MARK: LibXLM Functions */
void CSXXMLParserStartDocument(void *ctx);
void CSXXMLParserEndDocument(void *ctx);
void CSXXMLParserStartElement(void *ctx, 
                              const xmlChar *name, 
                              const xmlChar **atts);
void CSXXMLParserEndElement(void *ctx, const xmlChar *name);
void CSXXMLParserCharacters(void *ctx, const xmlChar *ch, int len);
void CSXXMLParserWarning(void *ctx, const char *msg, ...);
void CSXXMLParserError(void *ctx, const char *msg, ...);

/* MARK: LibXML Function Stucture */
static xmlSAXHandlerV1 CSXXMLParserSAXHandler = {
    NULL, /* internalSubset */
    NULL, /* isStandalone */
    NULL, /* hasInternalSubset */
    NULL, /* hasExternalSubset */
    NULL, /* resolveEntity */
    NULL, /* getEntity */
    NULL, /* entityDecl */
    NULL, /* notationDecl */
    NULL, /* attributeDecl */
    NULL, /* elementDecl */
    NULL, /* unparsedEntityDecl */
    NULL, /* setDocumentLocator */
    &CSXXMLParserStartDocument, /* startDocument */
    &CSXXMLParserEndDocument, /* endDocument */
    &CSXXMLParserStartElement, /* startElement */
    &CSXXMLParserEndElement, /* endElement */
    NULL, /* reference */
    &CSXXMLParserCharacters, /* characters */
    NULL, /* ignorableWhitespace */
    NULL, /* processingInstruction */
    NULL, /* comment */
    &CSXXMLParserWarning, /* warning */
    &CSXXMLParserError, /* error */
    NULL, /* fatalError */ /* unused error() get all the errors */
    NULL, /* getParameterEntity */
    NULL, /* cdataBlock */
    NULL, /* externalSubset */
    0 /* initialized */ 
};
@end

/* =========================================================================== 
 MARK: -
 MARK: Public Implementation
 =========================================================================== */
@implementation CSXXMLParser
/* MARK: Init */
- (id)initWithDocumentLayout:(CSXDocumentLayout *)docLayout {
    self = [super init];
    if(self != nil) {
        self.documentLayout = docLayout;
    }
    return self;
}

+ (id)XMLParserWithDocumentLayout:(CSXDocumentLayout *)docLayout {
    id inst;
    inst = [[self alloc] initWithDocumentLayout:docLayout];
    return [inst autorelease];
}

- (void)dealloc {
    self.documentLayout = nil;
    self.file = nil;
    self.data = nil;
    
    self.error = nil;
    self.warnings = nil;
    self.result = nil;
    
    [super dealloc];
}

/* MARK: Properties */
@synthesize documentLayout, file, data;
@synthesize error=_parseError, warnings=_warnings, result=_result;
@end


/* =========================================================================== 
 MARK: -
 MARK: Private Implementation
 =========================================================================== */
@implementation CSXXMLParser (Private)
- (void)setError:(NSError *)e {
    [e retain];
    [_parseError release];
    _parseError = e;
}

- (void)setWarnings:(NSArray *)a {
    [a retain];
    [_warnings release];
    _warnings = a;
}

- (void)setResult:(id)r {
    [r retain];
    [_result release];
    _result = r;
}

/* MARK: LibXLM Functions */
void CSXXMLParserStartDocument(void *ctx) {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

void CSXXMLParserEndDocument(void *ctx) {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

void CSXXMLParserStartElement(void *ctx, 
                              const xmlChar *name, 
                              const xmlChar **atts)
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

void CSXXMLParserEndElement(void *ctx, const xmlChar *name) {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

void CSXXMLParserCharacters(void *ctx, const xmlChar *ch, int len) {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

void CSXXMLParserWarning(void *ctx, const char *msg, ...) {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

void CSXXMLParserError(void *ctx, const char *msg, ...) {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}
@end
