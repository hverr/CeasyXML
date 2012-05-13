#!/bin/sh

appledoc \
    --create-html \
    --verbose 6\
    --templates "/Library/Application Support/appledoc" \
    --project-name "CeasyXML" \
    --project-company "Henri Verroken" \
    --company-id be-henriverroken \
    --output ../build/Documentation \
    --logformat xcode \
    --keep-undocumented-objects \
    --keep-undocumented-members \
    --exit-threshold 2 \
    --ignore .m \
    --docsetutil-path "/Applications/Xcode 3.2.6/usr/bin/docsetutil"\
    ../Classes


