#!/bin/bash

PROCESSOR_TYPE=$(uname -p)
DISTRIBUTOR_ID=$(lsb_release -i -s|tr '[:upper:]' '[:lower:]')
RELEASE=$(lsb_release -r -s)

LIBRARIES_DIRECTORY="./spec/libzstd/${PROCESSOR_TYPE}/${DISTRIBUTOR_ID}/${RELEASE}"

if [ -d "$LIBRARIES_DIRECTORY" ]; then
  for library in ${LIBRARIES_DIRECTORY}/*
  do
    bundle exec rake ZSTANDARD_LIBRARY=$library
    if [ "$?" -ne "0" ]; then
      exit 1
    fi
  done
else
  echo "There are no bundled libraries for the current system."
  exit 1
fi
