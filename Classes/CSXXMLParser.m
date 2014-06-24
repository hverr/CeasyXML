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

NSString * const CSXXMLParserNoDataException = @"CSXXMLParserNoDataException";
NSString * const CSXXMLParserInvalidArgumentContentTypeException = 
    @"CSXXMLParserInvalidArgumentContentTypeException";

NSString * const CSXXMLParserElementNameStackKey =
    @"CSXXMLParserElementNameStackKey";


#if __has_feature(objc_arc)
@implementation CSXXMLParserState
@synthesize errorOccurred, parsing, parsingDocument;
@synthesize elementNameStack, elementLayoutStack, elementInstanceStack;
@synthesize stringContent;
@end
#endif /* OBJC_ARC */

/* =========================================================================== 
 MARK: -
 MARK: Private Interface
 =========================================================================== */

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
static xmlSAXHandler CSXXMLParserSAXHandler = {
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

@interface CSXXMLParser (Private)
/* MARK: Private Properties */
@property (nonatomic, retain) NSError *error;
@property (nonatomic, retain) NSMutableArray *warnings;
@property (nonatomic, retain) id result;

- (void)initializeState;
- (void)emptyState;
- (void)pushStateElement:(const xmlChar *)name layout:(id)l instance:(id)inst;
- (void)popStateElement:(NSString **)name layout:(id *)l instance:(id *)inst;

/* MARK: XML Processing Methods */
- (CSXDocumentLayout *)documentLayoutForType:(const xmlChar *)docElem;
- (id)instanceOfDocumentClass:(CSXDocumentLayout *)layout;
- (id)instanceOfElementClass:(CSXElementLayout *)layout;
- (NSError *)assertRequiredElements:(CSXElementLayout *)layout 
                        forInstance:(id)i;
- (NSError *)assertRequiredAttributes:(CSXElementLayout *)layout 
                          forInstance:(id)i;

/* MARK: Setting Properties */
- (NSError *)setAttributes:(const xmlChar **)attrs
                    layout:(CSXElementLayout *)l
                  instance:(id)i;
- (NSError *)setNumber:(NSString *)s 
                layout:(CSXNodeLayout *)l 
              instance:(id)i;
- (NSError *)setString:(NSString *)s
                layout:(CSXNodeLayout *)l
              instance:(id)i;
- (NSError *)setBoolean:(NSString *)s
                 layout:(CSXNodeLayout *)l
               instance:(id)i;
- (NSError *)setUniqueInstance:(id)obj
                        layout:(CSXElementLayout *)l
                      instance:(id)i;
- (NSString *)setNonUniqueInstance:(id)obj
                            layout:(CSXElementLayout *)l
                          instance:(id)i;

/* MARK: Errors */
- (NSError *)unkownDocumentTypeError:(const xmlChar *)docElem;
- (NSError *)elementValueNoNumberError:(NSString *)val 
                                layout:(CSXNodeLayout *)l;
- (NSError *)elementValueNoBooleanError:(NSString *)val
                                 layout:(CSXNodeLayout *)l;
- (NSError *)requiredPropertyNotSetError:(id)instance
                                  layout:(CSXNodeLayout *)l
                               sublayout:(CSXNodeLayout *)subl;
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
#if !__has_feature(objc_arc)
    return [inst autorelease];
#else
    return inst;
#endif
}

- (id)initWithLayoutListDocument:(NSString *)f error:(NSError **)err {
    self = [super init];
    if(self != nil) {
        CSXLayoutList *list;
        
        list = [[CSXLayoutList alloc] initWithDocument:f error:err];
        if(list == nil) {
#if !__has_feature(objc_arc)
            [self release];
#endif
            return nil;
        }
        
        self.documentLayouts = list.layouts;
    }
    return self;
}

+ (id)XMLParserWithLayoutListDocument:(NSString *)f error:(NSError **)err {
    id inst;
    inst = [[self alloc] initWithLayoutListDocument:f error:err];
#if !__has_feature(objc_arc)
    return [inst autorelease];
#else
    return inst;
#endif
}

