#!/bin/sh
sed -i \
         -e 's/rgb(0%,0%,0%)/#281d2e/g' \
         -e 's/rgb(100%,100%,100%)/#eddad4/g' \
    -e 's/rgb(50%,0%,0%)/#19021e/g' \
     -e 's/rgb(0%,50%,0%)/#e3e2e5/g' \
 -e 's/rgb(0%,50.196078%,0%)/#e3e2e5/g' \
     -e 's/rgb(50%,0%,50%)/#281d2e/g' \
 -e 's/rgb(50.196078%,0%,50.196078%)/#281d2e/g' \
     -e 's/rgb(0%,0%,50%)/#eddad4/g' \
	"$@"