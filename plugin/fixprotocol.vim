" fixprotocol.vim - converts FIX to xml
" Maintainer:   Vitor Appolinario <http://appolinario.com/>
" Version:      0.2
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
" checks if user has configured the message type translation
if !exists('g:fixprotocol_type_as_comment')
	let g:fixprotocol_type_as_comment = 1
endif

" loads a map with the fix dictionary according with version chosen
function! fixprotocol#initDictionary()
	if g:fixprotocol_fixversion == '44'
		call fix44dict#loadFixDictionary()
	else
		call fix42dict#loadFixDictionary()
	endif
endfunction

"loads a map with the message types
function! fixprotocol#loadMessageTypes()
	call fix44messages#loadMessageTypes()
endfunction

call fixprotocol#initDictionary()
call fixprotocol#loadMessageTypes()

" converts the current line fom fixmessage to Xml
function! fixprotocol#toXml() range
	" save current line
	let s:currentLine = line(".")
	" add the opening xml tag
	call append(s:currentLine-1, '<' . g:fixprotocol_root_tag . '>')
	" transform the msg into xml
	substitute /\([^=]\+\)=\([^=]\+\)\(\%x01\)/\=fixprotocol#getXmlString(submatch(1), submatch(2))/g
	" add line breaks
	substitute /></>\r</g
	" indentation
	exe s:currentLine+1.','.line(".").'>'
	" adds the closing xml tag
	call append(line("."), '</' . g:fixprotocol_root_tag . '>')
	" moves the cursor to next line at the last col ( root tag size plus xml tag </>
	call cursor(line(".")+1,len(g:fixprotocol_root_tag)+3)
endfunction

" get a xml tag with field name and value
function! fixprotocol#getXmlString(field, value)
	let name = fixprotocol#getFieldName(a:field)
	if ( a:field == 35 )
		return fixprotocol#getXmlMessage(name, a:value)
	endif
	return '<' . name  . '>' . a:value . '</' . name . '>'
endfunction

" get a xml tag for message types
function! fixprotocol#getXmlMessage(name, value)
	let type = fixprotocol#getMessageName(a:value)
	let comment = ''
	let temp = ''
	if ( g:fixprotocol_type_as_comment == 1 )
		let comment = '<!-- ' . type  . ' -->'
		let temp = a:value
	else
		let temp = type
		let comment = ''
	endif
	return comment . '<' . a:name  . '>' . temp . '</' . a:name . '>'
endfunction

" get a field name based on field number based on the current
" loaded dictionary
function! fixprotocol#getFieldName(field)
	if has_key(g:fixDictionary, a:field) == 0
		return a:field
	endif
	return g:fixDictionary[a:field]
endfunction

" get a message type name based on a key
function! fixprotocol#getMessageName(key)
	if has_key(g:fixMessageTypes, a:key) == 0
		return a:key
	endif
	return g:fixMessageTypes[a:key]
endfunction

" add the command for command bar
command! FixToXml call fixprotocol#toXml()
