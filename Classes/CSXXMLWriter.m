/*
 *  CSXXMLWriter.m
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

#import "CSXXMLWriter.h"

NSString * const CSXXMLWriterErrorDomain = @"CSXXMLWriterErrorDomain";

NSString * const CSXXMLWriterNoRootInstanceException =
    @"CSXXMLWriterNoRootInstanceException";
NSString * const CSXXMLWriterNoDocumentLayoutException =
    @"CSXXMLWriterNoDocumentLayoutException";
NSString * const CSXXMLWriterInvalidAttributeTypeException =
    @"CSXXMLWriterInvalidAttributeTypeException";

/* =========================================================================== 
 MARK: -
 MARK: Private Interface
 =========================================================================== */
@interface CSXXMLWriter (Private)
/* MARK: XML Writing */
- (NSError *)flushDocument;
- (NSError *)startDocument;
- (NSError *)endDocument;
- (void)freeDocument;
- (NSError *)writeRootElement;
- (NSError *)writeElement:(CSXElementLayout *)lay instance:(id)inst;
- (NSError *)writeNonUniqueElement:(CSXElementLayout *)lay instance:(id)inst;
- (NSError *)writeCustomElement:(CSXElementLayout *)lay instance:(id)inst;
- (NSError *)writeStringElement:(CSXElementLayout *)lay instance:(id)inst;
- (NSError *)writeBooleanElement:(CSXElementLayout *)lay instance:(id)inst;
- (NSError *)writeEmptyElement:(CSXElementLayout *)l instance:(id)inst;
- (NSError *)writeNumberElement:(CSXElementLayout *)lay instance:(id)inst;
- (NSError *)writeAttributesOfLayout:(CSXElementLayout *)lay instance:(id)inst;


/* MARK: Errors */
- (NSError *)textWriterForFileError:(NSString *)outFile;
- (NSError *)bufferCreateError;
- (NSError *)xmlWriteError;
@end

/* =========================================================================== 
 MARK: -
 MARK: Public Implementation
 =========================================================================== */
@implementation CSXXMLWriter
/* MARK: Init and Dealloc */
- (id)initWithDocumentLayout:(CSXDocumentLayout *)layout {
    self = [super init];
    if(self != nil) {
        self.documentLayout = layout;
    }
    return self;
}

+ (id)XMLWriterWithDocumentLayout:(CSXDocumentLayout *)layout {
    id inst;
    inst = [[self alloc] initWithDocumentLayout:layout];
    return [inst autorelease];
}

- (id)initWithLayoutDocument:(NSString *)f error:(NSError **)err {
    self = [super init];
    if(self != nil) {
        CSXDocumentLayout *layout;
        
        layout = [[CSXDocumentLayout alloc] initWithLayoutDocument:f error:err];
        if(layout == nil) {
            [self release];
            return nil;
        }
        self.documentLayout = layout;
    }
    return self;
}

+ (id)XMLWriterWithLayoutDocument:(NSString *)f error:(NSError **)err {
    id inst;
    inst = [[self alloc] initWithLayoutDocument:f error:err];
    return [inst autorelease];
}

- (void)dealloc {
    self.documentLayout = nil;
    self.rootInstance = nil;
    
    self.XMLVersion = nil;
    self.encoding = nil;
    
    [super dealloc];
}

/* MARK: Properties */
@synthesize documentLayout, rootInstance;
@synthesize XMLVersion, encoding, compression;


/* MARK: Writing */
- (BOOL)writeToFile:(NSString *)file error:(NSError **)errptr {
    NSError *myError;
    
    /* Create the text writer */
    _state.textWriter = xmlNewTextWriterFilename([file UTF8String], 
                                                 self.compression);
    if(_state.textWriter == NULL) {
        myError = [self textWriterForFileError:file];
        goto handleErrorAndReturn;
    }
    
    _state.isWritingToFile = YES;
    
    /* Start document */
    if((myError = [self startDocument])) {
        goto handleErrorAndReturn;
    }
    
    /* Write root element */
    if((myError = [self writeRootElement])) {
        goto handleErrorAndReturn;
    }
    
    /* End document */
    if((myError = [self endDocument])) {
        goto handleErrorAndReturn;
    }
    
    /* Free document and return */
    [self freeDocument];
    return YES;
    
handleErrorAndReturn:
    [self freeDocument];
    
    if(errptr) {
        *errptr = myError;
    }
    return NO;
}

