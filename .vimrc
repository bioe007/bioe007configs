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
set nonumber       " show line numbers
set ruler          " cursor pos always shown
set vb t_vb=       " screen flash instead of beeps
set history=550    " have 150 lines of command-line (etc) history:
set undolevels=200 " number of commans
set hidden         " dont require saving to switch buffers
set showmatch      " show matches for parens/brackets
set ch=1           " Make command line one lines high
set winminheight=0 " let windows shrink to filenames only
set shortmess+=r   " use [RO] for to save space in the message line:
set showmode       " display the current mode
set showcmd        " and partially-typed commands in the status line:
set nowrap         " dont wrap long lines
set shiftwidth=4   " use indents of 4 spaces,
set tabstop=4      " and have them copied down lines:
set shiftround
set expandtab
set autoindent
set smarttab
set smartindent

" always auto-update taglist
let Tlist_Auto_Update = 1
" close vim if only tlist is open
let Tlist_Exit_OnlyWindow = 1
" always to taglist processing
let Tlist_Process_File_Always = 1

"{{{1 Status line
"{{{2Status line functions
function! Tname()
    "{{{3 either show the tag name or filetype
    let tname = Tlist_Get_Tagname_By_Line()
    if strlen(tname)
        let tname = Tlist_Get_Tagname_By_Line()
        return "[" . tname . "]"
    elseif strlen(&ft)
        return "[" . &ft . "]"
    else
        return ""
    endif
endfunction
"3}}}
"


"return '[\s]' if trailing white space is detected
"return '' otherwise
function! StatuslineTrailingSpaceWarning()
    "{{{3
    if !exists("b:statusline_trailing_space_warning")
        if search('\s\+$', 'nw') != 0
            let b:statusline_trailing_space_warning = '[\s]'
        else
            let b:statusline_trailing_space_warning = ''
        endif
    endif

    return b:statusline_trailing_space_warning
endfunction
"3}}}

"return the syntax highlight group under the cursor ''
function! StatuslineCurrentHighlight()
    "{{{3
    let name = synIDattr(synID(line('.'), col('.'), 1), 'name')
    if name == ''
        return ''
    else
        return '[' . name . ']'
    endif
endfunction
"3}}}

"return '[&et]' if &et is set wrong
"return '[mixed-indenting]' if spaces and tabs are used to indent
"return an empty string if everything is fine
function! StatuslineTabWarning()
    "{{{3
    if !exists("b:statusline_tab_warning")
        let tabs = search('^\t', 'nw') != 0
        let spaces = search('^ ', 'nw') != 0

        if tabs && spaces
            let b:statusline_tab_warning =  '[mixed-indenting]'
        elseif (spaces && !&et) || (tabs && &et)
            let b:statusline_tab_warning = '[&et]'
        else
            let b:statusline_tab_warning = ''
        endif
    endif
    return b:statusline_tab_warning
endfunction
"3}}}


"return a warning for "long lines" where "long" is either &textwidth or 80 (if
"no &textwidth is set)
"
"return '' if no long lines
"return '[#x, my, $z] if long lines are found, were x is the number of long
"lines, y is the median length of the long lines and z is the length of the
"longest line
function! StatuslineLongLineWarning()
    "{{{3set the long_line_warning based on g:SL_LongLine_Verbose
    if !exists("b:statusline_long_line_warning")
        let long_line_lens = s:LongLines()
        let b:statusline_long_line_warning = ""

        if exists("g:SL_LongLine_Verbose")
            if len(long_line_lens) > 0
                if g:SL_LongLine_Verbose > 1
                    let b:statusline_long_line_warning = "[" .
                                \ '#' . len(long_line_lens) . ", " .
                                \ 'm' . s:Median(long_line_lens) . ", " .
                                \ '$' . max(long_line_lens) . "]"
                elseif g:SL_LongLine_Verbose > 0
                    let b:statusline_long_line_warning = "[". b:bad_line . "]"
                endif
            endif
        endif
    endif
    return b:statusline_long_line_warning
endfunction
"3}}}

