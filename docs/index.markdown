## What is CeasyXML?
CeaysXML is a library that allows you to automate the connection between your
XML documents and your objective-c classes.

## How do I use CeasyXML?
By using an XML document to define the layout of your own XML document, the
parser and writer know exactly how to handle your documents and how to 
use your classes.

`CSXXMLParser` and `CSXXMLWriter` are the primary classes you will be using.
These provide a direct interface to the library.

- See [How to define the layout of your XML document][1] to write your first
  document layout.
- See [Parsing XML documents][2] for a tutorial on how to parse your own XML
  documents.
- See [Writing XML documents][3] for a tutorial on how to write your own XML
  documents with your custom class.

## How do I link to CeasyXML? (Important)
### Known linking problem and its solution
CeasyXML is a static Objective-C library. Unix libraries have a certain way of
being loaded, which generates some problems when using Objective-C categories.

This library does use categories, so that you must specify special linker flags
to your own project. This is very easy to do.

See [this question][4] on stackoverflow and [this article][5] from Apple for
more information.

### Including the Header Files
To include the header files of CeasyXML you'll want to use `#include
<CeasyXML.h>`. To enable the use of the brackets, add the location of the header
files to your header search paths.

The header files of CeasyXML include `libxml/*`. In order to make them work,
you'll want to add `/usr/include/libxml2` or an other directory to your header
search paths, too.

### Linking to LibXML2
Since your application loads the CeasyXML code, you'll have to also link to the
LibXLM2 library on your machine.

   [1]: docs/How%20to%20define%20the%20layout%20of%20your%20XML%20document.html
   [2]: docs/Parsing%20XML%20documents.html
   [3]: docs/Writing%20XML%20documents.html
   [4]: http://www.stackoverflow.com/q/10416779/262660
   [5]: http://developer.apple.com/library/mac/#qa/qa2006/qa1490.html


