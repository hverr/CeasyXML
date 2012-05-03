/*
 *  CSXElementLayout+CSXLayoutObject.m
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

#import "CSXElementLayout+CSXLayoutObject.h"
#import "CSXElementLayoutPlacebo.h" // here to avoid import conflicts

static NSString * const CSXElementLayoutUniqueElementName = @"unique";
static NSString * const CSXElementLayoutEmptyElementName = @"empty";
static NSString * const CSXElementLayoutElementElementName = @"element";

@implementation CSXElementLayout (CSXLayoutObject)
/* MARK: Layout Objects */
+ (CSXElementLayout *)uniqueElementLayout {
    CSXElementLayout *layout;
    CSXNodeContentLayout *content;
    
    layout = [CSXElementLayout new];
    content = [CSXNodeContentLayout new];
    
    layout.name = CSXElementLayoutUniqueElementName;
    layout.required = YES;
    layout.empty = YES;
    layout.unique = YES;
    
    content.contentType = CSXNodeContentTypeBoolean;
    content.getter = @selector(unique);
    content.setter = @selector(setUnique:);
    
    layout.contentLayout = content;
    [content release];
    
    return [layout autorelease];
}

+ (CSXElementLayout *)emptyElementLayout {
    CSXElementLayout *layout;
    CSXNodeContentLayout *content;
    
    layout = [CSXElementLayout new];
    content = [CSXNodeContentLayout new];
    
    layout.name = CSXElementLayoutEmptyElementName;
    layout.required = YES;
    layout.empty = YES;
    layout.unique = YES;
    
    content.contentType = CSXNodeContentTypeBoolean;
    content.getter = @selector(empty);
    content.setter = @selector(setEmpty:);
    
    layout.contentLayout = content;
    [content release];
    
    return [layout autorelease];
}

+ (CSXElementLayout *)elementElementLayout {
    CSXElementLayout *layout;
    CSXNodeContentLayout *content;
    
    layout = [CSXElementLayout new];
    content = [CSXNodeContentLayout new];
    
    layout.name = CSXElementLayoutEmptyElementName;
    layout.required = NO;
    layout.empty = NO;
    layout.unique = NO;
    
    content.contentType = CSXNodeContentTypeCustom;
    content.customClass = [CSXElementLayout class];
    
    layout.contentLayout = content;
    [content release];
    
    layout.attributes = [NSArray arrayWithObjects:
                         [self nameAttributeLayout],
                         nil];
    
    layout.subelements = [NSArray arrayWithObjects:
                          [self attributeElementLayout],
                          [CSXElementLayoutPlacebo placebo],
                          [CSXNodeContentLayout contentElementLayout],
                          nil];
    return [layout autorelease];
}
@end
