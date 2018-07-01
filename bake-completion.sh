#!/usr/bin/env bash

_bake () {
  local cur
  _get_comp_words_by_ref -n : -c cur
  local tasks="$(bake | grep -v BAKEFILE | grep '^  ' | sed 's/^  //g' | cut -f1 -d' ')"
  COMPREPLY=( $(compgen -W "$tasks" -- $cur) )

  # NB: this is a workaround for bash's default of splitting words on colons
  # when bake tasks also use colons as a namespace separator.  What we need to
  # do is fill COMPREPLY with the remaining parts of the task after the last
  # colon.
  # TODO: as is, this fails to drop incomplete tasks
  if [[ $cur == *:* ]]; then
    local pfx="${cur%%:*}:"
    for ((ii = 0; ii < ${#COMPREPLY[@]}; ++ii)); do
      local w="${COMPREPLY[$ii]}"
      COMPREPLY[$ii]="${w#$pfx}"
    done
  fi

}


complete -F _bake bake
