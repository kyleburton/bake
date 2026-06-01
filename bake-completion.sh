#!/usr/bin/env bash

_bake () {
  local cword cur words
  _get_comp_words_by_ref -n : -c cur -w words cword
  tasks="$(bake | grep -v BAKEFILE | grep '^  ' | sed 's/^  //g' | cut -f1 -d' ')"
  if [[ "$cword" -eq "1" ]]; then
    mapfile -t COMPREPLY < <(compgen -W "$tasks" -- "$cur")
  else
    local task="${words[1]}"
    local prior=("${words[@]:2:$((cword - 2))}")
    local candidates
    candidates="$(bake --complete "$task" "$cur" "${prior[@]}" 2>/dev/null)"
    if [[ -n "$candidates" ]]; then
      mapfile -t COMPREPLY < <(compgen -W "$candidates" -- "$cur")
    else
      mapfile -t COMPREPLY < <(compgen -o default -- "$cur")
    fi
  fi

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