- (NSData *)XMLDataWithError:(NSError **)errptr {
    NSError *myError;
    xmlBufferPtr myBuffer;
    NSData *myData;
    const xmlChar *bufData;
    int bufLen;
    
    _state.textWriter = NULL;
    
    myBuffer = xmlBufferCreate();
    if(myBuffer == NULL) {
        myError = [self bufferCreateError];
        goto handleErrorAndReturn;
    }
    
    /* Create the text writer */
    _state.textWriter = xmlNewTextWriterMemory(myBuffer, 0);
    if(_state.textWriter == NULL) {
        myError = [self textWriterForFileError:[NSString string]];
        goto handleErrorAndReturn;
    }
    
    _state.isWritingToFile = NO;
    
    /* Start document */
    if((myError = [self startDocument])) {
        goto handleErrorAndReturn;
    }
    
    /* Write root element */
    if((myError = [self writeRootElement])) {
        goto handleErrorAndReturn;
    }
    
    /* End document */
    if((myError = [self endDocument])) {
        goto handleErrorAndReturn;
    }
    
    /* Convert data */
    bufLen = xmlBufferLength(myBuffer);
    bufData = xmlBufferContent(myBuffer);
    myData = [[NSData alloc] initWithBytes:bufData
                                    length:(sizeof(*bufData) * bufLen)];
    
    /* Free buffer */
    xmlBufferFree(myBuffer);
    
    /* Free document and return */
    [self freeDocument];
    [myData autorelease];
    
handleErrorAndReturn:
    [self freeDocument];
    
    if(myBuffer) {
        xmlBufferFree(myBuffer);
    }
    
    if(errptr) {
        *errptr = myError;
    }
    return nil;
}
@end


/* =========================================================================== 
 MARK: -
 MARK: Private Implementation
 =========================================================================== */
@implementation CSXXMLWriter (Private)
/* MARK: XML Writing */
- (NSError *)flushDocument {
    int status;
    
    if(_state.isWritingToFile == NO) {
        return nil;
    }
    
    status = xmlTextWriterFlush(_state.textWriter);
    if(status < 0) {
        return [self xmlWriteError];
    }
    
    return nil;
}

- (NSError *)startDocument {
    int status;
    
    status = xmlTextWriterStartDocument(_state.textWriter, 
                                        [self.XMLVersion UTF8String], 
                                        [self.encoding UTF8String], 
                                        NULL);
    
    if(status < 0) {
        return [self xmlWriteError];
    }
    
    return [self flushDocument];
}

- (NSError *)endDocument {
    int status;
    
    status = xmlTextWriterEndDocument(_state.textWriter);
    
    if(status < 0) {
        return [self xmlWriteError];
    }
    
    return [self flushDocument];
}

- (void)freeDocument {
    xmlFreeTextWriter(_state.textWriter);
}

- (NSError *)writeRootElement {
    NSString *excName, *excReason;
    NSError *myError;
    
    /* Check necessary instance variables */
    if(self.rootInstance == nil) {
        excName = CSXXMLWriterNoRootInstanceException;
        excReason = [NSString stringWithFormat:
                     @"%@ has no root instance set.",
                     [self description]];
        [[NSException exceptionWithName:excName reason:excReason userInfo:nil]
         raise];
    
    } else if(self.documentLayout == nil) {
        excName = CSXXMLWriterNoDocumentLayoutException;
        excReason = [NSString stringWithFormat:
                     @"%@ has no document layout set.",
                     [self description]];
        [[NSException exceptionWithName:excName reason:excReason userInfo:nil]
         raise];
        
    }
    
    /* Write root element */
    _state.indentationLevel = 0;
    myError = [self writeCustomElement:(CSXElementLayout *)self.documentLayout 
                              instance:self.rootInstance];
    if(myError != nil) {
        return myError;
    }
    
    return nil;
}

