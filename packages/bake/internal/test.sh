
bake_task bake_echo_test "Task for testing the package system."
function bake_echo_test () {
  echo "OK[]: $@"
}
