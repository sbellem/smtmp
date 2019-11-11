#!/bin/bash

cp -R Auto-Test-Data/$TEST_SET/* Data/
echo Running testscript on set $TEST_SET
./Scripts/test.sh
