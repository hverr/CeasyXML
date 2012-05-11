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

/* =========================================================================== 
 MARK: -
 MARK: Private Interface
 =========================================================================== */
@interface CSXXMLWriter (Private)
/* MARK: XML Writing */
- (NSError *)flushDocument;
- (NSError *)startDocument;
- (void)freeDocument;

/* MARK: Errors */
- (NSError *)textWriterForFileError:(NSString *)outFile;
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

- (void)freeDocument {
    xmlFreeTextWriter(_state.textWriter);
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
