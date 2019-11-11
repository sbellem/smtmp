#!/bin/bash

set -ev

cp -R Auto-Test-Data/Cert-Store/* Cert-Store/

for i in $(seq 0 25); do
  \rm -f Scripts/logs/$i
done
