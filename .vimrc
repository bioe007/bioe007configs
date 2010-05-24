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
set history=550    " have 550 lines of command-line (etc) history:
set undolevels=200 " number of commands
set hidden         " dont require saving to switch buffers
set nowrap         " dont wrap long lines
set shiftwidth=4   " use indents of 4 spaces,
set tabstop=4      " and have them copied down lines:
set shiftround     " round indent to multiple of sw
set expandtab      " use spaces instead of tabs
set autoindent     " copy indent from prev line or syn
set smarttab       " smartly handle the tab/space thing

" {{{1 OS dependent options
if has("unix")
    "{{{2

    " adding the trailing backslash stores the entire file path into backup
    " direcotry, so multiple project copies can be opened.
    let g:my_vimrc = $HOME . "/.vimrc"
    let g:my_vimdir = $HOME . "/.vim"
    let g:my_guifont = "Profont\ 12"

    set clipboard=autoselect
    set shell=/bin/zsh

    set tags=./tags,./TAGS,tags,TAGS,/usr/avr/include/tags,
                \/usr/include/tags
    let my_ctags_cmd = '/usr/bin/ctags'

    augroup mail
        "{{{3 settings for mutt
        au!

        function! MailStripSigDupes()
            "{{{4remove signature block if its already in the mail
            let signature_match = '-- \_.\+Perry Hargrave\_.\+\*\* End of'
                        \. ' statement \*\*'
            let quoted_signature_match = '> -- \_.\+\*\* End of statement \*\*'

            " successive calls to search will move the cursor to where these
            " match, then can just dG because the signature must have been
            " appended to the mail
            if search(quoted_signature_match) != 0
                "move one line down so we don't find the quoted match again
                norm! j
                let sig_start = search(signature_match)
                if sig_start != 0
                " remove signature from sig_start to EOF
                norm! dG
                endif
            endif
            echo 'leaving sig strip'
        endfunction
        "4}}}

        au BufReadPost /tmp/mutt-* call  MailStripSigDupes()

    augroup END
    "3}}}
    "2}}}
else
    "{{{2windows
    let g:my_vimrc = "X:/.vimrc"
    let g:my_vimdir = $HOME . "/_vim"
    let g:my_guifont = "Dina:h10:cANSI"

    let &tags="X:/sandbox/tags,./tags,./TAGS,tags,TAGS"
    let my_ctags_cmd = $VIM . '/bin/ctags.exe'
    "2}}}
endif
"1}}}
let &runtimepath=my_vimdir . "," . &runtimepath
let &backupdir=my_vimdir.'/var/backups//'
let &directory=my_vimdir.'/var/swap//'

augroup skelLoad
    "{{{3 skeleton files
    au!
    exe "au BufNewFile  *.c 0r" my_vimdir."/templates/skeleton.c"
    exe "au BufNewFile  *.cpp 0r" my_vimdir."/templates/skeleton.cpp"
    exe "au BufNewFile  *.h 0r" my_vimdir."/templates/skeleton.h"
    exe "au BufNewFile  *.lua 0r" my_vimdir."/templates/skeleton.lua"
    exe "au BufNewFile  *.py 0r" my_vimdir."/templates/skeleton.py"
augroup END
"3}}}

"{{{1 Tag list options
let Tlist_Ctags_Cmd = my_ctags_cmd
" always auto-update taglist
let Tlist_Auto_Update = 1
" close vim if only tlist is open
let Tlist_Exit_OnlyWindow = 1
" always to taglist processing
let Tlist_Process_File_Always = 1
"1}}}

