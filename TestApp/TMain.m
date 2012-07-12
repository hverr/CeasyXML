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

#define DESTINATION ([@"~/Desktop/dest.xml" stringByExpandingTildeInPath])

int main(int argc, const char **argv) {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    
    NSString *layoutFile, *libraryFile, *destFile;
    NSError *err;
    
    layoutFile = [NSString stringWithUTF8String:__FILE__];
    layoutFile = [layoutFile stringByDeletingLastPathComponent];
    layoutFile = [layoutFile stringByAppendingPathComponent:@"Layout.xml"];
    
    libraryFile = [NSString stringWithUTF8String:__FILE__];
    libraryFile = [libraryFile stringByDeletingLastPathComponent];
    libraryFile = [libraryFile stringByAppendingPathComponent:@"Library.xml"];
    
    destFile = DESTINATION;
    
    CSXXMLParser *parser;
    
    parser = [[CSXXMLParser alloc] initWithLayoutListDocument:layoutFile 
                                                        error:NULL];
    if(parser == nil) {
        NSLog(@"Failed to create XML parser.");
        return 1;
    }
    
    parser.file = libraryFile;
    
    BOOL success = [parser parse];
    if(!success) {
        NSLog(@"Parser error: %@ (%@)", parser.error,
              [parser.error localizedRecoverySuggestion]);
        return 1;
    }
    
    NSLog(@"Result: %@", parser.result);
    
    
    CSXXMLWriter *writer;
    
    writer = [[CSXXMLWriter alloc] initWithDocumentLayout:
              [parser.documentLayouts objectAtIndex:0]];
    assert(writer != nil);
    
    writer.rootInstance = parser.result;
    writer.XMLVersion = @"1.0";
    writer.encoding = @"UTF-8";
    
    
    NSData *myData;
    
    myData = [writer XMLDataWithError:&err];
    if(!myData) {
        NSLog(@"Write error: %@", err);
    }
    NSLog(@"Data: %@", myData);
    [myData writeToFile:destFile 
                options:0 
                  error:NULL];
    
    [pool release];
    return 0;
}