- (id)initWithLayoutDocument:(NSString *)f error:(NSError **)err {
    self = [super init];
    if(self != nil) {
        CSXDocumentLayout *layout;
        
        layout = [[CSXDocumentLayout alloc] initWithLayoutDocument:f error:err];
        if(layout == nil) {
#if !__has_feature(objc_arc)
            [self release];
#endif
            return nil;
        }
        
        self.documentLayouts = [NSArray arrayWithObject:layout];
    }
    return self;
}

+ (id)XMLParserWithLayoutDocument:(NSString *)f error: (NSError **)err {
    id inst;
    inst = [[self alloc] initWithLayoutDocument:f error:err];
#if !__has_feature(objc_arc)
    return [inst autorelease];
#else
    return inst;
#endif
}

- (void)dealloc {
    self.documentLayouts = nil;
    self.file = nil;
    self.data = nil;
    
    self.error = nil;
    self.warnings = nil;
    self.result = nil;
    
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

/* MARK: Properties */
@synthesize documentLayouts, file, data;
@synthesize error=_parseError, warnings=_warnings, result=_result;
- (NSArray *)warnings {
    if(_warnings == nil) {
        _warnings = [NSMutableArray new];
    }
    return _warnings;
}
/* MARK: Parsing */
- (BOOL)parse {
    int status;
    
    if(self.file == nil && self.data == nil) {
        NSString *name, *reason;
        
        name = CSXXMLParserNoDataException;
        reason = [NSString stringWithFormat:
                  @"%@: No file or data set, unable to parse.",
                  [self description]];
        [[NSException exceptionWithName:name reason:reason userInfo:nil] raise];
        return NO;
    }
    
    /* Parse file if set */
    if(self.file != nil) {
#if !__has_feature(objc_arc)
        status = xmlSAXUserParseFile(&CSXXMLParserSAXHandler,
                                     self, [self.file UTF8String]);
#else
        status = xmlSAXUserParseFile(&CSXXMLParserSAXHandler,
                                     (__bridge void *)(self), [self.file UTF8String]);
#endif
        
    } else {
#if !__has_feature(objc_arc)
        status = xmlSAXUserParseMemory(&CSXXMLParserSAXHandler,
                                       (void *)self, [self.data bytes],
                                       (int)[self.data length]);
#else
        status = xmlSAXUserParseMemory(&CSXXMLParserSAXHandler,
                                       (__bridge void *)self, [self.data bytes],
                                       (int)[self.data length]);
#endif
    }
    
    if(status != 0) {
        return NO;
    }
    
    return (self.error == nil);
}
@end


/* =========================================================================== 
 MARK: -
 MARK: Private Implementation
 =========================================================================== */
@implementation CSXXMLParser (Private)
@dynamic result, error;
- (void)setError:(NSError *)e {
#if !__has_feature(objc_arc)
    [e retain];
    [_parseError release];
#endif
    _parseError = e;
}

- (void)setWarnings:(NSMutableArray *)a {
#if !__has_feature(objc_arc)
    [a retain];
    [_warnings release];
#endif
    _warnings = a;
}

- (void)setResult:(id)r {
#if !__has_feature(objc_arc)
    [r retain];
    [_result release];
#endif
    _result = r;
}

/* MARK: LibXLM Functions */
void CSXXMLParserStartDocument(void *ctx) {
#if !__has_feature(objc_arc)
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
#endif
    CSXXMLParser *parser;

#if !__has_feature(objc_arc)
    parser = (CSXXMLParser *)ctx;
#else
    parser = (__bridge CSXXMLParser *)ctx;
#endif
    parser.error = nil;
    parser.result = nil;
    parser.warnings = [NSMutableArray array];
    [parser initializeState];

#if !__has_feature(objc_arc)
    [pool release];
#endif
}

void CSXXMLParserEndDocument(void *ctx) {
#if !__has_feature(objc_arc)
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
#endif
    CSXXMLParser *parser;
    
#if !__has_feature(objc_arc)
    parser = (CSXXMLParser *)ctx;
#else
    parser = (__bridge CSXXMLParser *)ctx;
#endif
    [parser emptyState];
    
#if !__has_feature(objc_arc)
    [pool release];
#endif
}

void CSXXMLParserStartElement(void *ctx,
                              const xmlChar *name, 
                              const xmlChar **atts)
{
#if !__has_feature(objc_arc)
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
#endif
    CSXXMLParser *parser;
    NSError *err;
    
#if !__has_feature(objc_arc)
    parser = (CSXXMLParser *)ctx;
#else
    parser = (__bridge CSXXMLParser *)ctx;
#endif
    
    if(parser->_state.parsingDocument == NO) {
        CSXDocumentLayout *layout;
        id documentInstance;
        
        /* get document layout to use */
        layout = [parser documentLayoutForType:name];
        if(layout == nil) {
            parser.error = [parser unkownDocumentTypeError:name];
            parser->_state.errorOccurred = YES;
            goto drainAndReturn;
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
        
        /* set attributes */
        err = [parser setAttributes:atts 
                             layout:(CSXElementLayout *)layout 
                           instance:documentInstance];
        if(err != nil) {
            parser.error = err;
            parser->_state.errorOccurred = YES;
        }
        
        [parser pushStateElement:name layout:layout instance:documentInstance];
        parser->_state.parsingDocument = YES;
    
    } else if(parser->_state.parsingDocument) {
        CSXElementLayout *parentLayout;
        CSXElementLayout *subelement;
        NSString *elementName;
        id parentInstance;
        
        if(parser->_state.errorOccurred == YES) {
            goto drainAndReturn;
        }
        
        /* the element can also be a CSXDocumentLayout, but the classes share
         the needed methods, so their will be no problem */
        parentLayout = [parser->_state.elementLayoutStack lastObject];
        parentInstance = [parser->_state.elementInstanceStack lastObject];
        if((NSNull *)parentLayout == [NSNull null]) {
            [parser pushStateElement:name 
                              layout:[NSNull null] 
                            instance:[NSNull null]];
            goto drainAndReturn;
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
            
            /* set attributes */
            err = [parser setAttributes:atts 
                                 layout:subelement 
                               instance:elementInstance];
            if(err != nil) {
                parser.error = err;
                parser->_state.errorOccurred = YES;
                goto drainAndReturn;
            }
            
            [parser pushStateElement:name 
                              layout:subelement 
                            instance:elementInstance];
            
            /* set array if it was not already set and if we have a non-unique 
             element type */
            if(subelement.unique == NO) {
                id currentList;
                currentList = objc_msgSend(parentInstance, 
                                           subelement.contentLayout.getter);
                if(currentList == nil) {
                    objc_msgSend(parentInstance,
                                 subelement.contentLayout.setter,
                                 [NSMutableArray array]);
                }
            }
            
            /* if the subelement is empty, we can already set the property */
            if(subelement.empty == YES) {
                if((subelement.contentLayout.contentType == 
                    CSXNodeContentTypeBoolean))
                {
                    objc_msgSend(parentInstance,
                                 subelement.contentLayout.setter,
                                 YES);
                
                } else if(subelement.unique == NO) {
                    NSMutableArray *array;
                    array = objc_msgSend(parentInstance,
                                         subelement.contentLayout.getter);
                    [array addObject:elementInstance];
                
                } else if(subelement.unique == YES) {
                    objc_msgSend(parentInstance,
                                 subelement.contentLayout.setter,
                                 elementInstance);
                }
            }
            
            /* create string if not empty and the type is string, or set the 
             instance  property if a non-unique element type */
            else {
                switch(subelement.contentLayout.contentType) {
                    case CSXNodeContentTypeString: /* fallthrough */
                    case CSXNodeContentTypeNumber: /* fallthrough */
                    case CSXNodeContentTypeBoolean: 
                        parser->_state.stringContent = [NSMutableString new];
                        break;
                        
                    default:
                        parser->_state.stringContent = nil;
                        break;
                }
            }
        }
    }
    
drainAndReturn:
#if !__has_feature(objc_arc)
    [pool release];
#else
    return;
#endif
}

void CSXXMLParserEndElement(void *ctx, const xmlChar *name) {
#if !__has_feature(objc_arc)
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
#endif
    CSXXMLParser *parser;
    NSString *elementName;
    CSXElementLayout *layout;
    id instance;
    id parentInstance;
    NSError *err;
    
#if !__has_feature(objc_arc)
    parser = (CSXXMLParser *)ctx;
#else
    parser = (__bridge CSXXMLParser *)ctx;
#endif
    
    if(parser->_state.errorOccurred == YES) {
        goto drainAndReturn;
    }
    
    [parser popStateElement:&elementName 
                     layout:&layout 
                   instance:&instance];
    assert([[NSString stringWithUTF8String:(const char *)name]
            isEqualToString:elementName]);
    
    /* if this is the last element, the document is ended */
    if([parser->_state.elementNameStack count] == 0) {
        parser.result = instance;
        
        /* check if the required document properties are set */
        err = [parser assertRequiredElements:layout forInstance:instance];
        if(err != nil) {
            parser.error = err;
            parser->_state.errorOccurred = YES;
            goto drainAndReturn;
        }
        
        err = [parser assertRequiredAttributes:layout forInstance:instance];
        if(err != nil) {
            parser.error = err;
            parser->_state.errorOccurred = YES;
            goto drainAndReturn;
        }
        
        goto drainAndReturn;
    }
    
    /* if their is no layout element, we are not interested in this element */
    if((NSNull *)layout == [NSNull null]) {
        goto drainAndReturn;
    }
    
    /* if its an empty object, the property has already been set in the
     start element call back */
    if(layout.empty == YES) {
        goto drainAndReturn;
    }
    
    if((NSNull *)instance == [NSNull null]) {
        assert(parser->_state.stringContent != nil);
#if !__has_feature(objc_arc)
        instance = [parser->_state.stringContent autorelease];
#else
        instance = parser->_state.stringContent;
#endif
        parser->_state.stringContent = nil;
    }
    
    /* check if we hve all required properties set */
    err = [parser assertRequiredElements:layout forInstance:instance];
    if(err != nil) {
        parser.error = err;
        parser->_state.errorOccurred = YES;
        goto drainAndReturn;
    }
    
    err = [parser assertRequiredAttributes:layout forInstance:instance];
    if(err != nil) {
        parser.error = err;
        parser->_state.errorOccurred = YES;
        goto drainAndReturn;
    }

    /* get the parent element, we have to set its properties */
    parentInstance = [parser->_state.elementInstanceStack lastObject];
    
    if(layout.unique == NO) {
        NSMutableArray *arr;
        NSScanner *scanner;
        NSInteger myIntVal;
        NSNumber *numb;
        BOOL scanState;
        
        arr = objc_msgSend(parentInstance, layout.contentLayout.getter);
        assert(arr != nil);
        switch(layout.contentLayout.contentType) {
            case CSXNodeContentTypeBoolean:
                numb = [NSNumber numberWithBool:
                        [(NSString *)instance boolValue]];
                [arr addObject:numb];
                break;
                
            case CSXNodeContentTypeNumber:
                scanner = [NSScanner scannerWithString:instance];
                scanState = [scanner scanInteger:&myIntVal];
                if(!scanState) {
                    err = [parser elementValueNoNumberError:instance 
                                                     layout:layout];
                } else {
                    numb = [NSNumber numberWithInteger:myIntVal];
                    [arr addObject:numb];
                }
                break;
                
            case CSXNodeContentTypeString: /* fallthrough */
            case CSXNodeContentTypeCustom: /* fallthrough */
            default:
                [arr addObject:instance];
                break;
        }
    } else {
        switch(layout.contentLayout.contentType) {
            case CSXNodeContentTypeString:
                err = [parser setString:instance
                           layout:layout 
                         instance:parentInstance];
                break;
                
            case CSXNodeContentTypeNumber:
                err = [parser setNumber:instance 
                           layout:layout 
                         instance:parentInstance];
                break;
                
            case CSXNodeContentTypeBoolean:
                err = [parser setBoolean:instance 
                            layout:layout 
                          instance:parentInstance];
                break;
                
            case CSXNodeContentTypeCustom:
                err = [parser setUniqueInstance:instance 
                                   layout:layout 
                                 instance:parentInstance];
                break;

            default:
                err = nil;
                break;
        }
    }
    
    if(err != nil) {
        parser.error = err;
        parser->_state.errorOccurred = YES;
    }
    
drainAndReturn:
#if !__has_feature(objc_arc)
    [pool release];
#else
    return;
#endif
}

void CSXXMLParserCharacters(void *ctx, const xmlChar *ch, int len) {
#if !__has_feature(objc_arc)
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
#endif
    CSXXMLParser *parser;
    NSString *str;
    
#if !__has_feature(objc_arc)
    parser = (CSXXMLParser *)ctx;
#else
    parser = (__bridge CSXXMLParser *)ctx;
#endif
    
    if(parser->_state.errorOccurred == YES) {
        goto drainAndReturn;
    }
    
    str = [[NSString alloc] initWithBytes:(const char *)ch 
                                   length:len 
                                 encoding:NSUTF8StringEncoding];
    [parser->_state.stringContent appendString:str];
#if !__has_feature(objc_arc)
    [str release];
#endif
    
drainAndReturn:
#if !__has_feature(objc_arc)
    [pool release];
#else
    return;
#endif
}

void CSXXMLParserWarning(void *ctx, const char *msg, ...) {
#if !__has_feature(objc_arc)
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
#endif
    NSError *err;
    NSString *descr, *reco, *format;
    NSDictionary *userInfo;
    va_list argList;
    CSXXMLParser *parser;
    NSArray *stack;
    
#if !__has_feature(objc_arc)
    parser = (CSXXMLParser *)ctx;
#else
    parser = (__bridge CSXXMLParser *)ctx;
#endif
    
    va_start(argList, msg);
    
    descr = [NSString stringWithFormat:
             @"Warning while parsing the XML document."];
    
    format = [NSString stringWithUTF8String:msg];
    reco = [[NSString alloc] initWithFormat:format arguments:argList];
    
    stack = [parser->_state.elementNameStack copy];
    
    userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                descr, NSLocalizedDescriptionKey,
                reco, NSLocalizedRecoverySuggestionErrorKey,
                stack, CSXXMLParserElementNameStackKey,
                nil];
#if !__has_feature(objc_arc)
    [stack release];
    [reco release];
#endif
    
    err = [NSError errorWithDomain:CSXXMLLibXMLErrorDomain 
                              code:CSXXMLLibXMLWarning 
                          userInfo:userInfo];
    
    [(NSMutableArray *)parser.warnings addObject:err];
#if !__has_feature(objc_arc)
    [pool release];
#endif
}

void CSXXMLParserError(void *ctx, const char *msg, ...) {
#if !__has_feature(objc_arc)
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
#endif
    NSError *err;
    NSString *descr, *reco, *format;
    NSDictionary *userInfo;
    va_list argList;
    CSXXMLParser *parser;
    NSArray *stack;
    
#if !__has_feature(objc_arc)
    parser = (CSXXMLParser *)ctx;
#else
    parser = (__bridge CSXXMLParser *)ctx;
#endif
    
    va_start(argList, msg);
    
    descr = [NSString stringWithFormat:
             @"Error while parsing the XML document."];
    
    format = [NSString stringWithUTF8String:msg];
    reco = [[NSString alloc] initWithFormat:format arguments:argList];
    
    stack = [parser->_state.elementNameStack copy];
    
    userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                descr, NSLocalizedDescriptionKey,
                reco, NSLocalizedRecoverySuggestionErrorKey,
                stack, CSXXMLParserElementNameStackKey,
                nil];
#if !__has_feature(objc_arc)
    [stack release];
    [reco release];
#endif
    
    err = [NSError errorWithDomain:CSXXMLLibXMLErrorDomain 
                              code:CSXXMLLibXMLError
                          userInfo:userInfo];
    
    parser.error = err;
    parser->_state.errorOccurred = YES;
#if !__has_feature(objc_arc)
    [pool release];
#endif
}

