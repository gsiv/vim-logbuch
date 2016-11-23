scriptencoding utf-8

setlocal foldmethod=expr
setlocal foldtext=LogbuchFold(v:lnum) " in ftplugin
if exists('+breakindent')
    setlocal breakindent
    setlocal breakindentopt=shift:4
endif

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
        let next_entry_lnum = searchpos(l:pattern, "sW" . l:dir)[0]
        let l:vcount -= 1
    endwhile
    call setpos('.', [0, next_entry_lnum, 0, 0])
endfunction

function! s:GoToFirstLog()
    " Go to beginning of file
    call setpos('.', [0, 0, 0, 0])
    " Go to beginning first log entry
    call <SID>NextLog(1, 0, 0)
endfunction

function! s:NewLog()
    let l:gerdate = strftime("%d.%m.%Y")
    let l:author = expand("$EMAIL")
    " For author information $EMAIL is preferred with $USER as a fallback.
    if l:author == "$EMAIL"
        let l:author = expand("$USER")
    endif
    call <SID>GoToFirstLog()
    " insert new log entry header
    execute "silent normal! O" . l:gerdate . "\<c-v>\t" . l:author . "\r"
    " insert first bullet point
    execute "silent normal! O* "
endfunction

function! s:NewLogFromTemplate()
    " Copy the entry under the cursor and paste it at the top with an
    " up-to-date date/author header
    let l:gerdate = strftime("%d.%m.%Y")
    let l:author = expand("$EMAIL")
    " For author information $EMAIL is preferred with $USER as a fallback.
    if l:author == "$EMAIL"
        let l:author = expand("$USER")
    endif
    if getline('.') !~? s:dateline_pattern
        " if not already there go back to this entry's header
        call <SID>NextLog(1, 1, 0)
    endif
    let template_lines = []
    let start_lnum = line('.')
    let walk_lnum = start_lnum + 1
    " while line is not the next entry header
    while getline(walk_lnum) !~? s:dateline_pattern
        call add(template_lines, getline(walk_lnum))
        let walk_lnum += 1
    endwhile
    call <SID>GoToFirstLog()
    " insert new log entry header
    " TODO: make function
    let insert_at_lnum = line('.') - 1
    call append (insert_at_lnum + 0, l:gerdate . "\t" . l:author)
    " insert copied entry
    call append(insert_at_lnum + 1, template_lines)
    " Go back to previous entry, i.e., the newly created entry
    call <SID>NextLog(1, 1, 0)
    " update folds, then fully unfold new entry
    execute "silent normal! zxzCzO"
    " Move one line down
    call setpos('.', [0, line('.') + 1, 0, 0])
    " (Maybe) insert TODO marker
    if exists("g:logbuch_cfg_template_marker")
        " if not disabled by user
        if g:logbuch_cfg_template_marker != 0
            call <SID>SetMarker(0)
        endif
    else
        " if no preference configured
        call <SID>SetMarker(0)
    endif
endfunction

" extact <protocol>://<host> from filename
function! s:NetrwHost()
    let l:filename = expand("%")
    " hostname pattern:       | protocol |   hostname    |optional port |
    let l:hostname_pattern = "^[a-z]\\+://[a-z0-9-\\.@]\\+\\(:[0-9]\\+\\)*"
    if l:filename =~? l:hostname_pattern
        let l:netrw_host = fnamemodify(l:filename,
                    \":s?\\(" . l:hostname_pattern . "\/\\).*?\\1?")
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

function! s:SetMarker(pos)
    " The deletions happen separately because it is easier to restore the
    " cursors expected position this way.
    let l:marker = '* v v v v v v v v v v TODO v v v v v v v v v v'
    if a:pos == 1
        let l:opt_insert_below = 1
        let l:insert_lnum = line('.')
    else
        let l:opt_insert_below = 0
        let l:insert_lnum = line('.') - 1
    endif

    let l:wsv = winsaveview()
    call append(l:insert_lnum, l:marker)
    call winrestview(l:wsv)

    let l:wsv = winsaveview()
    " Delete previous markers
    if l:opt_insert_below == 1
        let l:wsv = winsaveview()
        silent execute "?" . s:dateline_pattern . "?,.-0g/" . l:marker . "/d"
        call winrestview(l:wsv)
        let l:wsv = winsaveview()
        silent execute ".+2,/" . s:dateline_pattern . "/-1g/" . l:marker . "/d"
        call winrestview(l:wsv)
    else
        " Delete following markers
        let l:wsv = winsaveview()
        silent execute "?" . s:dateline_pattern . "?,.-2g/" . l:marker . "/d"
        call winrestview(l:wsv)
        let l:wsv = winsaveview()
        silent execute ".+1,/" . s:dateline_pattern . "/-1g/" . l:marker . "/d"
        call winrestview(l:wsv)
    endif
    call winrestview(l:wsv)
endfunction

