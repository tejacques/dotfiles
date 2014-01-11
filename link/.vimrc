" Global variable which holds the path to my customization files
" You'll need to edit this so it matches your system
let g:VIM_CUSTOM = "/home/jesse/.vim_custom/"

set cindent
set smartindent
set autoindent
set visualbell
set background=dark
set tabstop=4
set showmatch
set showcmd
set autowrite
set backspace=2 " make backspace work like most other apps
set mouse=a
set nu
set ruler
set expandtab
set shiftwidth=4
set ignorecase
set smartcase
set incsearch
set encoding=utf-8

""""""""""""""""""""""""""""""""""""""""""""""""""
"                 Color scheme                   "
""""""""""""""""""""""""""""""""""""""""""""""""""

" Some custom color modifications.  reference :help highlight and :help cterm
highlight ModeMsg cterm=bold ctermfg=2 ctermbg=black	" set mode message ( --INSERT-- ) to green
highlight StatusLine ctermfg=7 ctermbg=9		" set the active statusline to black on white
highlight StatusLineNC ctermfg=8 ctermbg=9		" set inactive statusline to black on grey

autocmd!
let fullpath = getcwd() . bufname("%")
if match(fullpath, "okcontent") != -1
    autocmd BufNewFile,BufRead *.html,*.pub,*.lib,*.dict set filetype=pub
endif

syntax on
filetype on
au BufNewFile,BufRead *.T,*.Th,*.x,*.v set filetype=cpp


vmap <C-c> !sneakyvimcopy<CR>u
nnoremap <C-y> :r /home/u0/tj/.vim_swap<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""
"              Function Key maps                 "
""""""""""""""""""""""""""""""""""""""""""""""""""

" Re-source the default vimrc
map <F2> :execute Clean_up()<CR> :source $HOME/.vimrc<CR>

" C/C++ Programming 
map <F3> :execute Clean_up()<CR> :execute Re_source("c-vimrc")<CR>

" shell programming
map <F4> :execute Clean_up()<CR> :execute Re_source("bash-vimrc")<CR>

" php programming
map <F5> :execute Clean_up()<CR> :execute Re_source("php-vimrc")<CR>

" sgml editing
map <F6> :execute Clean_up()<CR> :execute Re_source("sgml-vimrc")<CR>

" Once you invoke this you need to delete rows and type in the # you wish
" to process
map <F11> :execute Dump_extra_whitespace(rows)

" Reverse the background color
map <F12> :execute ReverseBackground()<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""
"              Custom functions                  "
""""""""""""""""""""""""""""""""""""""""""""""""""

" Re-source the rc files
:function! Re_source(file_name)
: let path_file_name = g:VIM_CUSTOM . a:file_name
:  if filereadable(path_file_name)
:  	execute 'source ' . path_file_name
:  	echo path_file_name . " Loaded sucessfully"
:  else
:  	echo path_file_name . " does NOT exist"
:  	return 0
:  endif
:endfunction

" This function allows me to quickly remove extra tabs and whitespace
" from the beginning of lines.  This seems to be a problem when I cut
" and paste or when people don't use resizeable tabs.
" TODO The only problem with this is after you execute it it jumps to the 
" beginning of the file.  I need to figure out how to fix that.
:function! Dump_extra_whitespace(rows)
:	let com = ".,+" . a:rows . "s/^[ 	]*//g"
:	execute com
:endfunction

" This function was created by Dillon Jones (much better than my first attempt)
" it reverses the background color for switching between vim/gvim which have
" different defaults.
" TODO The only problem with this is after you execute it it jumps to the 
" beginning of the file.  I need to figure out how to fix that.
:function! ReverseBackground()
: let Mysyn=&syntax
: if &bg=="light"
: se bg=dark
: else
: se bg=light
: endif
: syn on
: exe "set syntax=" . Mysyn
":   echo "now syntax is "&syntax
:endfunction


" Cleanup
:function! Clean_up()
:set visualbell&
:set background&
:set tabstop&
:set showmatch&
:set showcmd&
:set autowrite&
:endfunction