- (void)initializeState {
    memset(&_state, 0, sizeof(_state));
    
    _state.parsing = YES;
    
    _state.elementNameStack = [NSMutableArray new];
    _state.elementLayoutStack = [NSMutableArray new];
    _state.elementInstanceStack = [NSMutableArray new];
}

- (void)emptyState {
#if !__has_feature(objc_arc)
    [_state.elementNameStack release];
    [_state.elementLayoutStack release];
    [_state.elementInstanceStack release];
#endif
    
    memset(&_state, 0, sizeof(_state));
}

- (void)pushStateElement:(const xmlChar *)name layout:(id)l instance:(id)inst {
    [_state.elementNameStack addObject:
     [NSString stringWithUTF8String:(const char *)name]];
    
    [_state.elementLayoutStack addObject:l];
    
    [_state.elementInstanceStack addObject:inst];
}
         
- (void)popStateElement:(NSString **)nameptr 
                 layout:(id *)lptr 
               instance:(id *)instptr 
{
    NSString *name;
    id inst;
    
    assert(nameptr != NULL);
    assert(lptr != NULL);
    assert(instptr != NULL);
    
#if !__has_feature(objc_arc)
    name = [[_state.elementNameStack lastObject] retain];
#else
    name = [_state.elementNameStack lastObject];
#endif
    [_state.elementNameStack removeLastObject];
    
#if !__has_feature(objc_arc)
    layout = [[_state.elementLayoutStack lastObject] retain];
#else
    name = [_state.elementLayoutStack lastObject];
#endif
    [_state.elementLayoutStack removeLastObject];
    
#if !__has_feature(objc_arc)
    inst = [[_state.elementInstanceStack lastObject] retain];
#else
    inst = [_state.elementInstanceStack lastObject];
#endif
    [_state.elementInstanceStack removeLastObject];
    
#if !__has_feature(objc_arc)
    *nameptr = [name autorelease];
    *lptr = [layout autorelease];
    *instptr = [inst autorelease];
#endif
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
#if !__has_feature(objc_arc)
    return [inst autorelease];
#else
    return inst;
#endif
}

