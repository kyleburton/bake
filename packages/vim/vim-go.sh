
VIM_GO_GIT_URl="https://github.com/fatih/vim-go.git"

bake_require "github.com/kyleburton/bake/packages/vim/pathogen.sh"

bake_task vim_go_install "Installs vim-go. See: http://blog.gopheracademy.com/vimgo-development-environment/"
function vim_go_install () {
  echo "ok, GO"
  test -d $HOME/.vim/bundle || mkdir -p $HOME/.vim/bundle
  pushd $HOME/.vim/bundle
  test -d vim-go || git clone $VIM_GO_GIT_URl
  cd vim-go
  git checkout .
  git pull
  popd
}
