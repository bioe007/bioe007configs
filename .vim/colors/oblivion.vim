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

hi SpecialKey    ctermfg=244
hi NonText       ctermfg=239 ctermbg=16
hi Directory     ctermfg=74
hi ErrorMsg      ctermfg=15 ctermbg=1
hi IncSearch     cterm=reverse ctermfg=202 ctermbg=231
hi Search        ctermfg=231 ctermbg=139
hi MoreMsg       ctermfg=221
hi ModeMsg       cterm=bold ctermfg=221
hi LineNr        ctermfg=239 ctermbg=16
hi Question      ctermfg=121

hi StatusLine    ctermfg=lightgray ctermbg=232 cterm=NONE
hi StatusLineNC  ctermfg=gray ctermbg=240 cterm=NONE

hi VertSplit     cterm=NONE ctermfg=240 ctermbg=240

hi Title         ctermfg=202
hi Visual        ctermfg=231 ctermbg=59
hi VisualNOS     cterm=bold,underline
hi WarningMsg    ctermfg=202
hi WildMenu      ctermfg=0 ctermbg=11
hi Folded        ctermfg=221 ctermbg=239
hi FoldColumn    ctermfg=16 ctermbg=239
hi DiffAdd       cterm=bold ctermfg=231 ctermbg=18
hi DiffChange    cterm=bold ctermfg=231 ctermbg=64
hi DiffDelete    cterm=bold ctermfg=231 ctermbg=53
hi DiffText      cterm=bold ctermfg=231 ctermbg=64
hi SignColumn    ctermfg=14 ctermbg=242
hi SpellBad      ctermbg=9
hi SpellCap      ctermbg=12
hi SpellRare     ctermbg=13
hi SpellLocal    ctermbg=14
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
hi Comment       ctermfg=244
hi Constant      ctermfg=202
hi Special       ctermfg=224
hi Identifier    cterm=bold ctermfg=74
hi Statement     cterm=bold ctermfg=15
hi PreProc       cterm=underline ctermfg=74
hi Type          ctermfg=112
hi Underlined    cterm=underline ctermfg=81
hi Ignore        ctermfg=0
hi Error         ctermfg=15 ctermbg=9
hi Todo          ctermfg=0 ctermbg=11
hi String        ctermfg=221
hi Number        ctermfg=214
hi Function      ctermfg=139
hi Normal        ctermbg=0
hi Cursor        ctermfg=16 ctermbg=231

hi TagListTitle   ctermfg=12              cterm=bold
hi TagListTagName ctermfg=227 ctermbg=27  cterm=bold
hi TagListFileName ctermfg=38  ctermbg=238 cterm=bold

