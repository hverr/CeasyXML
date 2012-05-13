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
#import <objc/runtime.h>
#import <libxml/parser.h>

#import "CSXLayoutList.h"
#import "CSXDocumentLayout.h"
#import "CSXElementLayout.h"
#import "CSXElementList.h"

/*!
 The class `CSXXMLParser` is used to parse an XML document with a predefined
 layout.
 
 You must pass one or more instances of `CSXDocumentLayout` to let the parser
 parse your XML document. The parser is able to decide what layout it will use
 based on the tagname of the root element of your XML document.
 
 #Example
 
    CSXXMLParser *parser;
    NSString *documentLayoutFile;
    NSString *xmlFile;
    NSError *myError;
    BOOL success;
 
    // Set the documents
    documentLayoutFile = // file representing a CSXDocumentLayout here
    xmlFile = // your XML document here
 
    // Create a parser with one possible document layout, contained in
    // a layout file.
    parser = [CSXXMLParser XMLParserWithLayoutDocument:documentLayoutFile
                                                 error:&myError];
    
    // Check if we could parse the layout file
    if(parser == nil) {
        NSLog(@"Failed to parse the layout file: %@", myError);
        exit(1);
    }
 
    // Set the file
    parser.file = xmlFile;
 
    // Parse your XML document
    success = [parser parse];
    if(success == NO) {
        NSLog(@"Failed to parse the XML document: %@", parser.error);
        exit(1);
    }
 
    if([parser.warnings count] != 0) {
        NSLog(@"Warnings while parsing the XML document: %@", parser.warnings);
    }
 
    NSLog(@"Result: %@", parser.result);
 
 #Errors
 
 Errors are instances of `NSError`. The possible domains and codes for these
 errors can be found below. The localized description and the localized
 recovery suggestion is always set. Besides these two properties some errors
 also set the `CSXXMLParserElementNameStackKey` key of the user info 
 dictionary to the stack of the XML document where the error was encountered.
 
 - Domains (`NSString`)
    
    The error domains used by `CSXXMLParser`.
 
    - `CSXXMLParserErrorDomain`
        
        Errors which are encountered by the class itself while parsing the
        document.
 
    - `CSXXMLLibXMLErrorDomain`
    
        Errors which are encountered while LibXML was parsing the document.
 
 - `CSXXMLParserErrorDomain` error codes
 
    The error codes used for errors in the `CSXXMLParserErrorDomain`.
 
    - `kCSXXMLParserUnkownDocumentTypeError`
 
        The parser is unable to find a `CSXDocumentLayout` for the tag name
        of the document root element.
    
    - `kCSXXMLParserElementValueNoNumberError`
    
        The value of an element is not a number, although the layout type
        states that it must be.
 
    - `kCSXXMLParserElementValueNoBooleanError`
 
        The value of an element is not a boolean, although the layout type
        states that it must be.
 
    - `kCSXXMLParserRequiredPropertyNotSetError`
 
        A required XML element or node is not found in the document, although
        it is specified as required.
 
 - `CSXXMLLibXMLErrorDomain` error codes
 
    The error codes used for errors in the `CSXXMLLibXMLErrorDomain`.
 
    - `CSXXMLLibXMLWarning`
        
        Used for a warning thrown by LibXML.
 
    - `CSXXMLLibXMLError`
 
        Used for an error thrown by LibXML.
 
 - User info dictionary keys (`NSString`)
 
    These self-defined keys may be set in the user info dictionary of the
    returned `NSError`.
 
    - `CSXXMLParserElementNameStackKey`
        
        The value for this key contains an array with the tagnames of the
        stack until the element where the error occurred.
 
 #Exceptions
 
 - `CSXXMLParserNoDataException`
 
    Thrown when the property file and the property data are both not set when
    the method parse is invoked.
 */

extern NSString * const CSXXMLParserErrorDomain;
extern NSString * const CSXXMLLibXMLErrorDomain;

