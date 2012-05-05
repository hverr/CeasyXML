/*
 *  CSXDocumentLayout+CSXLayoutObject.m
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

#import "CSXDocumentLayout+CSXLayoutObject.h"

static NSString * const CSXDocumentLayoutNameAttributeName = @"name";
static NSString * const CSXDocumentLayoutClassAttributeName = @"class";

static NSString * const CSXDocumentLayoutLayoutElementName = @"layout";
static NSString * const CSXDocumentLayoutDocumentElementName = @"document";

@implementation CSXDocumentLayout (CSXLayoutObject)
/* MARK: Various Attributes */
+ (CSXNodeLayout *)nameAttributeLayout {
    CSXNodeLayout *layout;
    CSXNodeContentLayout *content;
    
    layout = [CSXNodeLayout new];
    content = [CSXNodeContentLayout new];
    
    layout.name = CSXDocumentLayoutNameAttributeName;
    layout.required = YES;
    
    content.contentType = CSXNodeContentTypeString;
    content.getter = @selector(name);
    content.setter = @selector(setName:);
    
    layout.contentLayout = content;
    [content release];
    
    return [layout autorelease];
}

+ (CSXNodeLayout *)classAttributeLayout {
    CSXNodeLayout *layout;
    CSXNodeContentLayout *content;
    
    layout = [CSXNodeLayout new];
    content = [CSXNodeContentLayout new];
    
    layout.name = CSXDocumentLayoutClassAttributeName;
    layout.required = YES;
    
    content.contentType = CSXNodeContentTypeString;
    content.getter = @selector(documentClassString);
    content.setter = @selector(setDocumentClassString:);
    
    layout.contentLayout = content;
    [content release];
    
    return [layout autorelease];
}

/* MARK: Layout and Document */
+ (CSXElementLayout *)layoutElementLayout {
    CSXElementLayout *layout;
    CSXNodeContentLayout *content;
    
    layout = [CSXElementLayout new];
    content = [CSXNodeContentLayout new];
    
    layout.name = CSXDocumentLayoutLayoutElementName;
    layout.required = YES;
    layout.empty = NO;
    layout.unique = NO;
    
    content.contentType = CSXNodeContentTypeCustom;
    content.customClass = [CSXDocumentLayout class];
    
    layout.contentLayout = content;
    [content release];
    
    layout.attributes = [NSArray arrayWithObjects:
                         [self nameAttributeLayout],
                         [self classAttributeLayout],
                         nil];
    
    layout.subelements = [NSArray arrayWithObjects:
                          [CSXNodeLayout attributeElementLayout],
                          [CSXElementLayout elementElementLayout],
                          nil];
    
    return [layout autorelease];
}

+ (CSXDocumentLayout *)layoutDocumentLayout {
    CSXDocumentLayout *layout;
    
    layout = [CSXDocumentLayout new];
    
    layout.name = CSXDocumentLayoutLayoutElementName;
    layout.documentClass = [CSXDocumentLayout class];
    
    layout.attributes = [NSArray arrayWithObjects:
                         [self nameAttributeLayout],
                         [self classAttributeLayout],
                         nil];
    
    layout.subelements = [NSArray arrayWithObjects:
                       [CSXNodeLayout attributeElementLayout],
                       [CSXElementLayout elementElementLayout],
                       nil];
    
    return [layout autorelease];
}

@end
