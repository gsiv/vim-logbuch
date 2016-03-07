scriptencoding utf-8
" {{{ Function
function! s:NextLog(type, backwards, visual)

	let vcount = v:count1

    if a:visual
        normal! gv
    endif

    if a:type == 1
		let pattern = '^[0-9]\{2}\.[0-9]\{2}\.[0-9]\{4}\t'
    elseif a:type == 2
        let pattern = '^\*\ '
    endif

    if a:backwards
        let dir = '?'
    else
        let dir = '/'
    endif

	execute 'silent normal! ' . vcount . dir . pattern . dir . "\r"
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
" }}}

" vim: fdm=marker
