#!/bin/bash

set -ev

pip install --upgrade pip

docker build --no-cache -t scale-mamba -f py2.Dockerfile .

if [ "${BUILD}" == "tests" ]; then
    docker run --rm scale-mamba make test
fi
