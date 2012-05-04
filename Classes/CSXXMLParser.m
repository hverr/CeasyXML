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

/* =========================================================================== 
 MARK: -
 MARK: Private Interface
 =========================================================================== */
@interface CSXXMLParser (Private)
/* MARK: Private Properties */
@property (nonatomic, retain) NSError *error;
@property (nonatomic, retain) NSMutableArray *warnings;
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
- (void)popStateElement:(NSString **)name layout:(id *)l instance:(id *)inst;

/* MARK: XML Processing Methods */
- (CSXDocumentLayout *)documentLayoutForType:(const xmlChar *)docElem;
- (id)instanceOfDocumentClass:(CSXDocumentLayout *)layout;
- (id)instanceOfElementClass:(CSXElementLayout *)layout;

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

/* MARK: Errors */
- (NSError *)unkownDocumentTypeError:(const xmlChar *)docElem;
- (NSError *)elementValueNoNumberError:(NSString *)val 
                                layout:(CSXNodeLayout *)l;
- (NSError *)elementValueNoBooleanError:(NSString *)val
                                 layout:(CSXNodeLayout *)l;
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
        status = xmlSAXUserParseFile(&CSXXMLParserSAXHandler, 
                                     self, [self.file UTF8String]);
        
    } else {
        status = xmlSAXUserParseMemory(&CSXXMLParserSAXHandler, 
                                       self, [self.data bytes], 
                                       [self.data length]);
    }
    
    return (status == 0);
}
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

- (void)setWarnings:(NSMutableArray *)a {
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
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    CSXXMLParser *parser;
    
    parser = (CSXXMLParser *)ctx;
    [parser initializeState];
    
    [pool release];
}

void CSXXMLParserEndDocument(void *ctx) {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    CSXXMLParser *parser;
    
    parser = (CSXXMLParser *)ctx;
    [parser emptyState];
    
    [pool release];
}

void CSXXMLParserStartElement(void *ctx, 
                              const xmlChar *name, 
                              const xmlChar **atts)
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    CSXXMLParser *parser;
    NSError *err;
    
    parser = (CSXXMLParser *)ctx;
    
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
            
            /* set to yes if the subelement is empty */
            if(subelement.empty == YES) {
                objc_msgSend(parentInstance,
                             subelement.contentLayout.setter,
                             YES);
            }
            
            /* create string if not empty and the type is string, or set the 
             instance  property if we have a list or a non-unique element 
             type */
            else {
                switch(subelement.contentLayout.contentType) {
                    case CSXNodeContentTypeString: /* fallthrough */
                    case CSXNodeContentTypeNumber: /* fallthrough */
                    case CSXNodeContentTypeBoolean: 
                        parser->_state.stringContent = [NSMutableString new];
                        break;
                        
                    case CSXNodeContentTypeList:
                        objc_msgSend(parentInstance, 
                                     subelement.contentLayout.setter,
                                     elementInstance);
                        parser->_state.stringContent = nil;
                        break;
                        
                    default:
                        parser->_state.stringContent = nil;
                        break;
                }
            }
        }
    }
    
drainAndReturn:
    [pool release];
}

void CSXXMLParserEndElement(void *ctx, const xmlChar *name) {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    CSXXMLParser *parser;
    NSString *elementName;
    CSXElementLayout *layout;
    id instance;
    id parentInstance;
    NSError *err;
    
    parser = (CSXXMLParser *)ctx;
    if(parser->_state.errorOccurred == YES) {
        goto drainAndReturn;
    }
    
    [parser popStateElement:&elementName 
                     layout:(id *)&layout 
                   instance:&instance];
    assert([[NSString stringWithUTF8String:(const char *)name]
            isEqualToString:elementName]);
    
    /* if this is the last element, the document is ended */
    if([parser->_state.elementNameStack count] == 0) {
        parser.result = instance;
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
        instance = [parser->_state.stringContent autorelease];
        parser->_state.stringContent = nil;
    }

    /* get the parent element, we have to set its properties */
    parentInstance = [parser->_state.elementInstanceStack lastObject];
    
    if(layout.unique == NO) {
        NSMutableArray *arr;
        arr = objc_msgSend(parentInstance, layout.contentLayout.getter);
        assert(arr != nil);
        [arr addObject:instance];
        goto drainAndReturn;
    }
    
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
            
        case CSXNodeContentTypeList:
            [((CSXElementList *)parentInstance).elements addObject:instance];
            err = nil;
            break;
            
        default:
            err = nil;
            break;
    }
    
    if(err != nil) {
        parser.error = err;
        parser->_state.errorOccurred = YES;
    }
    
