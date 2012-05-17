/*
 *  CSXDocumentLayout.h
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
#import "CSXElementLayout.h"

extern NSString * const CSXDocumentLayoutInvalidClassException;

/*!
 `CSXDocumentLayout` represents one possible layout of a document. 
 
 The tagname for this element is `layout`. It can be a root element of a
 layout document, but it can also be a subelement of a `document` element
 used by the class `CSXLayoutList`.
 
 #Exceptions
 - CSXDocumentLayoutInvalidClassException
 
    Thrown when the class specified in the XML layout document could not be
    found.
 */

@interface CSXDocumentLayout : NSObject {
    NSString *name;
    NSArray *attributes;
    NSArray *subelements;
    Class documentClass;
}
/* MARK: Init */
/*! @name Creating and Initializing */
/*!
 Initiliaze a document from a layout document.
 
 The layout document should have `layout` as the root element tagname. The root
 element can contain subelements and attributes.
 
     <?xml version="1.0" ?>
    <layout name="root-element-name">
        <element name="myname">
            ...
        </element>
        ...
    </layout>
 
 @param doc The path to the layout document.
 
 @param err A pointer to a variable that can hold an error if one occurs. Pass
 `NULL` if you are not interested in errors. See the errors of `CSXXMLParser`
 for more information.
 
 @return An instance of `CSXDocumentLayout` or nil if an error occurred.
 
 @see CSXXMLParser
 */
- (id)initWithLayoutDocument:(NSString *)doc error:(NSError **)err;

/*!
 Returns the autoreleased result of initWithLayoutDocument:error:.
 
 @see initWithLayoutDocument:error:
 */
+ (id)documentLayoutWithLayoutDocument:(NSString *)doc error:(NSError **)err;

/* MARK: Properties */
/*! @name Properties */
/*!
 The name of the document element.
 */
@property (nonatomic, retain) NSString *name;

/*!
 The attributes of the document root element.
 
 The array contains instnaces of `CSXNodeLayout`.
 */
@property (nonatomic, retain) NSArray *attributes;

/*!
 The subelements of the document root element.
 
 The array contains instances of `CSXElementLayout`.
 */
@property (nonatomic, retain) NSArray *subelements;

/*!
 The user-defined document class.
 */
@property (nonatomic, assign) Class documentClass;

/*!
 Use this property to set the user-defined document class from a string.
 
 @exception CSXDocumentLayoutInvalidClassException Thrown when the class 
 represented by the string could not be found.
 
 @see documentClass
 */
@property (nonatomic, retain) NSString *documentClassString;

/*! @name Finding Subnodes */
/*!
 Linear search for a subelement with a known name.
 
 @param nam The name of the subelement.
 
 @return The found element or `nil` if no element could be found with the
 given name.
 
 @see CSXNodeLayout, subelements
 */
- (CSXElementLayout *)subelementWithName:(NSString *)nam;

/*!
 Linear search for the attribute with a known name.
 
 @param nam The name of the attribute.
 
 @return The found attribute or `nil` if no attribute could be found with the
 given name.
 
 @see CSXNodeLayout, attributes
 */
- (CSXNodeLayout *)attributeWithName:(NSString *)nam;
@end