- (NSError *)writeElement:(CSXElementLayout *)lay instance:(id)inst {
    NSError *myErr;
    id subElement;
    
    if(lay.unique == NO) {
        for(subElement in (NSArray *)inst) {
            NSAutoreleasePool *pool = [NSAutoreleasePool new];
            
            myErr = [self writeNonUniqueElement:lay instance:subElement];
            
            [myErr retain];
            [pool release];
            [myErr autorelease];
            
            if(myErr != nil) {
                return myErr;
            }
        }
        
        return nil;
    }
    
    if(lay.empty == YES) {
        switch(lay.contentLayout.contentType) {
            case CSXNodeContentTypeBoolean:
                myErr = [self writeEmptyElement:lay instance:nil];
                break;
                
            case CSXNodeContentTypeCustom:
                myErr = [self writeEmptyElement:lay instance:inst];
                break;
                
            default:
                myErr = nil;
                break;
        }
        
    } else {
        switch(lay.contentLayout.contentType) {
            case CSXNodeContentTypeCustom:
                myErr = [self writeCustomElement:lay instance:inst];
                break;
                
            case CSXNodeContentTypeString:
                myErr = [self writeStringElement:lay instance:inst];
                break;
                
            case CSXNodeContentTypeBoolean:
                myErr = [self writeBooleanElement:lay instance:inst];
                break;
                
            case CSXNodeContentTypeNumber:
                myErr = [self writeNumberElement:lay instance:inst];
                break;
                
            default:
                myErr = nil;
                break;
        }
    }
    
    return myErr;
}

- (NSError *)writeNonUniqueElement:(CSXElementLayout *)lay instance:(id)inst {
    NSError *myErr;
    
    if(lay.empty == YES) {
        switch(lay.contentLayout.contentType) {
            case CSXNodeContentTypeBoolean:
                myErr = [self writeEmptyElement:lay instance:nil];
                break;
                
            case CSXNodeContentTypeCustom:
                myErr = [self writeEmptyElement:lay instance:inst];
                break;
                
            default:
                myErr = nil;
                break;
        }
        
    } else {
        switch(lay.contentLayout.contentType) {
            case CSXNodeContentTypeCustom:
                myErr = [self writeCustomElement:lay instance:inst];
                break;
                
            case CSXNodeContentTypeString:
                myErr = [self writeStringElement:lay instance:inst];
                break;
                
            case CSXNodeContentTypeBoolean:
                myErr = [self writeBooleanElement:lay instance:inst];
                break;
                
            case CSXNodeContentTypeNumber:
                myErr = [self writeNumberElement:lay instance:inst];
                break;
                
            default:
                myErr = nil;
                break;
        }
    }
    
    return myErr;
}

