/*
 *  CSXElementLayout.h
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

#import "CSXNodeLayout.h"

/*!
 `CSXElementLayout` represents an XML element.
 */

@interface CSXElementLayout : CSXNodeLayout {
    
}
/* MARK: Properties */
/*! @name Properties */
/*!
 Specifies wether the element is an empty element or not.
 
 If this is set to `YES`, the element should look like this:
     
     <element />

 If this is not true, the element should look like this:
 
    <element>SOME_CONTENT</element>

*/
@property (nonatomic, assign) BOOL empty;


/*!
 Specifies wether the element is unique or not.
 
 If this is set to `NO`, the instance variable of the parent should be an
 `NSMutableArray`, as the parser will set the instance variable to an instance 
 of `NSMutableArray` containing all the elements.
 
 If this is set to `YES`, the parser will just set the instance variable to 
 an instance of the content type.
 */
 
@property (nonatomic, assign) BOOL unique;

/*!
 The attributes this element has.
 
 The array should contain instances of `CSXNodeLayout`.
 
 @see CSXNodeLayout
 */
@property (nonatomic, retain) NSArray *attributes;

/*!
 The subelements of this element.
 
 This property is only used when the `contentLayout` is of type 
 `CSXNodeContentTypeCustom`.
 
 @see CSXNodeLayout
 */
@property (nonatomic, retain) NSArray *subelements;

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

