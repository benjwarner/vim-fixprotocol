if exists("b:current_syntax")
  finish
endif

" First field in the line
syn region fixField start="^\d" end="="he=e-1 contains=fixValue
" all other fields in the line
syn region fixField start="" end="="he=e-1 contains=fixValue
" values
syn region fixValue start="="hs=s+1 end="" contained

" Function called when there is a change in the current colorscheme
function! SetFixColors()
	hi def link fixField KeyWord
	hi def link fixValue String
endfunction

" auto command for colorscheme 
augroup FixHLGroup
  autocmd! ColorScheme * call SetToDoColors()
augroup END

call SetFixColors()
let b:current_syntax = "fixprotocol"

