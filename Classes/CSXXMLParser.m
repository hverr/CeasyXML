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

NSString * const CSXXMLParserErrorDomain = @"CSXXMLParserErrorDomain";
NSString * const CSXXMLLibXMLErrorDomain = @"CSXXMLLibXMLErrorDomain";

NSString * const CSXXMLParserDocumentClassNullException = 
    @"CSXXMLParserDocumentClassNullException";
NSString * const CSXXMLParserElementClassNullException =
    @"CSXXMLParserElementClassNullException";

NSString * const CSXXMLParserElementNameStackKey =
    @"CSXXMLParserElementNameStackKey";

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

- (void)initializeState;
- (void)emptyState;
- (void)pushStateElement:(const xmlChar *)name layout:(id)l instance:(id)inst;

/* MARK: XML Processing Methods */
- (CSXDocumentLayout *)documentLayoutForType:(const xmlChar *)docElem;
- (id)instanceOfDocumentClass:(CSXDocumentLayout *)layout;
- (id)instanceOfElementClass:(CSXElementLayout *)layout;

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

/* MARK: Errors */
- (NSError *)unkownDocumentTypeError:(const xmlChar *)docElem;
@end

/* =========================================================================== 
 MARK: -
 MARK: Public Implementation
 =========================================================================== */
@implementation CSXXMLParser
/* MARK: Init */
- (id)initWithDocumentLayouts:(NSArray *)docLayouts {
    self = [super init];
    if(self != nil) {
        self.documentLayouts = docLayouts;
    }
    return self;
}

+ (id)XMLParserWithDocumentLayouts:(NSArray *)docLayouts {
    id inst;
    inst = [[self alloc] initWithDocumentLayouts:docLayouts];
    return [inst autorelease];
}

- (void)dealloc {
    self.documentLayouts = nil;
    self.file = nil;
    self.data = nil;
    
    self.error = nil;
    self.warnings = nil;
    self.result = nil;
    
    [super dealloc];
}

/* MARK: Properties */
@synthesize documentLayouts, file, data;
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
    CSXXMLParser *parser;
    
    parser = (CSXXMLParser *)ctx;
    [parser initializeState];
}

void CSXXMLParserEndDocument(void *ctx) {
    CSXXMLParser *parser;
    
    parser = (CSXXMLParser *)ctx;
    [parser emptyState];
}