drainAndReturn:
    [pool release];
}

void CSXXMLParserCharacters(void *ctx, const xmlChar *ch, int len) {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    CSXXMLParser *parser;
    NSString *str;
    
    parser = (CSXXMLParser *)ctx;
    if(parser->_state.errorOccurred == YES) {
        goto drainAndReturn;
    }
    
    str = [[NSString alloc] initWithBytes:(const char *)ch 
                                   length:len 
                                 encoding:NSUTF8StringEncoding];
    [parser->_state.stringContent appendString:str];
    [str release];
    
drainAndReturn:
    [pool release];
}

void CSXXMLParserWarning(void *ctx, const char *msg, ...) {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSError *err;
    NSString *descr, *reco, *format;
    NSDictionary *userInfo;
    va_list argList;
    CSXXMLParser *parser;
    NSArray *stack;
    
    parser = (CSXXMLParser *)ctx;
    
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
    [stack release];
    [reco release];
    
    err = [NSError errorWithDomain:CSXXMLLibXMLErrorDomain 
                              code:CSXXMLLibXMLWarning 
                          userInfo:userInfo];
    
    [(NSMutableArray *)parser.warnings addObject:err];
    [pool release];
}

void CSXXMLParserError(void *ctx, const char *msg, ...) {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSError *err;
    NSString *descr, *reco, *format;
    NSDictionary *userInfo;
    va_list argList;
    CSXXMLParser *parser;
    NSArray *stack;
    
    parser = (CSXXMLParser *)ctx;
    
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
    [stack release];
    [reco release];
    
    err = [NSError errorWithDomain:CSXXMLLibXMLErrorDomain 
                              code:CSXXMLLibXMLError
                          userInfo:userInfo];
    
    parser.error = err;
    parser->_state.errorOccurred = YES;
    [pool release];
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
         
- (void)popStateElement:(NSString **)nameptr 
                 layout:(id *)lptr 
               instance:(id *)instptr 
{
    NSString *name;
    id layout, inst;
    
    assert(nameptr != NULL);
    assert(lptr != NULL);
    assert(instptr != NULL);
    
    name = [[_state.elementNameStack lastObject] retain];
    [_state.elementNameStack removeLastObject];
    
    layout = [[_state.elementLayoutStack lastObject] retain];
    [_state.elementLayoutStack removeLastObject];
    
    inst = [[_state.elementInstanceStack lastObject] retain];
    [_state.elementInstanceStack removeLastObject];
    
    *nameptr = [name autorelease];
    *lptr = [layout autorelease];
    *instptr = [inst autorelease];
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
     element is non-unique an NSMutableArray is returned. If the type is a 
     list an instance of the CSXElementList class is returned. */
    
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
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        
        cattrName = attrs[c];
        if(cattrName == NULL) {
            [pool release];
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
            [pool release];
            break;
        }
        
        c += 2;
        
        [pool release];
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
    [stack release];
    
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
    [stack release];
    
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
    [stack release];
    
    err = [NSError errorWithDomain:CSXXMLParserErrorDomain 
                              code:kCSXXMLParserElementValueNoBooleanError 
                          userInfo:userInfo];
    return err;
}
@end
