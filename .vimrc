""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" .vimrc
" used for vim7.2, PJH
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" i always forget this command, after adding new plugins do this: 
"     
"         cd ~/.vim/doc 
"         :helptags ./
"
set nocompatible   " let vim be vim, not vi
set nomousehide    " dont Hide the mouse when typing text
set nonumber       " show line numbers
set mouse=a        " have the mouse enabled all the time:
set ruler          " cursor pos always shown
set vb t_vb=       " screen flash instead of beeps
set history=100    " have fifty lines of command-line (etc) history:
set undolevels=200 " number of commans
set hidden         " dont require saving to switch buffers

" set for urxvt-256
if &t_Co == 256 
  colorscheme oblivion
endif

let Tlist_Ctags_Cmd = '/usr/bin/ctags'

""""""""""""""""""""""""" this was for ctags.vim, but it is fail so....
" let g:ctags_path='/usr/bin/ctags'
" let g:ctags_statusline=1
" let g:ctags_regenerate=0
" let g:ctags_title=0
" let g:ctags_args='-R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>'

" set vim to chdir for each file
" au BufEnter * if &ft != 'help' | silent! cd %:p:h | endif
" set autochdir

" load the types.vim highlighting file, if it exists
autocmd BufRead,BufNewFile *.[ch] let fname = expand('<afile>:p:h') . '/types.vim'
autocmd BufRead,BufNewFile *.[ch] if filereadable(fname)
autocmd BufRead,BufNewFile *.[ch]   exe 'so ' . fname
autocmd BufRead,BufNewFile *.[ch] endif

" skeleton files
autocmd BufNewFile  *.c	0r ~/.vim/templates/skeleton.c
autocmd BufNewFile  *.cpp	0r ~/.vim/templates/skeleton.c
autocmd BufNewFile  *.h	0r ~/.vim/templates/skeleton.h

" remember between sessions:    10 search terms
"                               info for 10 files (never any on removable disks)
"                               100 lines of registers; including @10 in there should restrict input buffer but it causes an error for me:
"                               _don't_ marks in files or re-highlight old search
set viminfo=/30,'1000,r/media/disk,r/media/disk-1,r/media/disk-2,f0,h,\"100,%

" remember about sessions
set sessionoptions=blank,buffers,curdir,folds,help,winsize

" have command-line completion <Tab> (for filenames, help topics, option names)
" first list the available options and complete the longest common part, then
" have further <Tab>s cycle through the possibilities:
set wildmode=list:longest,full
set wildignore=*.o,*.obj,*.bak,*.exe,.* 

