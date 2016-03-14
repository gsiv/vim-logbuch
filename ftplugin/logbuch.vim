scriptencoding utf-8
" {{{ Functions

" Pattern that matches beginnings of new logbuch entries
let s:dateline_pattern = '^[0-9]\{2}\.[0-9]\{2}\.[0-9]\{4}\t'

function! s:NextLog(type, backwards, visual)
	let l:vcount = v:count1
    if a:visual
        normal! gv
    endif
    if a:type == 1
		let l:pattern = s:dateline_pattern
    elseif a:type == 2
        let l:pattern = '^\*\ '
    endif
    if a:backwards
        let l:dir = 'b'
    else
        let l:dir = ''
    endif
	while vcount > 0
		call search(l:pattern, "sW" . l:dir)
		let l:vcount -= 1
	endwhile
endfunction

function! s:NewLog()
	let l:gerdate = strftime("%d.%m.%Y")
	let l:author = expand("$EMAIL")
	" For author information $EMAIL is preferred with $USER as a fallback.
	if l:author == "$EMAIL"
		let l:author = expand("$USER")
	endif
	" find first log entry
	execute "silent normal! gg"
	call <SID>NextLog(1, 0, 0)
	" insert new log entry header
	execute "silent normal! O" . l:gerdate . "\<c-v>\t" . l:author . "\r"
	" insert first bullet point
	execute "silent normal! O* "
endfunction

function! s:NewLogFromTemplate()
	" Yank an entry, paste it at the top and update the date/author line
	" TODO: don't change the user's paste registers?
	let l:gerdate = strftime("%d.%m.%Y")
	let l:author = expand("$EMAIL")
	" For author information $EMAIL is preferred with $USER as a fallback.
	if l:author == "$EMAIL"
		let l:author = expand("$USER")
	endif
	execute "normal! yap"
	" find first log entry
	execute "silent normal! gg"
	call <SID>NextLog(1, 0, 0)
	execute "normal! P"
	" insert new log entry header
	execute "silent normal! C" . l:gerdate . "\<c-v>\t" . l:author
	" insert marker line
	" TODO: make this configurable in ~/.vimrc
	execute "normal! j"
	call <SID>SetMarker()
endfunction

" extact <protocol>://<host> from filename
function! s:NetrwHost()
	let l:filename = expand("%")
	if l:filename =~? "^[a-z]\\+://[a-z0-9-\\.@]\\+/"
		let l:netrw_host = fnamemodify(l:filename,
					\":s?\\(^scp:\\/\\/[a-zA-Z0-9-\\.@]\\+\/\\).*?\\1?")
		return l:netrw_host
	endif
		return ""
endfunction

" Open file under cursor; like `:e <cfile>` but open on same host as current
" file if using netrw
function! s:RemoteGF()
	let l:netrw_host = s:NetrwHost()
	if netrw_host != ""
		let l:linked_file = l:netrw_host . expand("<cfile>")
		execute 'edit ' . fnameescape(l:linked_file)
	else
		execute 'edit <cfile>'
	endif
endfunction

" Open an :edit prompt with the remote (<protocol>://<host>) filled in
function! s:NetrwPrompt()
	let l:netrw_host = s:NetrwHost()
	execute input("", "edit " . l:netrw_host)
endfunction

function! s:SetMarker()
	" Set a TODO marker line and remove other marker lines within the current
	" logbuch entry.
	" The deletions happen separately because it is easier to restore the
	" cursors expected position this way.
	let l:marker = '* v v v v v v v v v v TODO v v v v v v v v v v'
	let l:wsv = winsaveview()
	call append(line('.')-1, l:marker)
	" Delete previous markers
	silent execute "?" . s:dateline_pattern . "?,.-2g/" . l:marker . "/d"
	call winrestview(l:wsv)
	let l:wsv = winsaveview()
	" Delete following markers
	silent execute ".+1,/" . s:dateline_pattern . "/-1g/" . l:marker . "/d"
	call winrestview(l:wsv)
endfunction

" }}}

" {{{ Mappings
" Navigation: Normal mode
"  logbuch entry date lines
noremap <script> <buffer> <silent> ]]
        \ :<C-u>call <SID>NextLog(1, 0, 0)<CR>

noremap <script> <buffer> <silent> [[
        \ :<C-u>call <SID>NextLog(1, 1, 0)<CR>

"  logbuch bullet point lines
noremap <script> <buffer> <silent> ][
        \ :<C-u>call <SID>NextLog(2, 0, 0)<CR>

noremap <script> <buffer> <silent> []
        \ :<C-u>call <SID>NextLog(2, 1, 0)<CR>

" Navigation: Visual mode
vnoremap <script> <buffer> <silent> ]]
        \ :<C-u>call <SID>NextLog(1, 0, 1)<CR>

vnoremap <script> <buffer> <silent> [[
        \ :<C-u>call <SID>NextLog(1, 1, 1)<CR>

vnoremap <script> <buffer> <silent> ][
        \ :<C-u>call <SID>NextLog(2, 0, 1)<CR>

vnoremap <script> <buffer> <silent> []
        \ :<C-u>call <SID>NextLog(2, 1, 1)<CR>

" New log
noremap <script> <buffer> <silent> <leader>ln
        \ :<C-u>call <SID>NewLog()<CR>
" New log from template
noremap <script> <buffer> <silent> <leader>lN
        \ :<C-u>call <SID>NewLogFromTemplate()<CR>


" Remote Editing:
" Open file under cursor; like `:e <cfile>` but open on same host as current
" file if using netrw
noremap <script> <buffer> <silent> <leader>lf
        \ :<C-u>call <SID>RemoteGF()<CR>
" Open an :edit prompt with the remote (<protocol>://<host>) filled in
noremap <buffer> <leader>le :call <SID>NetrwPrompt()<CR>

" Set TODO marker line
noremap <script> <buffer> <silent> <leader>ll
        \ :<C-u>call <SID>SetMarker()<CR>

" }}}

" vim: fdm=marker
