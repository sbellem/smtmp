#!/bin/bash

set -ev

cp -R Auto-Test-Data/Cert-Store/* Cert-Store/

for i in $(seq 0 25); do
  \rm -f Scripts/logs/$i
done

cp -R Auto-Test-Data/$TEST_SET/* Data/
echo Running testscript on set $TEST_SET
./Scripts/test-batch.sh "$@"
