scriptencoding utf-8
" {{{ Functions

" Pattern that matches beginnings of new logbuch entries
let s:dateline_pattern = '^[0-9]\{2}\.[0-9]\{2}\.[0-9]\{4}\t'

function! s:NextLog(type, backwards, visual)
	let vcount = v:count1
    if a:visual
        normal! gv
    endif
    if a:type == 1
		let pattern = s:dateline_pattern
    elseif a:type == 2
        let pattern = '^\*\ '
    endif
    if a:backwards
        let dir = 'b'
    else
        let dir = ''
    endif
	while vcount > 0
		call search(pattern, "sW" . dir)
		let vcount -= 1
	endwhile
endfunction

function! s:NewLog()
	let author = expand("$EMAIL")
	let gerdate = strftime("%d.%m.%Y")
	" find first log entry
	execute "silent normal! gg"
	call <SID>NextLog(1, 0, 0)
	" insert new log entry header
	execute "silent normal! O" . gerdate . "\<c-v>\t" . author . "\r"
	" insert first bullet point
	execute "silent normal! O* "
endfunction

" extact <protocol>://<host> from filename
function! s:NetrwHost()
	let filename = expand("%")
	if filename =~? "^[a-z]\\+://[a-z0-9-\\.]\\+/"
		let netrw_host = fnamemodify(filename,
					\":s?\\(^scp:\\/\\/[a-zA-Z0-9-\\.]\\+\/\\).*?\\1?")
		return netrw_host
	endif
		return ""
endfunction

" Open file under cursor; like `:e <cfile>` but open on same host as current
" file if using netrw
function! s:RemoteGF()
	let netrw_host = s:NetrwHost()
	if netrw_host != ""
		let linked_file = netrw_host . expand("<cfile>")
		execute 'edit ' . fnameescape(linked_file)
	else
		execute 'edit <cfile>'
	endif
endfunction

" Open an :edit prompt with the remote (<protocol>://<host>) filled in
function! s:NetrwPrompt()
	let netrw_host = s:NetrwHost()
	exe input("", "edit " . netrw_host)
endfunction

function! s:SetMarker()
	" Set a TODO marker line and remove other marker lines within the current
	" logbuch entry.
	" The deletions happen separately because it is easier to restore the
	" cursors expected position this way.
	let marker = '* v v v v v v v v v v TODO v v v v v v v v v v'
	let wsv = winsaveview()
	call append(line('.')-1, marker)
	" Delete previous markers
	silent execute "?" . s:dateline_pattern . "?,.-2g/" . marker . "/d"
	call winrestview(wsv)
	let wsv = winsaveview()
	" Delete following markers
	silent execute ".+1,/" . s:dateline_pattern . "/-1g/" . marker . "/d"
	call winrestview(wsv)
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