function! LogbuchFold(lnum)
    let foldchar = matchstr(&fillchars, 'fold:\zs.')
    if v:foldlevel == 1
        " Formatting for completely collapsed entries
        " This gives a summary of the entry's header (date, author)
        " plus the first line of the entry itself
        let headline = getline(v:foldstart)
        let date = matchstr(headline, '[0-9\.]\+')
        " let author = matchstr(headline, '[a-zA-Z-\ ]\+\ze\ <') " full name
        let author = matchstr(headline, '\zs[a-zA-Z-]\+\ze\ ') " first name
        let email = matchstr(headline, '<.*>')
        let content_line = getline(v:foldstart + 1)
        let content_line = substitute(content_line, '\s*\*\s', '', '')
        let line = printf('%s - %s - %s', date, author, content_line)
    else
        " default
        let line = substitute(getline(v:foldstart), '^\s*"\?\s*\|\s*"\?\s*{{' . '{\d*\s*', '', 'g') . ' '
    endif
    let lines_count = v:foldend - v:foldstart + 1
    let lines_count_text = printf(" %s lines", lines_count)
    let summary_line = strpart(line, 0, (winwidth(0)*2)/3) " cut line at 2/3 of window width
    " length of sting(s) that will have to fit on screen
    let foldtextlength = strlen(substitute(summary_line . lines_count_text,
                \'.', 'x', 'g')) + &foldcolumn
    let foldtextlength = foldtextlength + 4 " No idea why we need to add 4 here!
    return summary_line . repeat(foldchar, winwidth(0)-foldtextlength) . lines_count_text
endfunction

function! s:ModifyVisualSelection()
    " Try to make a visual selection pastable by removing leading asterisks.
    " Also remove the final line break to avoid executing commands in the
    " shell.
    " TODO: avoid normal mode?
    let start_pos = getpos('v')
    let end_pos   = getpos("'>")
    " move to beginning of selection
    call setpos('.', start_pos)
    let line = getline('.')
    " Match logbuch entry bullet points ("* ")
    if line =~ "^\\*\\ "
        " - move 2 to exclude the bullet point
        execute "normal! 2l"
    endif
    " - visually select until previous end of selection
    execute "normal! v"
    call setpos('.', end_pos)
    " - move back 1 column to exclude newline
    execute "normal! $h"
endfunction

" }}}

" {{{ <Plug> Mappings
" Navigation: Normal mode
"  logbuch entry date lines
" ]]
noremap <script> <buffer> <silent> <Plug>(logbuch-next-section)
        \ :<C-u>call <SID>NextLog(1, 0, 0)<CR>

" [[
noremap <script> <buffer> <silent> <Plug>(logbuch-prev-section)
        \ :<C-u>call <SID>NextLog(1, 1, 0)<CR>

"  logbuch bullet point lines
" ][
noremap <script> <buffer> <silent> <Plug>(logbuch-next-subsection)
        \ :<C-u>call <SID>NextLog(2, 0, 0)<CR>

" []
noremap <script> <buffer> <silent> <Plug>(logbuch-prev-subsection)
        \ :<C-u>call <SID>NextLog(2, 1, 0)<CR>

" Navigation: Visual mode
" ]]
vnoremap <script> <buffer> <silent> <Plug>(logbuch-next-section)
        \ :<C-u>call <SID>NextLog(1, 0, 1)<CR>

" [[
vnoremap <script> <buffer> <silent> <Plug>(logbuch-prev-section)
        \ :<C-u>call <SID>NextLog(1, 1, 1)<CR>

" ][
vnoremap <script> <buffer> <silent> <Plug>(logbuch-next-subsection)
        \ :<C-u>call <SID>NextLog(2, 0, 1)<CR>

" []
vnoremap <script> <buffer> <silent> <Plug>(logbuch-prev-subsection)
        \ :<C-u>call <SID>NextLog(2, 1, 1)<CR>

" New log
noremap <script> <buffer> <silent> <Plug>(logbuch-new)
        \ :<C-u>call <SID>NewLog()<CR>
" New log from template
noremap <script> <buffer> <silent> <Plug>(logbuch-new-from-template)
        \ :<C-u>call <SID>NewLogFromTemplate()<CR>


" Remote Editing:
" Open file under cursor; like `:e <cfile>` but open on same host as current
" file if using netrw
noremap <script> <buffer> <silent> <Plug>(logbuch-remote-gf)
        \ :<C-u>call <SID>RemoteGF()<CR>
" Open an :edit prompt with the remote (<protocol>://<host>) filled in
noremap <script> <buffer> <silent> <Plug>(logbuch-remote-edit-prompt)
        \ :<C-u>call <SID>NetrwPrompt()<CR>

" Set marker line
noremap <script> <buffer> <silent> <Plug>(logbuch-todo-marker-above)
        \ :<C-u>call <SID>SetMarker(0)<CR>
noremap <script> <buffer> <silent> <Plug>(logbuch-todo-marker-below)
        \ :<C-u>call <SID>SetMarker(1)<CR>

" Modify visual selection
noremap <script> <buffer> <silent> <Plug>(logbuch-modify-selection)
        \ :<C-u>call <SID>ModifyVisualSelection()<CR>

" }}}

" {{{ Default mappings
"
function! s:set_default_key_maps()
    silent execute 'map ]]          <Plug>(logbuch-next-section)'
    silent execute 'map [[          <Plug>(logbuch-prev-section)'
    silent execute 'map ][          <Plug>(logbuch-next-subsection)'
    silent execute 'map []          <Plug>(logbuch-prev-subsection)'

    silent execute 'map <leader>o   <Plug>(logbuch-new)'
    silent execute 'map <leader>O   <Plug>(logbuch-new-from-template)'

    silent execute 'map <leader>gf  <Plug>(logbuch-remote-gf)'
    silent execute 'map <leader>ge  <Plug>(logbuch-remote-edit-prompt)'

    silent execute 'map <leader>lv  <Plug>(logbuch-modify-selection)'
    silent execute 'map <leader>ll  <Plug>(logbuch-todo-marker-above)'
endfunction

if exists("g:logbuch_cfg_no_mapping")
    " if not disabled by user
    if g:logbuch_cfg_no_mapping != 1
        call s:set_default_key_maps()
    endif
else
    call s:set_default_key_maps()
endif
" }}}

" vim: fdm=marker et sw=4 ts=4
