/*
 *  CSXNodeContentLayout.h
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

/*!
 `CSXNodeContentLayout` represents the content type of an XML element.
 
 #Exceptions
 - `CSXNodeLayoutInvalidContentTypeIdentifierException`
 
     The exception thrown when the property `contentTypeIdentifier` is set to
     an invalid string.
 
 - `CSXNodeLayoutClassNotFoundException`
 
     The exception thrown when the property `customClassString` is set to a 
     class which cannot be found.
 
 - `CSXNodeLayoutSelectorNotFoundException`
 
     The exception thrown when the property `setterString` or the property
     `getterString` is set to a selector which cannot be found.
 
 #Constants
 - Type identifiers (`NSString`)
 
    The identifiers that are used in the XML documents and that can be passed
    to the property `contentTypeIdentifier` to set the content type.
 
     - `CSXNodeContentTypeStringIdentifier`
     
         The identifier that represents `CSXNodeContentTypeString`.
     
     - `CSXNodeContentTypeNumberIdentifier`
     
         The identifier that represents `CSXNodeContentTypeString`.
     
     - `CSXNodeContentTypeBooleanIdentifier`
     
         The identifier that represents `CSXNodeContentTypeBoolean`.
     
     - `CSXNodeContentTypeCustomIdentifier`
     
         The identifier that represents `CSXNodeContentTypeCustom`.
 
 - enum `CSXNodeContentType`
 
    The available types for the property `contentType`.
 
    - `CSXNodeContentTypeString`
    
        The type that represents a string. This type represents an instance of
        `NSString`
    
    - `CSXNodeContentTypeNumber`
        
        The type of a signed integer. This type represents an `NSInteger`
        scalar value.
    
    - `CSXNodeContentTypeBoolean`
 
        The type of a boolean. This type represents a `BOOL`.
 
    - `CSXNodeContentTypeCustom`
 
        The type of a user-defined custom class. The class will be initialized
        using `[[Class alloc] init]`, after which the properties will be set
        according to the subelements.
 */

extern NSString * const CSXNodeLayoutInvalidContentTypeIdentifierException;
extern NSString * const CSXNodeLayoutClassNotFoundException;
extern NSString * const CSXNodeLayoutSelectorNotFoundException;

extern NSString * const CSXNodeContentTypeStringIdentifier;
extern NSString * const CSXNodeContentTypeNumberIdentifier;
extern NSString * const CSXNodeContentTypeBooleanIdentifier;
extern NSString * const CSXNodeContentTypeCustomIdentifier;

typedef enum {
    CSXNodeContentTypeString,
    CSXNodeContentTypeNumber,
    CSXNodeContentTypeBoolean,
    CSXNodeContentTypeCustom
} CSXNodeContentType;

@interface CSXNodeContentLayout : NSObject {
    CSXNodeContentType contentType;
    SEL setter;
    SEL getter;
    Class customClass;
}
/* MARK: Properties */
/*! @name Properties */
/*! 
 The content type. 
 
 @see CSXNodeContentType
 */
@property (nonatomic, assign) CSXNodeContentType contentType;

/*!
 The setter for this property.
 
 The parser will use this selector to set the parsed value for the parent
 instance.
 */
@property (nonatomic, assign) SEL setter;

/*!
 The getter for this property.
 
 The writer will use this selector to get the value from the parent instance.
 */
@property (nonatomic, assign) SEL getter;

/*!
 The custom, user-defined class to use when the type is 
 `CSXNodeContentTypeCustom`.
 
 @see CSXNodeContentTypeCustom.
 */
@property (nonatomic, assign) Class customClass;

/*!
 Use this property to get and set the string identifier of a content type.
 
 @exception CSXNodeLayoutInvalidContentTypeIdentifierException Thrown when 
 the passed string does not represent a valid type.
 
 @see contentType
 */
@property (nonatomic, retain) NSString *contentTypeIdentifier;

/*!
 Use this property to get and set the string representation of the custom class
 property.
 
 @exception CSXNodeLayoutClassNotFoundException Thrown when
 the class represented by the string could not be found.
 
 @see customClass
 */
@property (nonatomic, retain) NSString *customClassString;

/*!
 Use this property to get and set the string representation of the selector to
 set the property.
 
 @exception CSXNodeLayoutSelectorNotFoundException Thrown when the selector
 could not be found.
 
 @see setter
 */
@property (nonatomic, retain) NSString *setterString;

/*!
 Use this property to get and set the string representation of the selector to
 get the property.
 
 @exception CSXNodeLayoutSelectorNotFoundException Thrown when the selector
 could not be found.
 
 @see getter
 */
@property (nonatomic, retain) NSString *getterString;
@end