- (NSError *)writeCustomElement:(CSXElementLayout *)lay instance:(id)inst {
    int status;
    NSError *myError;
    xmlChar *indentation, *elemName;
    CSXElementLayout *subLayout;
    id subInst;
    
    /* Indent */
    indentation = NSStringCSXXMLCharIndentation(1, _state.indentationLevel);
    status = xmlTextWriterWriteRaw(_state.textWriter, indentation);
    free(indentation);
    if(status < 0) {
        return [self xmlWriteError];
    }
    
    /* Start element */
    elemName = [lay.name copyXMLCharacters];
    status = xmlTextWriterStartElement(_state.textWriter, elemName);
    free(elemName);
    if(status < 0) {
        return [self xmlWriteError];
    }
    
    /* Write attributes */
    myError = [self writeAttributesOfLayout:lay instance:inst];
    if(myError != nil) {
        return myError;
    }
    
    /* Write subelements */
    for(subLayout in lay.subelements) {
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        
        myError = nil;
        subInst = objc_msgSend(inst, subLayout.contentLayout.getter);
        if(subInst != nil || subLayout.required == YES) {
            _state.indentationLevel++;
            myError = [self writeElement:subLayout instance:subInst];
            _state.indentationLevel--;
        }
        
        [myError retain];
        [pool release];
        [myError autorelease];
        
        if(myError != nil) {
            return myError;
        }
    }
    
    /* Indent */
    indentation = NSStringCSXXMLCharIndentation(1, _state.indentationLevel);
    status = xmlTextWriterWriteRaw(_state.textWriter, indentation);
    free(indentation);
    if(status < 0) {
        return [self xmlWriteError];
    }
    
    /* Close element */
    status = xmlTextWriterEndElement(_state.textWriter);
    if(status < 0) {
        return [self xmlWriteError];
    }
        
    return [self flushDocument];
}

- (NSError *)writeStringElement:(CSXElementLayout *)lay instance:(id)inst {
    int status;
    NSError *myError;
    xmlChar *indentation, *elemName, *elemValue;
    
    /* Indent */
    indentation = NSStringCSXXMLCharIndentation(1, _state.indentationLevel);
    status = xmlTextWriterWriteRaw(_state.textWriter, indentation);
    free(indentation);
    if(status < 0) {
        return [self xmlWriteError];
    }
    
    /* Start element */
    elemName = [lay.name copyXMLCharacters];
    status = xmlTextWriterStartElement(_state.textWriter, elemName);
    free(elemName);
    if(status < 0) {
        return [self xmlWriteError];
    }
    
    /* Write attributes */
    myError = [self writeAttributesOfLayout:lay instance:inst];
    if(myError != nil) {
        return myError;
    }
    
    /* Write content */
    elemValue = [(NSString *)inst copyXMLCharacters];
    if(elemValue == NULL) {
        elemValue = calloc(1, 1);
    }
    status = xmlTextWriterWriteString(_state.textWriter, elemValue);
    free(elemValue);
    if(status < 0) {
        return myError;
    }
    
    /* End element */
    status = xmlTextWriterFullEndElement(_state.textWriter);
    if(status < 0) {
        return [self xmlWriteError];
    }
    
    return [self flushDocument];
}

- (NSError *)writeBooleanElement:(CSXElementLayout *)lay instance:(id)inst {
    BOOL boolVal;
    NSString *stringVal;
    
    *(id *)&boolVal = inst;
    stringVal = boolVal ? @"1" : @"0";
    
    return [self writeStringElement:lay instance:stringVal];
}

- (NSError *)writeNumberElement:(CSXElementLayout *)lay instance:(id)inst {
    NSInteger intVal;
    NSString *stringVal;
    
    *(id *)&intVal = inst;
    stringVal = [[NSNumber numberWithInteger:intVal] stringValue];
    
    return [self writeStringElement:lay instance:stringVal];
}

- (NSError *)writeEmptyElement:(CSXElementLayout *)l instance:(id)inst {
    int status;
    NSError *myError;
    xmlChar *indentation, *elemName;
    
    /* Indent */
    indentation = NSStringCSXXMLCharIndentation(1, _state.indentationLevel);
    status = xmlTextWriterWriteRaw(_state.textWriter, indentation);
    free(indentation);
    if(status < 0) {
        return [self xmlWriteError];
    }
    
    /* Start element */
    elemName = [l.name copyXMLCharacters];
    status = xmlTextWriterStartElement(_state.textWriter, elemName);
    free(elemName);
    if(status < 0) {
        return [self xmlWriteError];
    }
    
    /* Write attributes */
    myError = [self writeAttributesOfLayout:l instance:inst];
    if(myError != nil) {
        return myError;
    }
    
    /* End element */
    status = xmlTextWriterEndElement(_state.textWriter);
    if(status < 0) {
        return [self xmlWriteError];
    }
    
    return [self flushDocument];
}

