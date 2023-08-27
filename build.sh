#!/bin/sh

version=$(cat module.prop | grep 'version=' | awk -F '=' '{print $2}')
filename="Surfing_${version}_release.zip"
zip -r -o -X -ll "$filename" ./ -x '.git/*' -x '.github/*' -x 'folder/*' -x 'build.sh' -x 'Surfing.json'