- (id)instanceOfElementClass:(CSXElementLayout *)layout {
    /* Returns +[NSNull null] if content type is string, number or boolean. If
     the type is custom, an instance of the setup class is returned. If the 
     element is non-unique an NSMutableArray is returned. */
    
    id inst;
    
    NSString *name, *reason;
    
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
#if !__has_feature(objc_arc)
            [inst autorelease];
#endif
            break;
            
        default:
            inst = nil;
            break;
    }
    
    assert(inst != nil);
    
    return inst;
}

- (NSError *)assertRequiredElements:(CSXElementLayout *)layout 
                        forInstance:(id)i 
{
    CSXElementLayout *sublayout;
    id property;
    
    for(sublayout in layout.subelements) {
        if(sublayout.required == YES) {
            switch(sublayout.contentLayout.contentType) {
                case CSXNodeContentTypeCustom: /* fallthrough */
                case CSXNodeContentTypeString:
                    property = objc_msgSend(i, sublayout.contentLayout.getter);
                    if(property == nil) {
                        return [self requiredPropertyNotSetError:i 
                                                          layout:layout
                                                       sublayout:sublayout];
                    }
                    break;
                    
                case CSXNodeContentTypeNumber: /* fallthrough */
                case CSXNodeContentTypeBoolean: /* fallthrough */
                default:
                    break;
            }
        }
    }
    
    return nil;
}