- (NSError *)writeAttributesOfLayout:(CSXElementLayout *)lay instance:(id)inst {
    int status;
    CSXNodeLayout *attrLayout;
    NSString *strValue;
    BOOL boolVal;
    NSInteger intVal;
    xmlChar *attrName, *attrValue;
    NSString *excName, *excReason;
    
    for(attrLayout in lay.attributes) {
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        
        switch(attrLayout.contentLayout.contentType) {
            case CSXNodeContentTypeString:
                strValue = objc_msgSend(inst, attrLayout.contentLayout.getter);
                break;
                
            case CSXNodeContentTypeBoolean:
                *(id *)&boolVal = 
                    objc_msgSend(inst, attrLayout.contentLayout.getter);
                strValue = boolVal ? @"1" : @"0";
                break;
                
            case CSXNodeContentTypeNumber:
                intVal = (NSInteger)
                    objc_msgSend(inst, attrLayout.contentLayout.getter);
                strValue = [[NSNumber numberWithInteger:intVal] stringValue];
                break;
            
            case CSXNodeContentTypeCustom:
            default:
                excName = CSXXMLWriterInvalidAttributeTypeException;
                excReason = [NSString stringWithFormat:
                             @"The attribute %@ with layout %@ has an invalid "
                             @"content type.",
                             attrLayout.name, attrLayout];
                [[NSException exceptionWithName:excName 
                                         reason:excReason 
                                       userInfo:nil] raise];
                break;
        }
        
        attrName = [attrLayout.name copyXMLCharacters];
        attrValue = [strValue copyXMLCharacters];
        
        [pool release];
        
        status = xmlTextWriterWriteAttribute(_state.textWriter, 
                                             attrName, attrValue);
        free(attrName);
        free(attrValue);
        if(status < 0) {
            return [self xmlWriteError];
        }
    }
    
    return nil;
}

/* MARK: Errors */
- (NSError *)textWriterForFileError:(NSString *)outFile {
    NSString *descr, *reco;
    NSDictionary *userInfo;
    NSError *err;
    
    descr = [NSString stringWithFormat:
             @"Failed to write the XML document."];
    reco = [NSString stringWithFormat:
            @"Could not create an XML writer for the file at %@.",
            outFile];
    userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                descr, NSLocalizedDescriptionKey,
                reco, NSLocalizedRecoverySuggestionErrorKey,
                nil];
    
    err = [NSError errorWithDomain:CSXXMLWriterErrorDomain 
                              code:kCSXXMLWriterTextWriterCreationError 
                          userInfo:userInfo];
    return err;
}

- (NSError *)bufferCreateError {
    NSString *descr, *reco;
    NSDictionary *userInfo;
    NSError *err;
    
    descr = [NSString stringWithFormat:
             @"Failed to write the XML document."];
    reco = [NSString stringWithFormat:
            @"Could not create a buffer to write the XML data."];
    userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                descr, NSLocalizedDescriptionKey,
                reco, NSLocalizedRecoverySuggestionErrorKey,
                nil];
    
    err = [NSError errorWithDomain:CSXXMLWriterErrorDomain 
                              code:kCSXXMLWriterBufferCreateError
                          userInfo:userInfo];
    return err;
}

- (NSError *)xmlWriteError {
    NSString *descr, *reco;
    NSDictionary *userInfo;
    NSError *err;
    
    descr = [NSString stringWithFormat:
             @"Failed to write the XML document."];
    reco = [NSString stringWithFormat:
            @"Could not write the characters to the file."];
    userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                descr, NSLocalizedDescriptionKey,
                reco, NSLocalizedRecoverySuggestionErrorKey,
                nil];
    
    err = [NSError errorWithDomain:CSXXMLWriterErrorDomain 
                              code:kCSXXMLWriterTextWriterWriteError 
                          userInfo:userInfo];
    return err;
}
@end
