set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim

so ~/.vim/local.vim
call vundle#begin()
so ~/.vim/localPlugins.vim

""""""""""""""""""""""""""""""""""""""""""""""""""
"                Vundle Plugins                  "
""""""""""""""""""""""""""""""""""""""""""""""""""

" Let Vundle Manage Itself
Plugin 'gmarik/Vundle.vim'

" Plugins
Plugin 'Valloric/YouCompleteMe'
Plugin 'tpope/vim-fugitive'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'altercation/vim-colors-solarized'
Plugin 'leafgarland/typescript-vim'
Plugin 'andviro/flake8-vim'
Plugin 'vim-jp/vim-cpp'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'airblade/vim-gitgutter'

"call vundle#config#require(g:bundles)
" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" Global variable which holds the path to my customization files
" You'll need to edit this so it matches your system
let g:VIM_CUSTOM = "~/.vim_custom/"

set cindent
set autoindent
set visualbell
set showmatch
set showcmd
set autowrite
set backspace=2 " make backspace work like most other apps

" Line numbers
set nu
set relativenumber

set expandtab
set shiftwidth=4
set tabstop=4
set ignorecase
set smartindent
set encoding=utf-8
set wrap

set lazyredraw

" Searching
set magic
set smartcase
set hlsearch
set incsearch

" Fix mouse
if has("mouse")
  set mouse=a
  set mousehide
  if has("mouse_sgr")
    set ttymouse=sgr
  else
    set ttymouse=xterm2
  end
end

" Wildmenu
set wildmenu

" Add a bit of extra margin on the left
set foldcolumn=1

" 7 lines of scroll buffer at the bottom/top
set scrolloff=7

" Jump 5 lines at a time when at the edge
" set scrolljump=5

" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif
" Remember info about open buffers on close
set viminfo^=%

" UI Tweaks
set noshowmode    " Display the current mode
" set cursorline  " Highlight current line


if has('cmdline_info')
  set ruler                   " Show the ruler
"  set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%) " A ruler on steroids
"  set showcmd                 " Show partial commands in status line and
                              " Selected characters/lines in visual moe
endif

if has('statusline')
  set laststatus=2

endif

" set listchars=tab:>\ ,trail:•,extends:#,nbsp:.
" set list
"set listchars=trail:•,extends:#,nbsp:.

set whichwrap=b,s,h,l,<,>,[,]

" Yanking copies to Clipboard
set clipboard+=unnamed

"  Tags
set tags+=tags;/

""""""""""""""""""""""""""""""""""""""""""""""""""
"                 Color scheme                   "
""""""""""""""""""""""""""""""""""""""""""""""""""

"autocmd!
"let fullpath = getcwd() . bufname("%")
"if match(fullpath, "okcontent") != -1
"    autocmd BufNewFile,BufRead *.html,*.pub,*.lib,*.dict set filetype=pub
"endif
"
"filetype on
"au BufNewFile,BufRead *.T,*.Th,*.x,*.v set filetype=cpp

""""""""""""""""""""""""""""""""""""""""""""""""""
"                 Color scheme                   "
""""""""""""""""""""""""""""""""""""""""""""""""""

let &colorcolumn=join(range(80,999),",")
"highlight ColorColumn ctermbg=234 guibg=#2c2d27

""""""""""""""""""""""""""""""""""""""""""""""""""
"                   Key maps                     "
""""""""""""""""""""""""""""""""""""""""""""""""""

" Tab and Shift-Tab to indent / unindent
"nmap <Tab> >>
"nmap <s-tab> <<
"inoremap <Tab> <C-o>>>
"inoremap <s-tab> <C-o><<
vmap <tab> >gv
vmap <s-tab> <gv
nnoremap <F6> :!~/bin/mk<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""
"              Custom functions                  "
""""""""""""""""""""""""""""""""""""""""""""""""""

" Relative Numbers in normal mode
" Absolute numbers in insert mode
augroup RelativeNumbers
  autocmd InsertEnter * :set norelativenumber
  autocmd InsertLeave * :set relativenumber
augroup END

" When foxus is lost use absolute numbers
augroup RelativeNumbersFocus
  autocmd FocusLost * :set norelativenumber
  autocmd FocusGained * :set relativenumber
augroup END

" leave insert mode quickly (or at least slightly quicker)
if ! has('gui_running')
  set ttimeoutlen=10
  augroup FastEscape
    autocmd!
    au InsertEnter * set timeoutlen=0
    au InsertLeave * set timeoutlen=50
  augroup END
endif

""""""""""""""""""""""""""""""""""""""""""""""""""
"               Solarized Config                 "
""""""""""""""""""""""""""""""""""""""""""""""""""
syntax on
set background=dark
let g:solarized_visibility="high"
let g:solarized_contrast="high"
let g:solarized_termcolors=256
colorscheme solarized
set background=dark

""""""""""""""""""""""""""""""""""""""""""""""""""
"                NerdTree Config                 "
""""""""""""""""""""""""""""""""""""""""""""""""""

"" Load NERDTree on startup
"autocmd VimEnter * NERDTree
"" Set the cursor to the non NERDTree window
"autocmd VimEnter * wincmd p
"
""autocmd StdinReadPre * let s:std_in=1
""autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
"
"" Close NERDTree if it is the last window
"autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType")
"            \&& b:NERDTreeType == "primary") | q | endif


""""""""""""""""""""""""""""""""""""""""""""""""""
"                Airline Config                  "
""""""""""""""""""""""""""""""""""""""""""""""""""

let g:airline_powerline_fonts=1
let g:airline_theme='dark'
let g:airline#extensions#whitespace#enabled=0

""""""""""""""""""""""""""""""""""""""""""""""""""
"                YouCompleteMe                   "
""""""""""""""""""""""""""""""""""""""""""""""""""

let g:ycm_server_keep_logfiles = 1
let g:ycm_server_use_vim_stdout = 1
let g:ycm_server_log_level = 'debug'

""""""""""""""""""""""""""""""""""""""""""""""""""
"               Typescript-Vim                   "
""""""""""""""""""""""""""""""""""""""""""""""""""

autocmd QuickFixCmdPost [^l]* nested cwindow
autocmd QuickFixCmdPost    l* nested lwindow

" YCM Interop
if !exists("g:ycm_semantic_triggers")
   let g:ycm_semantic_triggers = {}
endif
let g:ycm_semantic_triggers['typescript'] = ['.']

""""""""""""""""""""""""""""""""""""""""""""""""""
"               Vim GitGutter                    "
""""""""""""""""""""""""""""""""""""""""""""""""""
let g:gitgutter_max_signs=10000
