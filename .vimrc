set laststatus=2
set noshowmode

set nocompatible

set encoding=utf-8
set binary

"set nowrap     " don't wrap lines
set shiftround  " use multiple of shiftwidth when indenting with '<' and '>'
set showmatch   " show matching parenthesis
set showcmd     " show number of selected lines in visual mode

" search settings
set hlsearch    " highlight search terms
set incsearch   " show search matches as you type
set ignorecase  " ignore case when searching
set smartcase   " ignore case if search pattern is all lowercase, case-sensitive otherwise

" ignore some file extensions when completing names by pressing Tab
set wildignore=*.swp,*~,*.bak,*.pyc,*.jpg,*.png,*.xpm,*.gif
set nobackup    " do not create backup file ~

" increase buffer size
set viminfo='100,<1000,s20,h

set pastetoggle=<F2>

filetype plugin indent on
syntax on

" Remember last position in file
autocmd BufReadPost *
  \ if line("'\"") > 0 && line("'\"") <= line("$") |
  \   exe "normal g`\"" |
  \ endif

" Turn off auto adding comments on next line
"set fo=tcq
autocmd FileType * setlocal formatoptions-=c formatoptions-=r

call plug#begin('~/.vim/plugged')

Plug 'itchyny/lightline.vim'
Plug 'myusuf3/numbers.vim'
Plug 'mbbill/undotree'
Plug 'editorconfig/editorconfig-vim'

" Initialize plugin system
call plug#end()

nnoremap <F3> :NumbersToggle<CR>
nnoremap <F4> :NumbersOnOff<CR>
