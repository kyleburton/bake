#!/bin/bash

bake_task bake_echo_test "Task for testing the package system."
function bake_echo_test () {
  bake_echo_green "OK[bake_echo_test]: $*"
}
