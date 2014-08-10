#!/usr/bin/env bash
set -eu

bake_task foo "The foo command just echos it's arguments"
function foo () {
  echo "foo: args='$@'"
}
