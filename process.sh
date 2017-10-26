#!/bin/bash
wget http://web.yonsei.ac.kr/icsl/teaching/assignments/process.zip
rm -f Makefile _sort process.txt time.c
unzip process.zip
rm -f process.zip
make clean
