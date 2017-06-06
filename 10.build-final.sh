#!/bin/bash

make clean &> /dev/null
./11.build-single.sh 2>&1 | tee single.log
if [ $? -ne 0 ]; then exit 1; fi

make clean &> /dev/null
./12.build-para.sh | tee para.log
if [ $? -ne 0 ]; then exit 1; fi

