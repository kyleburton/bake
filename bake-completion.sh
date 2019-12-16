#!/usr/bin/env bash

BAKE_COMPLETIONS="${BAKE_COMPLETIONS:-Bakefile.completions}"

_bake () {
  local cword cur tasks words
  _get_comp_words_by_ref -n : -c cur cword words
  tasks="$(bake | grep -v BAKEFILE | grep '^  ' | sed 's/^  //g' | cut -f1 -d' ')"
  if [[ "$cword" -eq "1" ]]; then
    mapfile -t COMPREPLY < <(compgen -W "$tasks" -- "$cur")
  else
    if [ -f "$BAKE_COMPLETIONS" ]; then
      # shellcheck disable=SC1090
      source "$BAKE_COMPLETIONS"
    else
      mapfile -t COMPREPLY < <(compgen -o default -- "$cur")
      return 0
    fi

    local completion_fn="_bake_completions_${words[1]}" # task name
    if declare -F "$completion_fn" &>/dev/null; then
      # complete using provided completer
      mapfile -t COMPREPLY < <("$completion_fn" "$cur")
    else
      # fallback on default completer
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
