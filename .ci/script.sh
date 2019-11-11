#!/bin/bash

set -ev

if [ "${BUILD}" == "tests" ]; then
    docker run --rm scale-mamba sh run_tests.sh
elif [ "${BUILD}" == "docs" ]; then
    docker run --rm scale-mamba make doc
fi