set shortmess+=r " use [RO] for '[readonly]' to save space in the message line:
set showmode     " display the current mode
set showcmd      " and partially-typed commands in the status line:
set nowrap       " don't make it look like there are line breaks where there aren't:
set shiftwidth=2 " use indents of 4 spaces,
set tabstop=2    " and have them copied down lines:
set shiftround
set expandtab
set autoindent
set smarttab
set smartindent  " set smartindent = try to make it like C
"
"""""""""""""""""""""""""""""""""""""""""""""""""""
"       backups 
" adding the trailing backslash stores the entire file path into backup
" direcotry, so multiple project copies can be opened.
set backupdir=$HOME/.backups/vim//
set directory=$HOME/.backups/vim//
"
"""""""""""""""""""""""""""""""""""""""""""""""""""
"       visual stuff 
"""""""""""""""""""""""""""""""""""""""""""""""""""
"
set numberwidth=1
set showmatch	      						" show matches for parens/brackets
set ch=1									      " Make command line one lines high
set winminheight=0              " let windows shrink to filenames only
let c_comment_strings=1         " highlighting strings inside C comments
set showtabline=0               " display tabbar 

" Switch on syntax highlighting if it wasn't on yet.
if !exists("syntax_on")
  syntax on
endif
"
"""""""""""""""""""""""""""""""""""""""""""""""""""
"	filetypes
"""""""""""""""""""""""""""""""""""""""""""""""""""
"
filetype on                                                   " enable filetype detection:
autocmd FileType c set formatoptions+=ro                      " C- if starting a new line in the middle of a comment automatically insert the comment leader characters:
autocmd FileType make set noexpandtab shiftwidth=8            " in makefiles, don't expand tabs to spaces, indentation at 8 chars to be sure that all indents are tabs
autocmd FileType python set expandtab shiftwidth=2 tabstop=2
autocmd FileType c syn match matchName /\(#define\)\@<= .*/
autocmd FileType cpp syn match matchName /\(#define\)\@<= .*/

let python_highlight_all = 1
let python_highlight_space_errors = 1
let python_fold=1
let perl_fold=1
let lua_fold=1
let lua_version = 5
let lua_subversion = 1
let bash_fold=1
set foldmethod=syntax
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"	search& replace
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
set ignorecase " make searches case-insensitive,
set smartcase  " unless they contain upper-case letters:
set incsearch  " show the `best match so far'
set hlsearch   " set highlighted search on
set gdefault   " assume the /g flag on :s substitutions to replace all matches in a line:

"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"	bindings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" becasue im st00pid
map :W<CR> :w<CR>
" toggle search highlights
" map \ :let @/=""<CR>  :echo "Highlights Cleared"<CR> 
nnoremap <space> :noh<CR><C-l>
" for pastebin @ pocoo
map <f12> :Lodgeit<CR>
",v brings up my .vimrc
map ,v :sp $HOME/.vimrc<CR><C-W>_
" ,c i special for writing and reloading my colorscheme file (assumes im already editing it)
map ,c :w<CR>:colorscheme oblivion<CR>
",V reload vimrc
map <silent> ,V :source $HOME/.vimrc<CR>:filetype detect<CR>:exe ":echo 'vimrc reloaded'"<CR>
",r load my vim quick reference card
map ,r :help qrcard<CR><C-W>L:vertical res 60<CR>
",B open .bash_profile
map ,B :sp $HOME/.bashrc<CR><C-W>_
",X open .Xdefualts
map ,X :sp $HOME/.Xdefaults<CR><C-W>_
",A open .awesome rc.lua & theme
map ,A :sp $HOME/.config/awesome/rc.lua<CR><C-W>=
" Spacebar toggles a fold, zi toggles all folding, zM closes all folds
" noremap  <silent>  <space> :exe 'silent! normal! za'.(foldlevel('.')?'':'l')<cr>
" create tags files quickly
map <F8> :!/usr/bin/ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>
" map <F9> :!/usr/bin/ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>
" map <F10> :!/usr/bin/ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>
" toggle taglist
map <silent> ,t :TlistToggle<CR> :colorscheme oblivion<CR>

" comments
noremap <silent> ,# :call CommentLineToEnd('# ')<CR>+
noremap <silent> ,* :call CommentLinePincer('/* ', ' */')<CR>+
noremap <silent> ,/ :call CommentLineToEnd('// ')<CR>+
noremap <silent> ," :call CommentLineToEnd('" ')<CR>+
noremap <silent> ,< :call CommentLinePincer('<!-- ', ' -->')<CR>+
noremap <silent> ,! :call CommentLineToEnd('! ')<CR>+
noremap <silent> ,- :call CommentLineToEnd('-- ')<CR>+
noremap <silent> ,] :call CommentLinePincer('--[[ ', ' --]]')<CR>+

" nmap ,c <Plug>CRV_CRefVimNormal

" Make shift-insert work like in Xterm
map <S-Insert> <MiddleMouse>
map! <S-Insert> <MiddleMouse>

" to cycle through files:
nnoremap ,N :next<CR>
nnoremap ,P :prev<CR>

" flip buffers 
noremap ,n :bnext<CR>
noremap ,p :bprevious<CR>

" change windows quickly
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l
map <C-j> <C-W>j

" resize windows
map <C-m> <C-W>+
map <C-n> <C-W>-
" map <M-m> <M-W><
" map <M-n> <M-W>>

" add and subtract normal mode while in screen
map <C-i> <C-a>

" insert mode - movement w/o 
imap <C-h> <Left>
imap <C-j> <Down>
imap <C-k> <Up>
imap <C-l> <Right>
imap <C-x> <Delete>
imap <C-e> <Esc>eli
imap <C-b> <Esc>bhi
" 
" quick search for buffer 
map <C-b> :buffer 

if has("unix")
  set clipboard=autoselect
  set shell=/bin/bash
endif

if has("gui_running")

  " set the X11 font to use
  set guifont=ProFont\ 8

  set toolbariconsize=tiny
  "	coloring
  colorscheme oblivion		" set colors

endif

