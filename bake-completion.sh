#!/usr/bin/env bash

_bake () {
  local cur=${COMP_WORDS[COMP_CWORD]}
  local tasks="$(bake | grep -v BAKEFILE | grep '^  ' | sed 's/^  //g' | cut -f1 -d' ')"
  echo "TASKS: $tasks" >> x
  COMPREPLY=( $(compgen -W "$tasks" -- $cur) )
}


complete -F _bake bake
