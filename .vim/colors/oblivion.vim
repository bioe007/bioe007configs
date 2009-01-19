" vim colorscheme for 256 colors, template from gglucas (oblivion, whoever the
" original author idk) modified by bioe007
"
" This colorscheme script was created using Hans Fugal's colorscheme template
" :so $VIMRUNTIME/syntax/hitest.vim 
hi clear

if version > 580
    hi clear

    if exists("syntax_on")
        syntax reset
    endif
endif

set background=dark
let g:colors_name="oblivion"

hi SpecialKey    ctermfg=244  ctermbg=NONE
hi NonText       ctermfg=239 ctermbg=16
hi Directory     ctermfg=74 ctermbg=NONE
hi ErrorMsg      ctermfg=15 ctermbg=1
hi IncSearch     cterm=reverse ctermfg=202 ctermbg=231
hi Search        ctermfg=231 ctermbg=139
hi MoreMsg       ctermfg=221 ctermbg=NONE
hi ModeMsg       cterm=bold ctermfg=221
hi LineNr        ctermfg=239 ctermbg=16
hi Question      ctermfg=121 ctermbg=NONE

hi StatusLine    ctermfg=black ctermbg=white cterm=NONE
hi StatusLineNC  ctermfg=gray ctermbg=233 cterm=NONE

hi VertSplit     cterm=NONE ctermfg=240 ctermbg=240

hi Title         ctermfg=202 ctermbg=NONE
hi Visual        ctermfg=231 ctermbg=59
hi VisualNOS     cterm=bold,underline
hi WarningMsg    ctermfg=202
hi WildMenu      ctermfg=0 ctermbg=11
hi Folded        ctermfg=221 ctermbg=238
hi FoldColumn    ctermfg=16 ctermbg=239
hi DiffAdd       cterm=bold ctermfg=231 ctermbg=18
hi DiffChange    cterm=bold ctermfg=231 ctermbg=64
hi DiffDelete    cterm=bold ctermfg=231 ctermbg=53
hi DiffText      cterm=bold ctermfg=231 ctermbg=64
hi SignColumn    ctermfg=14 ctermbg=242
hi SpellBad      ctermbg=9 ctermbg=NONE
hi SpellCap      ctermbg=12 ctermbg=NONE
hi SpellRare     ctermbg=13 ctermbg=NONE
hi SpellLocal    ctermbg=14 ctermbg=NONE
hi Pmenu         ctermfg=0 ctermbg=139
hi PmenuSel      ctermfg=0 ctermbg=11
hi PmenuSbar     ctermfg=0 ctermbg=248
hi PmenuThumb    cterm=reverse

hi TabLine       cterm=underline ctermfg=247 ctermbg=16
hi TabLineSel    cterm=bold ctermfg=231
hi TabLineFill   ctermfg=239 ctermbg=16

hi CursorColumn  ctermbg=16
hi CursorLine    cterm=underline ctermbg=16
hi MatchParen    ctermfg=231 ctermbg=139
hi Comment       ctermfg=150 ctermbg=NONE
hi Constant      ctermfg=202 ctermbg=NONE
hi Special       ctermfg=224 ctermbg=NONE
hi Identifier    cterm=bold ctermfg=74 ctermbg=NONE
hi Statement     cterm=bold ctermfg=32 ctermbg=NONE
hi Define        ctermfg=223              cterm=underline
hi PreProc       cterm=underline ctermfg=74
hi Type          ctermfg=123 ctermbg=NONE
hi Underlined    cterm=underline ctermfg=81
hi Ignore        ctermfg=0
hi Error         ctermfg=15 ctermbg=9
hi Todo          ctermfg=0 ctermbg=11
hi String        ctermfg=221 ctermbg=NONE
hi Number        ctermfg=214 ctermbg=NONE
hi Function      ctermfg=139 ctermbg=NONE
hi Normal        ctermbg=0 ctermbg=NONE
hi Cursor        ctermfg=16 ctermbg=231

hi cInclude       ctermfg=111
hi cDefine       ctermfg=223              cterm=bold
hi cPreProc       cterm=underline ctermfg=70 
hi cPreCondit     ctermfg=114 
hi cBlock         ctermfg=11
hi cBracket	      ctermfg=11
hi cNumbers	      ctermfg=10
hi cParen	        ctermfg=21
hi cUserCont      ctermfg=214
hi cNumbersCom	  ctermfg=214
hi cMulti	        ctermfg=214
hi cConstant	    ctermfg=214
hi cCppParen      ctermfg=214
hi cCppBracket    ctermfg=214
hi cCommentStart  ctermfg=80
hi link cComment Comment
hi cConditional  ctermfg=191

hi Function ctermfg=219
hi link luaFunction Function  
hi link luaCond cConditional  
hi link luaNumber cConstant
hi link luaString2 String


hi TagListTitle   ctermfg=35              cterm=bold
hi TagListTagName ctermfg=214 ctermbg=28  cterm=bold
hi TagListFileName ctermfg=42  ctermbg=NONE cterm=underline
hi TagListComment  ctermfg=1
