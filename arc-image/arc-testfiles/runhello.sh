#!/bin/sh
echo "Computing md5sum for localfile.txt";md5sum localfile.txt>>output.txt;
echo "Computing md5sum for remotefile.txt";md5sum remotefile.txt>>output.txt;
echo "Am sleeping for 30 seconds"
sleep 30
exit 
