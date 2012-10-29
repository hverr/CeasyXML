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
#import <objc/message.h>
#import <libxml/xmlwriter.h>

#import "CSXDocumentLayout.h"
#import "CSXElementLayout.h"
#import "CSXElementLayout.h"

#import "NSString+CSXLibXMLConversion.h"

/*!
 The class `CSXXMLWriter` is used to write an XML document with a predefined
 layout.
 
 Using a `CSXDocumentLayout` and an instance of your document class, this class
 can write out an XML document to a file and to the memory.
 
 #Errors
 
 Errors are instances of `NSError`. The localized description and localized
 recovery suggestion are set.
 
 - Domains (`NSString`)
    - `CSXXMLWriterErrorDomain`
        This class uses this custom error domain.

 - Error codes
    - `kCSXXMLWriterTextWriterCreationError`
 
        The writer can not create an instance of the LibXML text writer.
 
    - `kCSXXMLWriterTextWriterWriteError`
 
        An error occurred while trying to write with the LibXLM text writer
        instance.
 
    - `kCSXXMLWriterBufferCreateError`

        An error occurred while trying to create the LibXML buffer.
 
 #Exceptions
 
 - `CSXXMLWriterNoRootInstanceException`
 
    Thrown when the property `rootInstance` is not set when a write method
    is invoked.
 
 - `CSXXMLWriterNoDocumentLayoutException`
 
    Thrown when the property `documentLayout` is not set when a write method
    is invoked.
 
 - `CSXXMLWriterInvalidAttributeTypeException`
 
    Thrown when trying to write an object's attribute which `CSXNodeContentLayout`
    specifies a type not available for an attribute.
 */

extern NSString * const CSXXMLWriterErrorDomain;

extern NSString * const CSXXMLWriterNoRootInstanceException;
extern NSString * const CSXXMLWriterNoDocumentLayoutException;
extern NSString * const CSXXMLWriterInvalidAttributeTypeException;

enum {
    kCSXXMLWriterTextWriterCreationError = 1,
    kCSXXMLWriterTextWriterWriteError,
    kCSXXMLWriterBufferCreateError
};

@interface CSXXMLWriter : NSObject {
    CSXDocumentLayout *documentLayout;
    id rootInstance;
    NSString *XMLVersion;
    NSString *encoding;
    int compression;
    
    struct {
        BOOL isWritingToFile;
        xmlTextWriterPtr textWriter;
        NSInteger indentationLevel;
    } _state;
}
/* MARK: Init */
/*! @name Creating and Initializing */
/*!
 Initialize an instance with a given document layout.
 
 @param layout A valid instance of `CSXDocumentLayout` representing the
 layout of your XML document.
 */
- (id)initWithDocumentLayout:(CSXDocumentLayout *)layout;

/*!
 Returns the autoreleased result of initWithDocumentLayout:.
 
 @see initWithDocumentLayout:
 */
+ (id)XMLWriterWithDocumentLayout:(CSXDocumentLayout *)layout;

/*!
 Initialize an instance with the `CSXDocumentLayout` contained by the given
 layout document.
 
 Using this function is equivalent to calling 
 [CSXDocumentLayout initWithLayoutDocument:error:] and than calling
 initWithDocumentLayout:.
 
 @see [CSXDocumentLayout initWithLayoutDocument:error:]
 */
- (id)initWithLayoutDocument:(NSString *)f error:(NSError **)err;

/*!
 Returns the autoreleased result of initWithLayoutDocument:error:.
 
 @see initWithLayoutDocument:error:
 */
+ (id)XMLWriterWithLayoutDocument:(NSString *)f error:(NSError **)err;

/* MARK: Properties */
/*! @name Properties */
/*!
 The document layout of your XML document.
 */
@property (nonatomic, retain) CSXDocumentLayout *documentLayout;

/*!
 An instance of your custom class containing the document content.
 */
@property (nonatomic, retain) id rootInstance;

/*!
 The XML version.
 
 This defaults to the LibXML default.
 */
@property (nonatomic, retain) NSString *XMLVersion;

/*!
 The encoding of the file.
 
 This defaults to the LibXML default.
 */
@property (nonatomic, retain) NSString *encoding;

/*!
 The compression.
 
 This defaults to 0. See the LibXLM manual for more information.
 */
@property (nonatomic, assign) int compression;

/* MARK: Writing */
/*! @name Writing */
/*!
 Use this method to write the XML document to a file.
 
 @param file The output file.
 
 @param errptr A variable capable of holding the error if one occurs.
 
 @return `YES` if the writing was successful or `NO` if an error occurred.
 
 @exception CSXXMLWriterNoRootInstanceException Thrown when the property
 `rootInstance` is not set.
 
 @exception CSXXMLWriterNoDocumentLayoutException Thrown when the property
 `documentLayout` is not set.
 
 @exception CSXXMLWriterInvalidAttributeTypeException Thrown when an invalid
 attribute type is met while writing out the document.
 */
- (BOOL)writeToFile:(NSString *)file error:(NSError **)errptr;

/*!
 Use this method to write the XML document to an `NSData` buffer.
 
 @param errptr A variable capable of holding the error if one occurs.
 
 @return An autoreleased instance of `NSData` if the write was successful or
 nil if an error occurred.
 
 @exception CSXXMLWriterNoRootInstanceException Thrown when the property
 `rootInstance` is not set.
 
 @exception CSXXMLWriterNoDocumentLayoutException Thrown when the property
 `documentLayout` is not set.
 
 @exception CSXXMLWriterInvalidAttributeTypeException Thrown when an invalid
 attribute type is met while writing out the document.
 */
- (NSData *)XMLDataWithError:(NSError **)errptr;

/*!
 Use this method to write the root element to a self created LibXML writer.
 
 @param theWriter A valid initialized instance of `xmlTextWriter` to which you
 want to add the root element.
 
 @param indentation The indentation of the root element.
 
 @param errptr A variable capable of holding the error if one occurs.
 
 @return `YES` if the writing was successful and `NO` otherwise.
 
 @exception CSXXMLWriterNoRootInstanceException Thrown when the property
 `rootInstance` is not set.
 
 @exception CSXXMLWriterNoDocumentLayoutException Thrown when the property
 `documentLayout` is not set.
 
 @exception CSXXMLWriterInvalidAttributeTypeException Thrown when an invalid
 attribute type is met while writing out the document.
 */
- (BOOL)writeRootElementToTextWriter:(xmlTextWriterPtr)theWriter
                         indentation:(NSInteger)indentation
                               error:(NSError **)errptr;
@end

