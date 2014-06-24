/*
 *  CSXElementLayoutPlacebo.m
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

#import "CSXElementLayoutPlacebo.h"

/* =========================================================================== 
 MARK: -
 MARK: Private Interface
 =========================================================================== */
@interface CSXElementLayoutPlacebo (Private)
/* MARK: Private Properties */
@property (nonatomic, assign, getter=isSetup) BOOL setup;

/* MARK: Setup */
- (void)setupPlacebo;
@end

/* =========================================================================== 
 MARK: -
 MARK: Public Implementation
 =========================================================================== */
@implementation CSXElementLayoutPlacebo
/* MARK: Init */
- (id)init {
    self = [super init];
    return self;
}

+ (id)placebo {
    id inst;
    inst = [[self alloc] init];
#if !__has_feature(objc_arc)
    return [inst autorelease];
#else
    return inst;
#endif
}

/* MARK: Properties */
- (NSString *)name {
    if(self.setup == NO) {
        [self setupPlacebo];
    }
    return super.name;
}

- (BOOL)required {
    if(self.setup == NO) {
        [self setupPlacebo];
    }
    return super.required;
}

- (CSXNodeContentLayout *)contentLayout {
    if(self.setup == NO) {
        [self setupPlacebo];
    }
    return super.contentLayout;
}

- (BOOL)empty {
    if(self.setup == NO) {
        [self setupPlacebo];
    }
    return super.empty;
}

- (BOOL)unique {
    if(self.setup == NO) {
        [self setupPlacebo];
    }
    return super.unique;
}

- (NSArray *)attributes {
    if(self.setup == NO) {
        [self setupPlacebo];
    }
    return super.attributes;
}

- (NSArray *)subelements {
    if(self.setup == NO) {
        [self setupPlacebo];
    }
    return super.subelements;
}
@end


/* =========================================================================== 
 MARK: -
 MARK: Private Implementation
 =========================================================================== */
@implementation CSXElementLayoutPlacebo (Private)
/* MARK: Private Properties */
- (BOOL)isSetup {
    return _setup;
}

- (void)setSetup:(BOOL)f {
    _setup = f;
}

/* MARK: Setup */
- (void)setupPlacebo {
    CSXElementLayout *base;
    
    base = [CSXElementLayout elementElementLayout];
    
    self.name = base.name;
    self.required = base.required;
    self.contentLayout = base.contentLayout;
    
    self.empty = base.empty;
    self.unique = base.unique;
    self.attributes = base.attributes;
    self.subelements = base.subelements;
    
    self.setup = YES;
}
@end