function! s:LongLines()
    "{{{3return a list containing the lengths of the long lines in this buffer
    let threshold = (&tw ? &tw : 80)
    let spaces = repeat(" ", &ts)

    let long_line_lens = []

    if exists("b:bad_line")
        unlet b:bad_line
    endif

    let i = 1
    while i <= line("$")
        let len = strlen(substitute(getline(i), '\t', spaces, 'g'))
        if len > threshold
            if !exists("b:bad_line")
                "push the first line as the next bad line
                let b:bad_line = i
            endif
            call add(long_line_lens, len)
        endif
        let i += 1
    endwhile

    return long_line_lens
endfunction
"3}}}


function! s:Median(nums)
    "{{{3find the median of the given array of numbers
    let nums = sort(a:nums)
    let l = len(nums)

    if l % 2 == 1
        let i = (l-1) / 2
        return nums[i]
    else
        return (nums[l/2] + nums[(l/2)-1]) / 2
    endif
endfunction
"3}}}
"2}}}

" controls the output of longline functions
let g:SL_LongLine_Verbose=1

" statusline content/format
"   %#<some syn group># changes color, %* restores nl hilight
set statusline=
set statusline+=%<%-.22f\     " filename

" show tagname or filetype if tags don't exist
set statusline+=%#TagListTagName#%{Tname()}%*

" warnings for various conditions
" display a warning if fileformat isnt unix
set statusline+=%#error#%{&ff!='unix'?'['.&ff.']':''}%*

" display a warning if &et is wrong, or we have mixed-indenting
set statusline+=%#error#%{&ro?'':StatuslineTabWarning()}%*

" warning '\s' if trailing spaces found
set statusline+=%#error#%{&ro?'':StatuslineTrailingSpaceWarning()}
set statusline+=%*

" warning if 'long' line is found
set statusline+=%#error#%{&ro?'':StatuslineLongLineWarning()}
set statusline+=%*

"show modified, or RO
set statusline+=%#SignColumn#%{&mod?'\ [+]':''}
set statusline+=%{&ro?'[RO]':''}
set statusline+=%#DiffText#%w%*
set statusline+=%=                  "left/right separator
set statusline+=%-12.(%b\[0x%B\]%)%*      " current char byte-value/hex
set statusline+=%-12.(\[%l,\ %c%V\]%)%*
set statusline+=%P
set laststatus=2

"1}}}

if !exists("autocommands_loaded")
    let autocommands_loaded = 1
    augroup sbars
        au!
        autocmd bufwritepost * exe "TlistUpdate"
        "recalculate the trailing whitespace warning when idle, and after saving
        autocmd cursorhold,bufwritepost * unlet! b:statusline_trailing_space_warning
        "recalculate the tab warning flag when idle and after writing
        autocmd cursorhold,bufwritepost * unlet! b:statusline_tab_warning
        "recalculate the long line warning when idle and after saving
        autocmd cursorhold,bufwritepost * unlet! b:statusline_long_line_warning
    augroup END
endif

" CLI completion <Tab>
" first list the available options and complete the longest common part, then
" have further <Tab>s cycle through the possibilities:
set wildmode=list:longest,full
set wildignore=*.o,*.obj,*.bak,*.exe

" set wcm=<Tab>      " this breaks :so $VIMRUNTIME/hitest.vim

" remember about sessions
set sessionoptions=blank,buffers,curdir,folds,help,winsize,tabpages

" remember across sessions, nothing from /media
set viminfo=/30,'1000,r/media,f0,h,\"100,%

" mouse enabled
if has('mouse')
    set mouse=a
endif


