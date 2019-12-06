#!/bin/bash

set -ev

IMG=$DOCKER_USERNAME/scale-mamba:$COMMIT
#programs=(test_array test_branch test_branching test_comparison)

prgs_arr=($PROGRAMS)
docker run --rm --env TEST_SET $IMG sh .ci/run_tests.sh "${prgs_arr[@]}"
