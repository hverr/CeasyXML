/*
 *  CSXLayoutList.h
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

#import "CSXDocumentLayout.h"
#import "CSXXMLParser.h"

/*!
 `CSXLayoutList` represents a collection of possible layouts for one document.
 
 The XML document root element tagname is `document`. This root element
 contains element with the tagname `layout`, which represent instances of
 `CSXDocumentLayout`.
 */

@interface CSXLayoutList : NSObject {
    NSMutableArray *layouts;
}
/* MARK: Init */
/* @name Creating and Initializing */
/*!
 Creates an instance from an XML document.
 
 The document must have a root element with tagname `document`. This element
 must contain one or more elements with tag name `layout`.
 
     <?xml version="1.0" ?>
     <document>
         <layout name="first-layout">
             ...
         </layout>
 
         <layout name="second-layout">
         </layout>
        
         ...
     </document>
 
 @param doc The path to the XML document.
 
 @param err A variable capable of holding an `NSError` if an error occurs.
 Pass `NULL` if you are not interested in the error.
 
 @return A new instance or `nil` if an error occurred.
 */
- (id)initWithDocument:(NSString *)doc error:(NSError **)err;

/*!
 Returns the autoreleased result of initWithDocument:error:
 
 @see initWithDocument:error:
 */
+ (id)layoutListWithDocument:(NSString *)doc error:(NSError **)err;

/* MARK: Properties */
/*! @name Properties */
/*!
 The possible layouts of a document.
 
 The array contains instances of `CSXDocumentLayout`.
 
 @see CSXDocumentLayout
 */
@property (nonatomic, retain) NSMutableArray *layouts;
@end

