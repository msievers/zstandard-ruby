#!/bin/bash

for library in ./spec/libzstd/x86_64/ubuntu/14.04/*
do
  bundle exec rake ZSTANDARD_LIBRARY_PATH=$library
done
