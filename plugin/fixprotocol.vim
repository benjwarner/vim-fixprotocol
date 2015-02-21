" fixprotocol.vim - converts FIX to xml
" Maintainer:   Vitor Appolinario <http://appolinario.com/>
" Version:      0.1
"

"checks if plugin is already loaded or is in compatibility mode
if exists("g:vim_fixprotocol_loaded") || &cp
  finish
endif
let g:vim_fixprotocol_loaded = 1

" checks if user has configured the protocol version
if !exists('g:fixprotocol_fixversion')
	let g:fixprotocol_fixversion = '42'
endif
" checks if user has configured the xml root tag
if !exists('g:fixprotocol_root_tag')
	let g:fixprotocol_root_tag = 'FIXMESSAGE'
endif

" loads a map with the fix dictionary according with version chosen
function! fixprotocol#initDictionary()
	if g:fixprotocol_fixversion == '44'
		call fix44dict#loadFixDictionary()
	else
		call fix42dict#loadFixDictionary()
	endif
endfunction

call fixprotocol#initDictionary()

" converts the current line fom fixmessage to Xml
function! fixprotocol#toXml()
	" add the opening xml tag
	call append(line(".")-1, '<' . g:fixprotocol_root_tag . '>')
	" transform the msg into xml
	:substitute /\([^=]\+\)=\([^=]\+\)\(\%x01\)/\=fixprotocol#getXmlString(submatch(1), submatch(2))/g
	" adds the closing xml tag
	call append(line("."), '</' . g:fixprotocol_root_tag . '>')
endfunction

" get a xml tag with field name and value
function! fixprotocol#getXmlString(field, value)
	let name = fixprotocol#getFieldName(a:field)
	return '<' . name  . '>' . a:value . '</' . name . '>'
endfunction

" get a fiel name based on field number based on the current
" loaded dictionary
function! fixprotocol#getFieldName(field)
	return g:fixDictionary[a:field]
endfunction

" add the command for command bar
command! -bar FixToXml call fixprotocol#toXml()
