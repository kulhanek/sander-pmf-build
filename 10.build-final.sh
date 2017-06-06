#!/bin/bash

./CMakeClean.sh deep

./11.build-single.sh 2>&1 | tee single.log
if [ $? -ne 0 ]; then exit 1; fi

./CMakeClean.sh deep

./12.build-para.sh | tee para.log
if [ $? -ne 0 ]; then exit 1; fi