"""{{{1 Appearance
set nonumber       " dont show line numbers
set vb t_vb=       " no flash
set showmatch      " show matches for parens/brackets
set ch=1           " Make command line one lines high
set winminheight=0 " let windows shrink to filenames only
set shortmess+=aI  " use [RO] for to save space in the message line:
set showmode       " display the current mode
set showcmd        " and partially-typed commands in the status line:
set scrolloff=5    " keep cursor +/- 5 lines in window
set ruler          " cursor pos always shown

"{{{2 Status line
"{{{3Status line functions
function! Tname()
    "{{{4 either show the tag name or filetype
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
"4}}}

function! StatuslineTrailingSpaceWarning()
    "{{{4return '[\s]' if trailing white space is detected
    if !exists("b:statusline_trailing_space_warning")
        let b:statusline_trailing_space_warning = search('\s\+$', 'nw')

        if b:statusline_trailing_space_warning == 0
            let b:statusline_trailing_space_warning = ''
        else
            let b:statusline_trailing_space_warning =
                        \'[\s' . b:statusline_trailing_space_warning . ']'
        endif
    endif

    return b:statusline_trailing_space_warning
endfunction
"4}}}

function! StripTrailingSpace()
    "{{{4remove all trailing whitespace from buffer
    if search('\s\+$', 'nw') != 0
        norm! mZ
        exe '%s:\s\+$::'
        unlet! b:statusline_trailing_space_warning
        call StatuslineTrailingSpaceWarning()
        norm! gZ

    else
        echo 'No lines with trailing space'
    endif
endfunction
"}}}

function! StatuslineCurrentHighlight()
    "{{{4return the syntax highlight group under the cursor ''
    let name = synIDattr(synID(line('.'), col('.'), 1), 'name')
    if name == ''
        return ''
    else
        return '[' . name . ']'
    endif
endfunction
"4}}}

function! StatuslineTabWarning()
    "{{{4set the b:statusline_tab_warning string
    "return '[&et]' if &et is set wrong
    "return '[mixed-indenting]' if spaces and tabs are used to indent
    "return an empty string if everything is fine
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
"4}}}

function! StatuslineLongLineWarning()
    "{{{4set the long_line_warning based on g:SL_LongLine_Verbose
    "warning for "long lines" where "long" is either &textwidth or 80
    "
    "return '' if no long lines return '[#x, my, $z] if long lines are found,
    "were x is the number of long lines, y is the median length of the long
    "lines and z is the length of the longest line
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
                    let b:statusline_long_line_warning = "[". b:long_line . "]"
                endif
            endif
        endif
    endif
    return b:statusline_long_line_warning
endfunction
"4}}}

function! s:LongLines()
    "{{{4return a list containing the lengths of the long lines in this buffer
    let threshold = (&tw ? &tw : 80)
    let spaces = repeat(" ", &ts)

    let long_line_lens = []

    if exists("b:long_line")
        unlet b:long_line
    endif

    let i = 1
    while i <= line("$")
        let len = strlen(substitute(getline(i), '\t', spaces, 'g'))
        if len > threshold
            if !exists("b:long_line")
                "push the first line as the next bad line
                let b:long_line = i
            endif
            call add(long_line_lens, len)
        endif
        let i += 1
    endwhile

    return long_line_lens
endfunction
"4}}}

function! s:Median(nums)
    "{{{4find the median of the given array of numbers
    let nums = sort(a:nums)
    let l = len(nums)

    if l % 2 == 1
        let i = (l-1) / 2
        return nums[i]
    else
        return (nums[l/2] + nums[(l/2)-1]) / 2
    endif
endfunction
"4}}}
"3}}}

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
set statusline+=%#SignColumn#%{&mod?'[+]':''}
set statusline+=%{&ro?'[RO]':''}
set statusline+=%#DiffText#%w%*
set statusline+=%=                  "left/right separator
set statusline+=%-12.(\[%l,\ %c%V\]%)%*
set statusline+=%P
set laststatus=2

if !exists("autocommands_loaded")
    "{{{3Autocommands for statusline
    let autocommands_loaded = 1
    augroup sbars
        au!
        " update taglist information whenever a buffer is written
        au bufwritepost * exe "TlistUpdate"
        "recalculate the trailing whitespace warning when idle, and after saving
        au cursorholdi,cursorhold,bufwritepost * unlet!
                    \ b:statusline_trailing_space_warning
        "recalculate the tab warning flag when idle and after writing
        au cursorhold,bufwritepost * unlet! b:statusline_tab_warning
        "recalculate the long line warning when idle and after saving
        au cursorholdi,cursorhold,bufwritepost * unlet!
                    \ b:statusline_long_line_warning
    augroup END
endif
"3}}}
"2}}}

if has("gui_running")
    " {{{2 GUI/CLI coloring options
    set mousehide    " Hide the mouse when typing text
    " hide all gui elements
    set guioptions=
    let fontop = ":set guifont=" . g:my_guifont
    " exe "set guifont=" . g:my_guifont
    exe fontop

    echo "gui running stuff now"

    "coloring
    let moria_style='dark'
    let moria_fontface='mixed'
    let g:my_colors = 'moria'

elseif &t_Co == 256
    " set for urxvt-256
    let g:my_colors = 'apathy'
else
    let g:my_colors = 'torte'
endif

exe ":colorscheme" g:my_colors
"2}}}

"1}}}

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

"{{{ filetypes and syntax hilighting
"
" Switch on syntax hilighting if it wasn't on yet.
if !exists("syntax_on")
    syntax on
endif

augroup ftypes
    "{{{ft behaviors
    au!

    " enable filetype detection:
    filetype on


    au FileType * set et sw=4 ts=8 sts=4 fdm=syntax tw=80

    " load the types.vim highlighting file, if it exists
    function! LoadTypesHilights()
        let fname = expand('<afile>:p:h') . '/types.vim'
        if filereadable(fname)
            exe 'so ' . fname
        endif
    endfunction

    au BufRead,BufNewFile *.[ch] call LoadTypesHilights()

    " if starting a new line in the middle of a comment automatically insert
    " the comment leader characters:
    au FileType c set et formatoptions+=ro
    au FileType c syn match matchName /\(#define\)\@<= .*/
    au FileType cpp syn match matchName /\(#define\)\@<= .*/

    " in makefiles, don't expand tabs to spaces, indentation at 8 chars
    " to be sure that all indents are tabs
    au FileType make set noet sw=8

    au FileType python,lua set fdm=indent
    au BufRead,BufNewFile *.lua.in set ft=lua

    " git TAG descriptions are recognized as 'conf' files..
    au BufRead,BufNewFile .git/TAG* set ft=gitcommit
    au FileType vcscommit set tw=72
    au FileType gitcommit set tw=72
    au FileType gitcommit call setpos('.', [0, 1, 1, 0])

    au FileType java set ft=javascript

    au BufRead,BufNewFile *.txt set tw=72
    au FileType mail set tw=72
    au FileType mail :nmap <F8> :w<CR>:!aspell -e -c %<CR>:e<CR>

    filetype plugin on
    filetype indent on

    "ft options
    let c_comment_strings= 1 " highlighting strings inside C comments
    let python_highlight_all = 1
    let python_highlight_space_errors = 1
    let python_fold = 1
    let perl_fold = 1
    let lua_fold = 1
    let lua_version = 5
    let lua_subversion = 1
    let g:is_bash = 1             " i use zsh, but meh
    let g:sh_fold_enabled = 7     " allow all folds in bash
augroup END
"}}}


"}}}

"{{{ search & replace
"
function! FixCommaSep(noconfirm)
    "{{{ Fix ugly comma usage

    "e.g. foo(a,b ,c) -> foo(a, b, c)
    if a:noconfirm == 0
        "{{{ check before every fix or not?
        let confirm = 'c'
    else
        let confirm = ''
    endif
    "}}}

    " search check and substitution commands
    " white space+ before comma, close-{paren, brace, bracket}
    " white space+ after open-{paren, brace, bracket}
    let mylist = [
                \ ['\S,\S',     '%s:\(\S\),\(\S\):\1, \2:g'],
                \ ['\S\s\+,\S', '%s:\(\S\)\s\+,\(\S\):\1, \2:g'],
                \ ['\S\s\+,\s\+\S', '%s:\(\S\)\s\+,\s\+\(\S\):\1, \2:g'],
                \ ['\S+\S',     '%s:\(\S\)+\(\S\):\1 + \2:g'],
                \ ['\S\s\++\S', '%s:\(\S\)\s\++\(\S\):\1 + \2:g'],
                \ ['\S\s\+}',   '%s:\(\S\)\s\+}:\1}:g'],
                \ ['{\s\+',     '%s:{\s\+:{:g'],
                \ ['\S\s\+)',   '%s:\(\S\)\s\+):\1):g'],
                \ ['(\s\+',     '%s:(\s\+:(:g'],
                \ ['\S\s\+]',   '%s:\(\S\)\s\+]:\1]:g'],
                \ ['[\s\+',     '%s:\[\s\+:[:g'],
                \]
    for pair in mylist
        if search(pair[0], 'wn')
            exe pair[1] . confirm
        endif
    endfor

endfunction
"}}}

set ignorecase " make searches case-insensitive,
set smartcase  " unless they contain upper-case letters:
set incsearch  " show the `best match so far'
set hlsearch   " set highlighted search on

"}}}

"{{{ bindings
"
" clear search highlights
noremap <silent> <space> :noh<CR>
"fix comma spacing quickly
map fc :call FixCommaSep(0)<CR>

" noremap <silent> <space> :noh<CR><C-l>
" for pastebin @ pocoo
map <f12> :Lodgeit<CR>
", v brings up my .vimrc
map ,v :exe "sp" g:my_vimrc<CR>
", V reload vimrc
" map <silent> ,V :exe "source" $HOME/g:my_vimrc
map <silent> ,V :exe "source" g:my_vimrc<CR>
            \:filetype detect<CR>
            \:exe ":echo 'vimrc reloaded'"<CR>
" ,c for writing and reloading my colorscheme file
" (assumes im already editing it)
map ,c :w<CR>
            \:exe "colorscheme" g:my_colors<CR>
", r load my vim quick reference card
map ,r :help qrcard<CR><C-W>L:vertical res 60<CR>

" strip trailing whitespace
map <silent> ,s :call StripTrailingSpace()<CR>

function! MyGoToLongLine()
    "{{{ Helper function moves to the next long line in buffer
    if exists("b:long_line")
        call cursor(b:long_line, (&tw ? &tw : 80))
        " unfold, then move cursor line to top of window and move back a word
        norm! zv
        norm! zt
        norm! b
    else
        echo "No long lines found"
    endif
endfunction
"}}}
map <silent> ,l :call MyGoToLongLine()<CR>

" create tags files quickly
map <F8> :exe "! " my_ctags_cmd
            \" -R --c++-kinds=+p --fields=+iaS --extra=+q "<CR>

" toggle taglist
map <silent> ,t :TlistToggle<CR>
"exe "colorscheme" g:my_colors<CR>

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

"}}}

if !exists(":DiffOrig")
    "this really doesnt seem to work right..
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

" vim: fdm=marker
