#!/usr/bin/env bash
set -eu


bake_task bar_task "The bar_task command just echos its arguments"
function bar_task () {
  echo "bar_task: args='$@'"
}

bake_task qux
function qux () {
  echo "qux: args='$@'"
}

bake_task foo "The foo command just echos its arguments"
function foo () {
  echo "foo: args='$@'"
}