" {{{ OS dependent options
if has("unix")

    " adding the trailing backslash stores the entire file path into backup
    " direcotry, so multiple project copies can be opened.
    set backupdir=$HOME/.backups/vim//
    set directory=$HOME/.backups/vim//

    " skeleton files
    augroup skelLoad

        " au! deletes old commands
        au!

        autocmd BufNewFile  *.c	0r ~/.vim/templates/skeleton.c
        autocmd BufNewFile  *.cpp	0r ~/.vim/templates/skeleton.c
        autocmd BufNewFile  *.h	0r ~/.vim/templates/skeleton.h
    augroup END

    augroup mail
        au!
        au BufRead /tmp/mutt-* set tw=72
        au BufRead /*/claws-mail/tmp/* set tw=72
        " autocmd FileType mail :nmap <F8> :w<CR>:!aspell -e -c %<CR>:e<CR>
    augroup END

    set clipboard=autoselect
    set shell=/bin/zsh

    set tags=./tags,./TAGS,tags,TAGS,/usr/avr/include/tags,
                \/usr/include/tags,/home/perry/sandbox/tags_global
    let Tlist_Ctags_Cmd = '/usr/bin/ctags'

    " ", Z open .bash_profile
    map ,Z :sp $HOME/.zshrc<CR><C-W>_
    " ", X open .Xdefualts
    map ,X :sp $HOME/.Xdefaults<CR><C-W>_
    " ", A open .awesome rc.lua & theme
    map ,A :sp $HOME/.config/awesome/rc.lua<CR><C-W>=

else
    set backupdir=~/vimfiles/backups//
    set directory=~/vimfiles/backups//

    " "skeleton files
    augroup skelLoad
        au!
        autocmd BufNewFile *.c 0r ~/vimfiles/templates/skeleton.c
        autocmd BufNewFile *.cpp 0r ~/vimfiles/templates/skeleton.c
        autocmd BufNewFile *.h 0r ~/vimfiles/templates/skeleton.h
    augroup END

    set tags=./tags,./TAGS,tags,TAGS,/usr/avr/include/tags,/usr/include/tags
    let Tlist_Ctags_Cmd = $VIM.'/bin/ctags.exe'
endif
" }}}

" {{{ GUI/CLI coloring options
if has("gui_running")

    set mousehide    " Hide the mouse when typing text
    set guioptions-=m
    set go-=b
    set go-=l
    set go-=r
    set go-=T
    set go-=t

    if has("unix")
        "set the X11 font to use
        set guifont=Terminus\ 10
        " set toolbariconsize=tiny
    else
        " windows font to use
        set guifont=Dina:h10:cANSI
    endif

    "	coloring
    let moria_style='dark'
    let moria_fontface='mixed'
    let mycolors = 'moria'

elseif &t_Co == 256
    " set for urxvt-256
    let mycolors = 'apathy'
else
    let mycolors = 'torte'
endif

exe "colorscheme" mycolors
" }}}

"	{{{ filetypes and syntax hilighting
"
" Switch on syntax hilighting if it wasn't on yet.
if !exists("syntax_on")
    syntax on
endif


" enable filetype detection:
filetype on

augroup ftypes
    "{{{ft behaviors
    au!

    " load the types.vim highlighting file, if it exists
    autocmd BufRead, BufNewFile *.[ch]
                \let fname = expand('<afile>:p:h') . '/types.vim'
    autocmd BufRead, BufNewFile *.[ch] if filereadable(fname)
    autocmd BufRead, BufNewFile *.[ch]   exe 'so ' . fname
    autocmd BufRead, BufNewFile *.[ch] endif

    " if starting a new line in the middle of a comment automatically insert
    " the comment leader characters:
    autocmd FileType c set et formatoptions+=ro sw=4 ts=4 tw=80
    autocmd FileType c syn match matchName /\(#define\)\@<= .*/
    autocmd FileType cpp syn match matchName /\(#define\)\@<= .*/

    " in makefiles, don't expand tabs to spaces, indentation at 8 chars
    " to be sure that all indents are tabs
    autocmd FileType make set noet sw=8 tw=80

    autocmd FileType python set et sw=4 ts=8 sts=4 fdm=indent tw=80
    filetype plugin on
    filetype indent on
augroup END
"}}}

"ft options
let c_comment_strings= 1 " highlighting strings inside C comments
let python_highlight_all = 1
let python_highlight_space_errors = 1
let python_fold=1
let perl_fold=1
let lua_fold=1
let lua_version = 5
let lua_subversion = 1
let bash_fold=1
set foldmethod=syntax
set textwidth=80

" }}}

"	{{{ search & replace
"
function! FixCommaSep(noconfirm)
    "Fix ugly comma usage
    "
    "e.g. foo(a,b ,c) -> foo(a, b, c)
    if a:noconfirm == 0
        let confirm = 'c'
    else
        let confirm = ''
    endif

    " see if there are any matches in this file
    let messedLine = search('\S,\S', 'Wn')
    if messedLine != 0
        exe '%s:\(\S\),\(\S\):\1, \2:g' . confirm
    else
        echo 'FixCommaSep: No matches found for \S,\S'
    endif


    let messedLine = search('\S ,\S', 'Wn')
    if messedLine != 0
        exe '%s:\(\S\) ,\(\S\):\1, \2:g' . confirm
    else
        echo 'FixCommaSep: No matches found for \S ,\S'
    endif

endfunction

set ignorecase " make searches case-insensitive,
set smartcase  " unless they contain upper-case letters:
set incsearch  " show the `best match so far'
set hlsearch   " set highlighted search on

" }}}

"	{{{ bindings
"
" clear search highlights
noremap <silent> <space> :noh<CR>
"fix comma spacing quickly
map fc :call FixCommaSep(0)<CR>

" noremap <silent> <space> :noh<CR><C-l>
" for pastebin @ pocoo
map <f12> :Lodgeit<CR>
", v brings up my .vimrc
map ,v :sp $HOME/.vimrc<CR><C-W>_
", V reload vimrc
map <silent> ,V :source $HOME/.vimrc<CR>:filetype detect<CR>
            \:exe ":echo 'vimrc reloaded'"<CR>
" ,c for writing and reloading my colorscheme file
" (assumes im already editing it)
map ,c :w<CR>:colorscheme apathy<CR>
", r load my vim quick reference card
map ,r :help qrcard<CR><C-W>L:vertical res 60<CR>

" strip trailing whitespace
map ,s :%s:\s\+$::<CR>

function! MyGoToLongLine()
    "{{{ Helper function moves to the next long line in buffer
    if exists("b:bad_line")
        call cursor(b:bad_line, (&tw ? &tw : 80))
        norm! zv
        norm! z<CR>
        call cursor(b:bad_line, (&tw ? &tw : 80))
        norm! b
    endif
endfunction
"}}}

map ,l :call MyGoToLongLine()<CR>


" create tags files quickly
map <F8> :!/usr/bin/ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>
" toggle taglist
map <silent> ,t :TlistToggle<CR>  :colorscheme apathy<CR>

" comments
noremap <silent> ,# :call CommentLineToEnd('# ')<CR>+
noremap <silent> ,* :call CommentLinePincer('/* ', ' */')<CR>+
noremap <silent> ,/ :call CommentLineToEnd('// ')<CR>+
noremap <silent> ," :call CommentLineToEnd('" ')<CR>+
noremap <silent> ,< :call CommentLinePincer('<!-- ', ' -->')<CR>+
noremap <silent> ,! :call CommentLineToEnd('! ')<CR>+
noremap <silent> ,- :call CommentLineToEnd('-- ')<CR>+

" Make shift-insert work like in Xterm
map <S-Insert> <MiddleMouse>
map! <S-Insert> <MiddleMouse>

" change windows quickly
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l
map <C-j> <C-W>j

" resize windows
map <C-m> <C-W>+
map <C-n> <C-W>-

" insert mode - movement
imap <C-h> <Left>
imap <C-j> <Down>
imap <C-k> <Up>
imap <C-l> <Right>
imap <C-x> <Delete>
imap <C-e> <Esc>eli
imap <C-b> <Esc>bhi

" quick search for buffer
map ,b :buffer

" }}}

if !exists(":DiffOrig")
    command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
                \ | wincmd p | diffthis
endif

set printexpr=PrintFile(v:fname_in)
function! PrintFile(fname)
    system('lpr' . (&printdevice == '' ? '' : ' -P' . &printdevice) .
                \' ' . a:fname_in)
    delete(a:fname_in)
    return a:shell_error
    " call system("/home/perry/.bin/tprint " . a:fname)
    " call delete(a:fname)
    " return v:shell_error
endfunc



" vim: fdm=marker ts=4 sw=4 et sta ai si:
