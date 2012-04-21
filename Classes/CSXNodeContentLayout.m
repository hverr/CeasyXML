/*
 *  CSXNodeContentLayout.m
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

#import "CSXNodeContentLayout.h"


NSString * const CSXNodeLayoutInvalidContentTypeIdentifierException =
	@"CSXNodeLayoutInvalidContentTypeIdentifierException";
NSString * const CSXNodeLayoutClassNotFoundException = 
	@"CSXNodeLayoutClassNotFoundException";
NSString * const CSXNodeLayoutSelectorNotFoundException = 
	@"CSXNodeLayoutSelectorNotFoundException";


NSString * const CSXNodeContentTypeStringIdentifier = @"string";
NSString * const CSXNodeContentTypeNumberIdentifier = @"number";
NSString * const CSXNodeContentTypeListIdentifier = @"list";
NSString * const CSXNodeContentTypeCustomIdentifier = @"custom";

/* =========================================================================== 
 MARK: -
 MARK: Public Implementation
 =========================================================================== */
@implementation CSXNodeContentLayout
/* MARK: Properties */
@synthesize contentType, setter, getter, customClass;


- (void)setContentTypeIdentifier:(NSString *)s {
	if([s isEqualToString:CSXNodeContentTypeStringIdentifier]) {
		self.contentType = CSXNodeContentTypeString;
		
	} else if([s isEqualToString:CSXNodeContentTypeNumberIdentifier]) {
		self.contentType = CSXNodeContentTypeNumber;
		
	} else if([s isEqualToString:CSXNodeContentTypeListIdentifier]) {
		self.contentType = CSXNodeContentTypeList;
		
	} else if([s isEqualToString:CSXNodeContentTypeCustomIdentifier]) {
		self.contentType = CSXNodeContentTypeCustom;
		
	} else {
		NSException *exc;
		NSString *excName, *excReason;
		
		excName = CSXNodeLayoutInvalidContentTypeIdentifierException;
		excReason = [NSString stringWithFormat:
					 @"Invalid type identifier: %@", s];
		exc = [NSException exceptionWithName:excName 
									  reason:excReason 
									userInfo:nil];
		[exc raise];
	}
}

- (NSString *)contentTypeIdentifier {
	NSString *value;
	
	switch(self.contentType) {
		case CSXNodeContentTypeString:
			value = CSXNodeContentTypeStringIdentifier;
			break;
			
		case CSXNodeContentTypeNumber:
			value = CSXNodeContentTypeNumberIdentifier;
			break;
			
		case CSXNodeContentTypeList:
			value = CSXNodeContentTypeListIdentifier;
			break;
			
		case CSXNodeContentTypeCustom:
			value = CSXNodeContentTypeCustomIdentifier;
			break;
			
		default:
			value = nil;
			break;
	}
	
	return value;
}

- (void)setCustomClassString:(NSString *)s {
	Class myClass;
	
	myClass = objc_getClass([s UTF8String]);
	
	if(myClass == NULL) {
		NSException *exc;
		NSString *excName, *excReason;
		
		excName = CSXNodeLayoutClassNotFoundException;
		excReason = [NSString stringWithFormat:
					 @"Class not found: %@", s];
		exc = [NSException exceptionWithName:excName 
									  reason:excReason 
									userInfo:nil];
		[exc raise];
		return;
	}
	
	self.customClass = myClass;
}

- (NSString *)customClassString {
	if(self.customClass == NULL) {
		return nil;
	}
	return NSStringFromClass(self.customClass);
}

- (void)setSetterString:(NSString *)s {
	SEL mySelector;
	
	mySelector = NSSelectorFromString(s);
	if(mySelector == NULL) {
		NSException *exc;
		NSString *excName, *excReason;
		
		excName = CSXNodeLayoutSelectorNotFoundException;
		excReason = [NSString stringWithFormat:
					 @"Selector not found: %@", s];
		exc = [NSException exceptionWithName:excName 
									  reason:excReason 
									userInfo:nil];
		[exc raise];
		return;
	}
	
	self.setter = mySelector;
}

- (NSString *)setterString {
	if(self.setter == NULL) {
		return nil;
	}
	
	return NSStringFromSelector(self.setter);
}

- (void)setGetterString:(NSString *)s {
	SEL mySelector;
	
	mySelector = NSSelectorFromString(s);
	if(mySelector == NULL) {
		NSException *exc;
		NSString *excName, *excReason;
		
		excName = CSXNodeLayoutSelectorNotFoundException;
		excReason = [NSString stringWithFormat:
					 @"Selector not found: %@", s];
		exc = [NSException exceptionWithName:excName 
									  reason:excReason 
									userInfo:nil];
		[exc raise];
		return;
	}
	
	self.getter = mySelector;
}

- (NSString *)getterString {
	if(self.getter == NULL) {
		return nil;
	}
	
	return NSStringFromSelector(self.getter);
}

@end