- (NSError *)assertRequiredAttributes:(CSXElementLayout *)layout 
                          forInstance:(id)i 
{
    CSXNodeLayout *sublayout;
    id property;
    
    for(sublayout in layout.attributes) {
        if(sublayout.required == YES) {
            switch(sublayout.contentLayout.contentType) {
                case CSXNodeContentTypeString:
                    property = objc_msgSend(i, sublayout.contentLayout.getter);
                    if(property == nil) {
                        return [self requiredPropertyNotSetError:i 
                                                          layout:layout
                                                       sublayout:sublayout];
                    }
                    break;
                    
                case CSXNodeContentTypeBoolean: /* fallthrough */
                case CSXNodeContentTypeNumber: /* fallthrough */
                default:
                    break;
            }
        }
    }
    
    return nil;
}

/* MARK: Setting Properties */
- (NSError *)setAttributes:(const xmlChar **)attrs
               layout:(CSXElementLayout *)l
             instance:(id)i
{
    CSXNodeLayout *attributeLayout;
    const xmlChar *cattrName, *cattrValue;
    NSString *attrName, *attrValue;
    NSString *excName, *excReason;
    NSError *err;
    int c;
    
    if(attrs == NULL) {
        return nil;
    }
    
    c = 0;
    err = nil;
    while(1) {
#if !__has_feature(objc_arc)
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
#endif
        
        cattrName = attrs[c];
        if(cattrName == NULL) {
#if !__has_feature(objc_arc)
            [pool release];
#endif
            break;
        }
        
        cattrValue = attrs[c+1];
        
        attrName = [NSString stringWithUTF8String:(const char *)cattrName];
        attrValue = [NSString stringWithUTF8String:(const char *)cattrValue];
        
        attributeLayout = [l attributeWithName:attrName];
        if(attributeLayout != nil) {
            switch(attributeLayout.contentLayout.contentType) {
                case CSXNodeContentTypeString:
                    err = [self setString:attrValue 
                                   layout:attributeLayout 
                                 instance:i];
                    break;
                    
                case CSXNodeContentTypeNumber:
                    err = [self setNumber:attrValue 
                                   layout:attributeLayout 
                                 instance:i];
                    break;
                    
                case CSXNodeContentTypeBoolean:
                    err = [self setBoolean:attrValue 
                                    layout:attributeLayout 
                                  instance:i];
                    break;
                    
                default:
                    excName = CSXXMLParserInvalidArgumentContentTypeException;
                    excReason = [NSString stringWithFormat:
                                 @"The content type '%@' is not allowed for "
                                 @"an attribute.", 
                                 l.contentLayout.contentTypeIdentifier];
                    [[NSException exceptionWithName:excName 
                                             reason:excReason 
                                           userInfo:nil] raise];
                    break;
            }
        }
        
        if(err != nil) {
#if !__has_feature(objc_arc)
            [pool release];
#endif
            break;
        }
        
        c += 2;
        
#if !__has_feature(objc_arc)
        [pool release];
#endif
    }
    
    return err;
}

- (NSError *)setNumber:(NSString *)s 
                layout:(CSXNodeLayout *)l 
              instance:(id)i 
{
    NSScanner *scanner;
    NSInteger intVal;
    BOOL status;
    
    scanner = [NSScanner scannerWithString:s];
    status = [scanner scanInteger:&intVal];
    if(status == NO) {
        return [self elementValueNoNumberError:s layout:l];
    }
    
    objc_msgSend(i, l.contentLayout.setter, intVal);
    
    return nil;
}

- (NSError *)setString:(NSString *)s
                layout:(CSXNodeLayout *)l
              instance:(id)i 
{
    objc_msgSend(i, l.contentLayout.setter, s);
    return nil;
}

- (NSError *)setBoolean:(NSString *)s
                 layout:(CSXNodeLayout *)l
               instance:(id)i
{
    BOOL boolVal;
    
    if([s caseInsensitiveCompare:@"YES"]) {
        boolVal = YES;
        
    } else if([s caseInsensitiveCompare:@"NO"]) {
        boolVal = NO;
        
    } else if([s caseInsensitiveCompare:@"TRUE"]) {
        boolVal = YES;
        
    } else if([s caseInsensitiveCompare:@"FALSE"]) {
        boolVal = NO;
        
    } else if([s caseInsensitiveCompare:@"1"]) {
        boolVal = YES;
    
    } else if([s caseInsensitiveCompare:@"0"]) {
        boolVal = NO;
    
    } else {
        return [self elementValueNoBooleanError:s layout:l];
    }
    
    objc_msgSend(i, l.contentLayout.setter, boolVal);
    
    return nil;
}
    
- (NSError *)setUniqueInstance:(id)obj
                        layout:(CSXElementLayout *)l
                      instance:(id)i
{
    objc_msgSend(i, l.contentLayout.setter, obj);
    return nil;
}

- (NSString *)setNonUniqueInstance:(id)obj
                            layout:(CSXElementLayout *)l
                          instance:(id)i
{
    NSMutableArray *list;
    
    list = (NSMutableArray *)objc_msgSend(i, l.contentLayout.getter);
    assert([list isKindOfClass:[NSMutableArray class]]);
    
    [list addObject:obj];
    
    return nil;
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
#if !__has_feature(objc_arc)
    [stack release];
#endif
    
    err = [NSError errorWithDomain:CSXXMLParserErrorDomain 
                              code:kCSXXMLParserUnkownDocumentTypeError 
                          userInfo:userInfo];
    return err;
}

- (NSError *)elementValueNoNumberError:(NSString *)val 
                                layout:(CSXNodeLayout *)l 
{
    NSString *descr, *reco;
    NSArray *stack;
    NSDictionary *userInfo;
    NSError *err;
    
    descr = [NSString stringWithFormat:
             @"The element value is not a number."];
    reco = [NSString stringWithFormat:
            @"The element value of element %@ is not a valid number.",
            l.name];
    stack = [_state.elementNameStack copy];
    userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                descr, NSLocalizedDescriptionKey,
                reco, NSLocalizedRecoverySuggestionErrorKey,
                stack, CSXXMLParserElementNameStackKey,
                nil];
