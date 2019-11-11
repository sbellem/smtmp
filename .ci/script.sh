#!/bin/bash

set -ev

BASE_CMD="docker-compose -f .travis.compose.yml run --rm mamba"

if [ "${BUILD}" == "tests" ]; then
    docker run --rm scale-mamba sh run_tests.sh
elif [ "${BUILD}" == "docs" ]; then
    docker run --rm scale-mamba make doc
fi
