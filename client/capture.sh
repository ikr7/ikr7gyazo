#!/usr/bin/env bash

server="http://localhost:3232"
tmpfile="/tmp/ikr7gyazo_$$.png"
imgfile=$1

if [ -n "$imgfile" ] && [ -r $imgfile ]; then
	sips -s format png $imgfile --out $tmpfile
else
	screencapture -x -i $tmpfile
	if [ -r $tmpfile ]; then
		sips -d profile --deleteColorManagementProperties $tmpfile > /dev/null
		dpiWidth=$(sips -g dpiWidth $tmpfile | awk '/:/ {print $2}')
		dpiHeight=$(sips -g dpiHeight $tmpfile | awk '/:/ {print $2}')
		pixelWidth=$(sips -g pixelWidth $tmpfile | awk '/:/ {print $2}')
		pixelHeight=$(sips -g pixelHeight $tmpfile | awk '/:/ {print $2}')
		if [ "$(echo "$dpiWidth > 72.0" | bc)" -eq 1 ] && [ "$(echo "$dpiHeight > 72.0" | bc)" -eq 1 ]; then
			width=$($pixelWidth * 72.0 / dpiWidth)
			height=$($pixelHeight * 72.0 / dpiHeight)
			sips -s dpiWidth 72 -s dpiHeight 72 -z $height $width $tmpfile
		fi
	fi
fi

if [ ! -r $tmpfile ]; then
	exit 1
fi

url=$(curl -s -S -X POST "$server/share/path?path=$tmpfile" | jq -r ".url")
echo $url | pbcopy
open $url
rm $tmpfile