#if !__has_feature(objc_arc)
    [stack release];
#endif
    
    err = [NSError errorWithDomain:CSXXMLParserErrorDomain 
                              code:kCSXXMLParserElementValueNoNumberError 
                          userInfo:userInfo];
    return err;
}

- (NSError *)elementValueNoBooleanError:(NSString *)val
                                 layout:(CSXNodeLayout *)l
{
    NSString *descr, *reco;
    NSArray *stack;
    NSDictionary *userInfo;
    NSError *err;
    
    descr = [NSString stringWithFormat:
             @"The element value is not a boolean."];
    reco = [NSString stringWithFormat:
            @"The element value of element %@ is not a valid boolean.",
            l.name];
    stack = [_state.elementNameStack copy];
    userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                descr, NSLocalizedDescriptionKey,
                reco, NSLocalizedRecoverySuggestionErrorKey,
                stack, CSXXMLParserElementNameStackKey,
                nil];
#if !__has_feature(objc_arc)
    [stack release];
#endif
    
    err = [NSError errorWithDomain:CSXXMLParserErrorDomain 
                              code:kCSXXMLParserElementValueNoBooleanError 
                          userInfo:userInfo];
    return err;
}

- (NSError *)requiredPropertyNotSetError:(id)instance
                                  layout:(CSXNodeLayout *)l
                               sublayout:(CSXNodeLayout *)subl
{
    NSString *descr, *reco;
    NSArray *stack;
    NSDictionary *userInfo;
    NSError *err;
    
    descr = [NSString stringWithFormat:
             @"A required property is missing."];
    reco = [NSString stringWithFormat:
            @"The property %@ is not set for instance %@, though "
            @"it is required.", subl.name, [instance description]];
    stack = [_state.elementNameStack copy];
    userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                descr, NSLocalizedDescriptionKey,
                reco, NSLocalizedRecoverySuggestionErrorKey,
                stack, CSXXMLParserElementNameStackKey,
                nil];
#if !__has_feature(objc_arc)
    [stack release];
#endif
    
    err = [NSError errorWithDomain:CSXXMLParserErrorDomain 
                              code:kCSXXMLParserRequiredPropertyNotSetError 
                          userInfo:userInfo];
    return err;
}
@end
