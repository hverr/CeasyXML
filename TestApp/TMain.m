/*
 *  TMain.m
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
 *  the following
 *  The above copyright notice and this permission notice shall be
 *  ice shall be included in all copies or substantial portions of the
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *  ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
 *  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 *  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 *  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 *  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 *  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
 *
 */

#import <Foundation/Foundation.h>
#import <CeasyXML.h>

int main(int argc, const char **argv) {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    
    NSString *file;
    
    file = [NSString stringWithUTF8String:__FILE__];
    file = [file stringByDeletingLastPathComponent];
    file = [file stringByAppendingPathComponent:@"Layout.xml"];
    
    CSXLayoutList *layouts;
    NSError *error;
    
    layouts = [[CSXLayoutList alloc] initWithDocument:file error:error];
    if(layouts == nil) {
        NSLog(@"Could not create layout: %@", error);
        exit(0);
    }
    
    NSLog(@"Layout:\n%@", layouts);
    [layouts release];
    
    [pool release];
    return 0;
}
