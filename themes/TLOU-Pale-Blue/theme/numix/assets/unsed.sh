#!/bin/sh
sed -i \
         -e 's/rgb(0%,0%,0%)/#374d5b/g' \
         -e 's/rgb(100%,100%,100%)/#eddad4/g' \
    -e 's/rgb(50%,0%,0%)/#1b2f3c/g' \
     -e 's/rgb(0%,50%,0%)/#eddad4/g' \
 -e 's/rgb(0%,50.196078%,0%)/#eddad4/g' \
     -e 's/rgb(50%,0%,50%)/#374d5b/g' \
 -e 's/rgb(50.196078%,0%,50.196078%)/#374d5b/g' \
     -e 's/rgb(0%,0%,50%)/#eddad4/g' \
	"$@"