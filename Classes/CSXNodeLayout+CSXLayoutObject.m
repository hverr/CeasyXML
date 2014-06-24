/*
 *  CSXNodeLayout+CSXLayoutObject.m
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

#import "CSXNodeLayout+CSXLayoutObject.h"

static NSString * const CSXNodeLayoutNameAttributeName = @"name";
static NSString * const CSXNodeLayoutAttributeElementName = @"attribute";
static NSString * const CSXNodeLayoutRequiredElementName = @"required";

@implementation CSXNodeLayout (CSXLayoutObject)
/* MARK: Various Attributes */
+ (CSXNodeLayout *)nameAttributeLayout {
    CSXNodeLayout *layout;
    CSXNodeContentLayout *content;
    
    layout = [CSXNodeLayout new];
    content = [CSXNodeContentLayout new];
    
    layout.name = CSXNodeLayoutNameAttributeName;
    layout.required = YES;
    
    content.contentType = CSXNodeContentTypeString;
    content.getter = @selector(name);
    content.setter = @selector(setName:);

    layout.contentLayout = content;
#if !__has_feature(objc_arc)
    [content release];
#endif
    
#if !__has_feature(objc_arc)
    return [layout autorelease];
#else
    return layout;
#endif
}

/* MARK: Node/Attribute Element */
+ (CSXElementLayout *)requiredElementLayout {
    CSXElementLayout *layout;
    CSXNodeContentLayout *content;
    
    layout = [CSXElementLayout new];
    content = [CSXNodeContentLayout new];
    
    layout.name = CSXNodeLayoutRequiredElementName;
    layout.empty = YES;
    layout.unique = YES;
    layout.required = NO;
    
    content.contentType = CSXNodeContentTypeBoolean;
    content.getter = @selector(required);
    content.setter = @selector(setRequired:);
    
    layout.contentLayout = content;
#if !__has_feature(objc_arc)
    [content release];
#endif
    
#if !__has_feature(objc_arc)
    return [layout autorelease];
#else
    return layout;
#endif
}

+ (CSXElementLayout *)attributeElementLayout {
    CSXElementLayout *layout;
    CSXNodeContentLayout *content;
    
    layout = [CSXElementLayout new];
    content = [CSXNodeContentLayout new];
    
    layout.name = CSXNodeLayoutAttributeElementName;
    layout.empty = NO;
    layout.unique = NO;
    layout.required = NO;
    
    content.contentType = CSXNodeContentTypeCustom;
    content.getter = @selector(attributes);
    content.setter = @selector(setAttributes:);
    content.customClass = [CSXNodeLayout class];
    
    layout.contentLayout = content;
#if !__has_feature(objc_arc)
    [content release];
#endif
    
    layout.attributes = [NSArray arrayWithObjects:
                         [self nameAttributeLayout],
                         nil];
    
    layout.subelements = [NSArray arrayWithObjects:
                          [self requiredElementLayout],
                          [CSXNodeContentLayout contentElementLayout],
                          nil];
    
#if !__has_feature(objc_arc)
    return [layout autorelease];
#else
    return layout;
#endif
}
@end

