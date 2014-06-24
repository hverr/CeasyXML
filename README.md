# CeasyXML

## Main Documentation
You can find all documentation and the API reference at [github.io][pages-url].

## What is CeasyXML?
CeaysXML is a library that allows you to automate the connection between your XML documents and your Objective-C classes.

## How do I use CeasyXML?
By using an XML document to define the layout of your own XML document, the parser and writer know exactly how to handle your documents and how to use your classes.

CSXXMLParser and CSXXMLWriter are the primary classes you will be using. These provide a direct interface to the library.

- See [How to define the layout of your XML document](http://hverr.github.io/CeasyXML/docs/How%20to%20define%20the%20layout%20of%20your%20XML%20document.html) to write your first document layout.
- See [Parsing XML documents](http://hverr.github.io/CeasyXML/docs/Parsing%20XML%20documents.html) for a tutorial on how to parse your own XML documents.
- See [Writing XML documents](http://hverr.github.io/CeasyXML/docs/Writing%20XML%20documents.html) for a tutorial on how to write your own XML documents with your custom class.

## How do I link to CeasyXML? *(important)*

### Known linking problem and its solution
CeasyXML is a static Objective-C library. Unix libraries have a certain way of being loaded, which generates some problems when using Objective-C categories.

This library does use categories, so that you must specify special linker flags to your own project. This is very easy to do.

See [this question](http://stackoverflow.com/q/10416779/262660) on stackoverflow and [this article](https://developer.apple.com/library/mac/#qa/qa2006/qa1490.html) from Apple for more information.

### Including the Header Files
To include the header files of CeasyXML you'll want to use `#include <CeasyXML.h>`. To enable the use of brackets, add the location of the header files to your header search paths.

The header files of CeasyXML include `libxml/*`. In order to make them work, you'll want to add `/usr/include/libxml2` to your header search paths, too.

### Linking to LibXML2
Since your application loads the CeasyXML code, you'll have to also link to the `libxml2` library on your machine.

## Class Reference
See [github.io][pages-url] for the full documentation.


 [pages-url]: http://hverr.github.io/CeasyXML