void CSXXMLParserStartElement(void *ctx, 
                              const xmlChar *name, 
                              const xmlChar **atts)
{
    CSXXMLParser *parser;
    
    parser = (CSXXMLParser *)ctx;
    
    if(parser->_state.parsingDocument == NO) {
        CSXDocumentLayout *layout;
        id documentInstance;
        
        /* get document layout to use */
        layout = [parser documentLayoutForType:name];
        if(layout == nil) {
            parser.error = [parser unkownDocumentTypeError:name];
            parser->_state.errorOccurred = YES;
            return;
        }
        
        /* create instance of class */
        @try {
            documentInstance = [parser instanceOfDocumentClass:layout];
        }
        @catch (NSException * e) {
            parser->_state.errorOccurred = YES;
            [e raise];
        }
        @finally {}
        
        [parser pushStateElement:name layout:layout instance:documentInstance];
        parser->_state.parsingDocument = YES;
    
    } else if(parser->_state.parsingDocument) {
        CSXElementLayout *parentLayout;
        CSXElementLayout *subelement;
        NSString *elementName;
        
        /* the element can also be a CSXDocumentLayout, but the classes share
         the needed methods, so their will be no problem */
        parentLayout = [parser->_state.elementLayoutStack lastObject];
        if((NSNull *)parentLayout == [NSNull null]) {
            [parser pushStateElement:name 
                              layout:[NSNull null] 
                            instance:[NSNull null]];
            return;
        }
        
        elementName = [NSString stringWithUTF8String:(const char *)name];
        subelement  = [parentLayout subelementWithName:elementName];
        if(subelement == nil) {
            [parser pushStateElement:name 
                              layout:[NSNull null] 
                            instance:[NSNull null]];
            
        } else {
            id elementInstance;
            
            @try {
                elementInstance = [parser instanceOfElementClass:subelement];
            }
            @catch (NSException * e) {
                parser->_state.errorOccurred = YES;
                [e raise];
            }
            @finally {}
            
            [parser pushStateElement:name 
                              layout:subelement 
                            instance:elementInstance];
        }
    }
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

- (void)initializeState {
    memset(&_state, 0, sizeof(_state));
    
    _state.parsing = YES;
    
    _state.elementNameStack = [NSMutableArray new];
    _state.elementLayoutStack = [NSMutableArray new];
    _state.elementInstanceStack = [NSMutableArray new];
}

- (void)emptyState {
    [_state.elementNameStack release];
    [_state.elementLayoutStack release];
    [_state.elementInstanceStack release];
    
    memset(&_state, 0, sizeof(_state));
}

- (void)pushStateElement:(const xmlChar *)name layout:(id)l instance:(id)inst {
    [_state.elementNameStack addObject:
     [NSString stringWithUTF8String:(const char *)name]];
    
    [_state.elementLayoutStack addObject:l];
    
    [_state.elementInstanceStack addObject:inst];
}
         

/* MARK: XML Processing Methods */
- (CSXDocumentLayout *)documentLayoutForType:(const xmlChar *)docElem {
    CSXDocumentLayout *aLayout;
    xmlChar *layoutName;
    
    for(aLayout in self.documentLayouts) {
        layoutName = xmlCharStrdup([aLayout.name UTF8String]);
        if(xmlStrcmp(docElem, layoutName) == 0) {
            free(layoutName);
            return aLayout;
        }
        free(layoutName);
    }
    
    return nil;
}

- (id)instanceOfDocumentClass:(CSXDocumentLayout *)layout {
    id inst;
    
    if(layout.documentClass == NULL) {
        NSString *name, *reason;
        
        name = CSXXMLParserDocumentClassNullException;
        reason = [NSString stringWithFormat:
                  @"Document class of the layout %@ with name %@ is NULL",
                  [layout description], layout.name];
        [[NSException exceptionWithName:name reason:reason userInfo:nil] raise];
        return nil;
    }
    
    inst = [[layout.documentClass alloc] init];
    return [inst autorelease];
}

- (id)instanceOfElementClass:(CSXElementLayout *)layout {
    /* Returns +[NSNull null] if content type is string, number or boolean. If
     the type is custom, an instance of the setup class is returned. If the 
     type is or the element is non-unique list an instance of the 
     CSXElementList class is returned. */
    
    id inst;
    
    NSString *name, *reason;
    
    if(layout.unique == NO) {
        return [CSXElementList elementList];
    }
    
    switch(layout.contentLayout.contentType) {
        case CSXNodeContentTypeString: /* fallthrough */
        case CSXNodeContentTypeNumber: /* fallthrough */
        case CSXNodeContentTypeBoolean:
            inst = [NSNull null];
            break;
            
        case CSXNodeContentTypeCustom:
            if(layout.contentLayout.customClass == NULL) {
                name = CSXXMLParserElementClassNullException;
                reason = [NSString stringWithFormat:
                          @"Element class of the layout %@ with name %@ "
                          @"is NULL",
                          [layout description], layout.name];
                [[NSException exceptionWithName:name 
                                         reason:reason 
                                       userInfo:nil]
                 raise];
                return nil;
            }
            
            inst = [[layout.contentLayout.customClass alloc] init];
            [inst autorelease];
            break;
            
        case CSXNodeContentTypeList:
            inst = [CSXElementList elementList];
            break;
            
        default:
            inst = nil;
            break;
    }
    
    assert(inst != nil);
    
    return inst;
}

/* MARK: Errors */
- (NSError *)unkownDocumentTypeError:(const xmlChar *)docElem {
    NSString *descr, *reco;
    NSArray *stack;
    NSDictionary *userInfo;
    NSError *err;
    
    descr = [NSString stringWithFormat:
             @"Unkown document type while parsing XML document."];
    reco = [NSString stringWithFormat:
            @"Could not find a matching layout for the document with "
            @"root element '%s'", (const char *)docElem];
    stack = [_state.elementNameStack copy];
    
    userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                descr, NSLocalizedDescriptionKey,
                reco, NSLocalizedRecoverySuggestionErrorKey,
                stack, CSXXMLParserElementNameStackKey,
                nil];
    [stack release];
    
    err = [NSError errorWithDomain:CSXXMLParserErrorDomain 
                              code:kCSXXMLParserUnkownDocumentTypeError 
                          userInfo:userInfo];
    return err;
}
@end
