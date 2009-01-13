" Vim color file
" 
":so $VIMRUNTIME/syntax/hitest.vim 

set background=light
hi clear
if exists("syntax_on")
    syntax reset
endif
let g:colors_name="mine"

hi Normal  ctermfg=0  ctermbg=105
"146 188
hi Cursor         ctermfg=232   ctermbg=25
hi MatchParen     ctermfg=17  ctermbg=46
hi helpNormal     ctermfg=231
hi CursorLine     ctermfg=238 ctermbg=NONE
hi Directory      ctermfg=14  
hi DiffAdd        ctermfg=11  ctermbg=18 
hi DiffDelete     ctermfg=124 ctermbg=NONE 
hi DiffChange     ctermfg=22  ctermbg=NONE
hi DiffText       ctermfg=0 ctermbg=NONE  
hi ErrorMsg       ctermfg=15  ctermbg=88
hi Folded         ctermfg=21  ctermbg=NONE
hi IncSearch      ctermfg=251 ctermbg=160
" hi LineNr         ctermbg=238    ctermfg=15  
hi LineNr         ctermfg=57  
hi ModeMsg        ctermfg=15              cterm=bold
hi MoreMsg        ctermfg=59
hi NonText        ctermfg=15  
hi Question       ctermfg=11  
hi Search         ctermfg=8   ctermbg=27  cterm=bold
hi SpecialKey     ctermfg=52
hi Special        ctermfg=94
hi StatusLine     ctermfg=220  ctermbg=18 cterm=none  
hi StatusLineNC   ctermfg=220  ctermbg=63 cterm=none
hi VertSplit   ctermfg=63  ctermbg=63 cterm=none
hi Title          ctermfg=15  
hi TagListFileName ctermfg=17  ctermbg=63 cterm=bold
hi TagListTitle   ctermfg=20 ctermbg=74              cterm=bold
hi TagListTagName ctermfg=18  ctermbg=63  cterm=bold
hi FoldColumn     ctermfg=38  ctermbg=63 cterm=bold
hi Visual         ctermfg=0   ctermbg=250 cterm=none
hi VisualNOS      ctermfg=234 ctermbg=247 cterm=none
hi WarningMsg     ctermfg=230
hi Typedef        ctermfg=14              cterm=bold,underline 
hi Tag            ctermfg=64             cterm=bold
"hi WildMenu  
"hi Menu    
"hi Scrollbar  
"hi Tooltip    
hi Function       ctermfg=228 cterm=bold
hi SpecialComment ctermfg=22 cterm=bold
hi SpellLocal	    ctermfg=0
hi SpellBad       ctermfg=124   ctermbg=NONE
hi SpellCap       ctermfg=0
hi SpellRare       ctermfg=0
" syntax highlighting groups
hi Comment        ctermfg=0
hi Constant       ctermfg=52  
hi Identifier     ctermfg=88  
" hi helpHyperTextJump ctermfg=18  
hi helpHyperTextJump ctermfg=25 
hi Statement      ctermfg=18  
hi PreProc        ctermfg=54
hi Type           ctermfg=18 cterm=bold
hi Underlined     ctermfg=15  
hi Ignore         ctermfg=0  
hi Error          ctermfg=124   ctermbg=NONE  
hi Todo           ctermfg=11  ctermbg=124
hi Define         ctermfg=22             cterm=bold
hi Pmenu          ctermfg=232 ctermbg=250
hi PmenuSel       ctermfg=12  ctermbg=250
hi PmenuSbar      ctermfg=15  ctermbg=237 
hi Boolean        ctermfg=125              cterm=bold
hi cInclude       ctermfg=19 
hi cDefine        ctermfg=192
hi cPreProc       ctermfg=20 
hi cPreCondit     ctermfg=114 
hi cBlock         ctermfg=0
hi cBracket	      ctermfg=11
hi cNumbers	      ctermfg=13
hi cParen	        ctermfg=214
hi cUserCont      ctermfg=214
hi cNumbersCom	  ctermfg=214
hi cMulti	        ctermfg=214
hi cConstant	    ctermfg=214
hi cCppParen      ctermfg=214
hi cCppBracket    ctermfg=214
hi cCommentStart  ctermfg=152
"
" hi link Character  Constant
" hi link Number    Constant
" hi link Float    Number
" hi link Conditional  Statement
" hi link Label    Statement
" hi link Keyword    Statement
" hi link Exception  Statement
" hi link Repeat    Statement
" hi link PreCondit  PreProc
" hi link StorageClass  Type
" hi link Structure  Type
" hi link Delimiter  Special
" hi link SpecialComment  Special
" hi link Debug    Special
" hi link CursorIM Cursor
hi link VertSplit StatusLineNC      
