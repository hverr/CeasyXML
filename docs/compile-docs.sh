#!/bin/sh

cd "`dirname "$0"`"

appledoc \
    --create-html \
    --verbose 6\
    --templates "/Library/Application Support/appledoc" \
    --project-name "CeasyXML" \
    --project-company "Henri Verroken" \
    --company-id be-henriverroken \
    --output ../build\
    --logformat xcode \
    --keep-undocumented-objects \
    --keep-undocumented-members \
    --exit-threshold 2 \
    --ignore .m \
    --ignore ../Classes/CSXElementLayoutPlacebo.h \
    --ignore ../Classes/CSXNodeContentLayout+CSXLayoutObject.h \
    --ignore ../Classes/CSXNodeLayout+CSXLayoutObject.h \
    --ignore ../Classes/CSXElementLayout+CSXLayoutObject.h \
    --ignore ../Classes/CSXDocumentLayout+CSXLayoutObject.h \
    --ignore ../Classes/CSXLayoutList+CSXLayoutObject.h \
    --docsetutil-path "/Applications/Xcode 3.2.6/usr/bin/docsetutil"\
    ../Classes


