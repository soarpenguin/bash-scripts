$ git clone https://github.com/farazdagi/vim-go-ide.git ~/.vim_go_runtime
$ sh ~/.vim_go_runtime/bin/install
$
$ gotags -R ./*.go &> tags
$ vim -u ~/.vimrc.go

##################################################
############### ~/.vimrc.go
set runtimepath^="~/.vim_go_runtime"

set nocp
source ~/.vim_go_runtime/autoload/pathogen.vim
source ~/.vim_go_runtime/vimrc/basic.vim
source ~/.vim_go_runtime/vimrc/filetypes.vim
source ~/.vim_go_runtime/vimrc/plugins.vim
source ~/.vim_go_runtime/vimrc/extended.vim

try
  source ~/.vim_go_runtime/custom_config.vim
catch
endtry