extern NSString * const CSXXMLParserDocumentClassNullException;
extern NSString * const CSXXMLParserElementClassNullException;

extern NSString * const CSXXMLParserNoDataException;
extern NSString * const CSXXMLParserInvalidArgumentContentTypeException;

extern NSString * const CSXXMLParserElementNameStackKey;

enum {
    kCSXXMLParserUnkownDocumentTypeError = 1,
    kCSXXMLParserElementValueNoNumberError,
    kCSXXMLParserElementValueNoBooleanError,
    kCSXXMLParserRequiredPropertyNotSetError
};

enum {
    CSXXMLLibXMLWarning = 1,
    CSXXMLLibXMLError
};

@interface CSXXMLParser : NSObject {
    NSError *_parseError;
    NSMutableArray *_warnings;
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
        
        NSMutableString *stringContent;
    } _state;
}
/* MARK: Init */
/*! @name Creating and Initializing */
/*!
 Create a parser with the given document layouts.
 
 @param docLayouts An error containing valid instances of `CSXDocumentLayout`.
 
 @see CSXDocumentLayout
 */
- (id)initWithDocumentLayouts:(NSArray *)docLayouts;
/*!
 Returns the autoreleased result of initWithDocumentLayouts:.
 
 @see initWithDocumentLayouts
 */
+ (id)XMLParserWithDocumentLayouts:(NSArray *)docLayouts;

/*!
 Creates a parser with all the document layouts in a file.
 
 This is equivalent to first creating a `CSXLayoutList` and then calling
 initWithDocumentLayouts:.
 
 @see [CSXLayoutList initWithDocument:error:]
 */
- (id)initWithLayoutListDocument:(NSString *)f error:(NSError **)err;

/*!
 Returns the autoreleased result of initWithLayoutListDocument:error:.
 
 @see initWithLayoutListDocument:error:
 */
+ (id)XMLParserWithLayoutListDocument:(NSString *)f error:(NSError **)err;

/*!
 Returns a parser with the one layout of the file.
 
 This is equivalent to first creation a `CSXDocumentLayout` and then calling
 initWithDocumentLayouts: with an array containing the document layout.
 
 @see [CSXDocumentLayout initWithLayoutDocument:error:]
 */
- (id)initWithLayoutDocument:(NSString *)f error:(NSError **)err;

/*!
 Returns the autoreleased result of initWithLayoutDocument:error:.
 
 @see initWithLayoutDocument:error
 */
+ (id)XMLParserWithLayoutDocument:(NSString *)f error: (NSError **)err;

/* MARK: Properties */
/*! @name Properties */
/*!
 The possible document layouts for your XML document.
 
 The array must contain instances of `CSXDocumentLayout`. The parser will
 decide for itself which layout it will use based on the root element tagname
 of your XML document.
 
 @see CSXDocumentLayout
 */
@property (nonatomic, retain) NSArray *documentLayouts;

/*!
 The file containing your XML document.
 
 If this property is set the property data is ignored.
 
 @see data
 */
@property (nonatomic, retain) NSString *file;

/*! 
 An instance of `NSData` containing your XML document in UTF-8.
 
 This property has a lower priority than the property file.
 
 @see file
 */
@property (nonatomic, retain) NSData *data;

/*!
 The error that occurred when the method parse returns `NO`.
 */
@property (nonatomic, retain, readonly) NSError *error;

/*!
 The warnings that LibXML gave us while parsing.
 
 The array contains instances of `NSError`.
 */
@property (nonatomic, retain, readonly) NSArray *warnings;

/*!
 The setup instance of your custom class that represents your XML document.
 */
@property (nonatomic, retain, readonly) id result;

/* MARK: Parsing */
/*! @name Parsing */
/*!
 Parse the document.
 
 @return `YES` if parsing was successful and `NO` if an error occurred. The
 method still returns `YES` if only warnings did occur.
 
 @exception CSXXMLParserNoDataException Thrown when neither the data or the file
 property are set.
 */
- (BOOL)parse;
@end

