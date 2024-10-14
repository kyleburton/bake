#!/bin/bash
bake_task vim_pathogen_install "Install https://github.com/tpope/vim-pathogen"
function vim_pathogen_install () {
  test -d "$HOME/.vim/autoload" || mkdir -p "$HOME/.vim/autoload"
  if [ -e "$HOME/.vim/autoload/pathogen.vim" ]; then
    return 0
  else
    curl -LSso "$HOME/.vim/autoload/pathogen.vim" https://tpo.pe/pathogen.vim
    echo "add the following to your .vimrc:"
    echo "  execute pathogen#infect()"
    echo "  syntax on"
    echo "  filetype plugin indent on"
  fi
}
