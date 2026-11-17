#!/bin/bash

setUp() {
  rm test*.yml || true
}

testSortKeys() {
  cat >test.yml <<EOL
# top
z: 1
a:
  y: [{d: 1, c: 2}]
  b: 2 # b comment
EOL

  read -r -d '' expected << EOM
# top
a:
  b: 2 # b comment
  y: [{c: 2, d: 1}]
z: 1
EOM

  X=$(./yq --sort-keys test.yml)
  assertEquals "$expected" "$X"

  X=$(./yq ea -S test.yml)
  assertEquals "$expected" "$X"
}

testSortKeysWithExpression() {
  cat >test.yml <<EOL
b: 1
a: {d: 1, c: 2}
EOL

  read -r -d '' expected << EOM
{
  "c": 2,
  "d": 1,
  "e": 3
}
EOM

  X=$(./yq -S -o=json '.a.e = 3 | .a' test.yml)
  assertEquals "$expected" "$X"
}

testSortKeysInPlace() {
  cat >test.yml <<EOL
b: 1
a: 2
EOL

  read -r -d '' expected << EOM
a: 2
b: 1
c: 3
EOM

  ./yq -i -S '.c = 3' test.yml
  X=$(cat test.yml)
  assertEquals "$expected" "$X"
}

source ./scripts/shunit2
