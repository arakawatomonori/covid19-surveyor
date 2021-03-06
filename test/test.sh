#!/bin/bash
# vim: set ft=sh ff=unix fileencoding=utf-8 expandtab ts=4 sw=4 :

cd `dirname $0`
cd ..

cd test
TEST_SCRIPTS=`echo *.sh`
cd -

TEST_COUNT=0
TEST_SUCCESS=0
TEST_FAIL=0

for SCRIPT in $TEST_SCRIPTS; do
    if [ x"$SCRIPT" = x"test.sh" ]; then
        continue
    fi
    TEST_COUNT=$(($TEST_COUNT + 1))
    echo "[RUN]: $SCRIPT"
    ./test/$SCRIPT
    if [ $? = 0 ]; then
        TEST_SUCCESS=$(($TEST_SUCCESS + 1))
    else
        TEST_FAIL=$(($TEST_FAIL + 1))
    fi
done

echo "----"
echo "[TESTS]:    $TEST_COUNT"
echo "[SUCCESS]:  $TEST_SUCCESS"
echo "[FAIL]:     $TEST_FAIL"

if [ $TEST_FAIL != 0 ]; then
    exit 1
fi

exit 0

