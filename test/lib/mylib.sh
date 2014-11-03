#!/usr/bin/env bash
set -eu


bake_task bar_task "The bar_task command just echos it's arguments"
function bar_task () {
  echo "bar_task: args='$@'"
}

bake_task foo "The foo command just echos it's arguments"
function foo () {
  echo "foo: args='$@'"
}
