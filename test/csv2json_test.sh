#!/bin/bash
set -e

. ./lib/test-helper.sh

. ./lib/csv2json.sh

echo test csv2json

csv=`cat <<EOM
# header
#
# a,b,c
foo,0,true
bar,1,false
EOM
`
actual=`echo "$csv" | csv2json "name" "id:number" "bool:boolean"`
expect='[{"name":"foo","id":0,"bool":true},{"name":"bar","id":1,"bool":false}]'
assert_equal $expect $actual
