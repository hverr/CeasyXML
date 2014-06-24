/*
 *  CSXNodeContentLayout+CSXLayoutObject.m
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

#import "CSXNodeContentLayout+CSXLayoutObject.h"


static NSString * const CSXNodeContentLayoutTypeAttributeName = @"type";
static NSString * const CSXNodeContentLayoutContentElementName = @"content";

static NSString * const CSXNodeContentLayoutSetterElementName = @"setter";
static NSString * const CSXNodeContentLayoutGetterElementName = @"getter";
static NSString * const CSXNodeContentLayoutClassElementName = @"class";

@implementation CSXNodeContentLayout (CSXLayoutObject)
/* MARK: Various Attributes */
+ (CSXNodeLayout *)typeAttributeLayout {
    CSXNodeLayout *layout;
    CSXNodeContentLayout *content;
    
    layout = [CSXNodeLayout new];
    content = [CSXNodeContentLayout new];
    
    layout.name = CSXNodeContentLayoutTypeAttributeName;
    layout.required = YES;
    
    content.contentType = CSXNodeContentTypeString;
    content.getter = @selector(contentTypeIdentifier);
    content.setter = @selector(setContentTypeIdentifier:);
    
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

/* MARK: Content Element */
+ (CSXElementLayout *)getterElementLayout {
    CSXElementLayout *layout;
    CSXNodeContentLayout *content;
    
    layout = [CSXElementLayout new];
    content = [CSXNodeContentLayout new];
    
    layout.name = CSXNodeContentLayoutGetterElementName;
    layout.required = NO;
    layout.unique = YES;
    layout.empty = NO;
    
    content.contentType = CSXNodeContentTypeString;
    content.getter = @selector(getterString);
    content.setter = @selector(setGetterString:);
    
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

+ (CSXElementLayout *)setterElementLayout {
    CSXElementLayout *layout;
    CSXNodeContentLayout *content;
    
    layout = [CSXElementLayout new];
    content = [CSXNodeContentLayout new];
    
    layout.name = CSXNodeContentLayoutSetterElementName;
    layout.required = NO;
    layout.unique = YES;
    layout.empty = NO;
    
    content.contentType = CSXNodeContentTypeString;
    content.getter = @selector(setterString);
    content.setter = @selector(setSetterString:);
    
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

+ (CSXElementLayout *)classElementLayout {
    CSXElementLayout *layout;
    CSXNodeContentLayout *content;
    
    layout = [CSXElementLayout new];
    content = [CSXNodeContentLayout new];
    
    layout.name = CSXNodeContentLayoutClassElementName;
    layout.required = NO;
    layout.unique = YES;
    layout.empty = NO;
    
    content.contentType = CSXNodeContentTypeString;
    content.getter = @selector(customClassString);
    content.setter = @selector(setCustomClassString:);
    
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

+ (CSXElementLayout *)contentElementLayout {
    CSXElementLayout *layout;
    CSXNodeContentLayout *content;
    
    layout = [CSXElementLayout new];
    content = [CSXNodeContentLayout new];
    
    layout.name = CSXNodeContentLayoutContentElementName;
    layout.required = YES;
    layout.unique = YES;
    layout.empty = NO;
    
    content.contentType = CSXNodeContentTypeCustom;
    content.getter = @selector(contentLayout);
    content.setter = @selector(setContentLayout:);
    content.customClass = [CSXNodeContentLayout class];
    
    layout.contentLayout = content;
#if !__has_feature(objc_arc)
    [content release];
#endif
    
    layout.attributes = [NSArray arrayWithObjects:
                         [self typeAttributeLayout],
                         nil];
    layout.subelements = [NSArray arrayWithObjects:
                          [self getterElementLayout],
                          [self setterElementLayout],
                          [self classElementLayout],
                          nil];
    
#if !__has_feature(objc_arc)
    return [layout autorelease];
#else
    return layout;
#endif
}
@end

