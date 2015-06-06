#!/bin/bash

# argument check
if [ "$1" == "" ]; then
  #echo "Usage: pas2cgi [source file] <cgi file>"
  echo "PAS2CGI: Error: You must supply a source file as an argument."
  exit
fi

# source file check
if [ ! -f $1 ]; then
  echo "PAS2CGI: Error: \"$1\" source file is not found."
  exit
fi

# variable setup
echo "=== Starting CGI deployment..."
SRC_EXT=pas
SRC_NAME=$(basename $1 .$SRC_EXT)
SRC_FOLDER=$(dirname $1)
BIN_NAME=$SRC_NAME
CGI_NAME=$SRC_NAME
CGI_EXT=cgi
CGI_FOLDER=Web

# call your compiler here
echo "=== 1: Compiling source file..."
CMD="fpc -XXs -CX -O3 $1 -FuApplications:lazarus/components/lazutils"
echo "\$ $CMD"; $CMD;

# deploy and clean up
if [ -f $SRC_FOLDER/$SRC_NAME ]; then
  # second argument to set different CGI name
  if [ "$2" != "" ]; then
    CGI_NAME=$(basename $2 .$CGI_EXT)
  fi

  echo "=== 2: Moving binary file to CGI folder..."
  CMD="mv $SRC_FOLDER/$BIN_NAME $CGI_FOLDER/$CGI_NAME.$CGI_EXT"
  echo "\$ $CMD"; $CMD;

  echo "=== 3: Deleting garbage files..."
  CMD="rm $SRC_FOLDER/$SRC_NAME.o"
  echo "\$ $CMD"; $CMD;
  CMD="rm $SRC_FOLDER/libp$SRC_NAME.a"
  echo "\$ $CMD"; $CMD;
  CMD="rm Applications/*.o Applications/*.a Applications/*.ppu"
  echo "\$ $CMD"; $CMD;

  echo "=== Done."
else
  echo "=== Compilation failed!"
fi