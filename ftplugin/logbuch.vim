" ftplugin/logbuch.vim: logbuch.vim functions, commands, and settings
" Copyright (C) 2016, 2017 Gernot Schulz <gernot@intevation.de>
"
" This program is free software; you can redistribute it and/or modify
" it under the terms of the GNU General Public License as published by
" the Free Software Foundation; either version 2 of the License, or
" (at your option) any later version.
"
" This program is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
" GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with this program; if not, see <http://www.gnu.org/licenses/>.

scriptencoding utf-8

" Pattern that matches beginnings of new logbuch entries
let s:dateline_pattern = '^[0-9]\{2}\.[0-9]\{2}\.[0-9]\{4}\t'

let s:user = $LOGNAME
let s:screen_exchange = "/tmp/logbuch-screen-exchange-" . s:user

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
        \ :<C-u>call <SID>NetrwEditFilePrompt()<CR>
" Open an :edit prompt for a new host
noremap <script> <buffer> <silent> <Plug>(logbuch-remote-new-host)
        \ :<C-u>call <SID>NetrwNewHostPrompt()<CR>
" Open an :edit prompt for a new host after applying regex substitution
noremap <script> <buffer> <silent> <Plug>(logbuch-remote-substitute-host)
        \ :<C-u>call <SID>NetrwNewHostSubstitutePrompt()<CR>
" Reload the current buffer (:edit)
noremap <script> <buffer> <silent> <Plug>(logbuch-remote-reload-buffer)
        \ :<C-u>call <SID>NetrwRefreshTimestampOnEdit()<CR>

" Set marker line
noremap <script> <buffer> <silent> <Plug>(logbuch-todo-marker-above)
        \ :<C-u>call <SID>InsertMarker(0)<CR>
noremap <script> <buffer> <silent> <Plug>(logbuch-todo-marker-below)
        \ :<C-u>call <SID>InsertMarker(1)<CR>

" Modify visual selection
noremap <script> <buffer> <silent> <Plug>(logbuch-modify-selection)
        \ :<C-u>call <SID>ModifyVisualSelection()<CR>

" Yank text to X selection
noremap <script> <buffer> <silent> <Plug>(logbuch-yank-to-xselection)
        \ :<C-u>call <SID>YankToXSel()<CR>

" No-X Editing:
" Mapping for interaction with screen's copy/paste buffer:
noremap <script> <buffer> <silent> <Plug>(logbuch-write-screenexchange)
        \ :<C-u>call <SID>WriteToScreenExchangeFile()<CR>
" tmux
noremap <script> <buffer> <silent> <Plug>(logbuch-tmux-setpastebuffer)
        \ :<C-u>call <SID>TmuxSetPasteBuffer()<CR>


" }}}
" {{{ Default mappings
"
function! s:set_default_key_maps()
    silent execute 'map <buffer> ]]          <Plug>(logbuch-next-section)'
    silent execute 'map <buffer> [[          <Plug>(logbuch-prev-section)'
    silent execute 'map <buffer> ][          <Plug>(logbuch-next-subsection)'
    silent execute 'map <buffer> []          <Plug>(logbuch-prev-subsection)'

    silent execute 'map <buffer> <leader>o   <Plug>(logbuch-new)'
    silent execute 'map <buffer> <leader>O   <Plug>(logbuch-new-from-template)'

    silent execute 'map <buffer> <leader>gf  <Plug>(logbuch-remote-gf)'
    silent execute 'map <buffer> <leader>ge  <Plug>(logbuch-remote-edit-prompt)'
    silent execute 'map <buffer> <leader>gr  <Plug>(logbuch-remote-reload-buffer)'

    " silent execute 'vmap <buffer> <leader>lv <Plug>(logbuch-modify-selection)'
    silent execute 'map <buffer> <leader>ll  <Plug>(logbuch-todo-marker-above)'
    silent execute 'map <buffer> <leader>ln  <Plug>(logbuch-remote-new-host)'
    silent execute 'map <buffer> <leader>lN  <Plug>(logbuch-remote-substitute-host)'

    " Copying
    silent execute 'vmap <leader>ly <Plug>(logbuch-yank-to-xselection)'
    silent execute 'vmap <leader>lx <Plug>(logbuch-write-screenexchange)'
    silent execute 'vmap <leader>lt <Plug>(logbuch-tmux-setpastebuffer)'

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

if !exists("g:logbuch_mod_times")
    " Init modification time array
    let g:logbuch_mod_times = {}
endif

if exists("g:loaded_logbuch_plugin")
  finish
endif
let g:loaded_logbuch_plugin = 1

" {{{ Command definitions
if !exists(":LogbuchExchange")
    command LogbuchExchange call <SID>SetUpScreenExchange()
endif

" }}}

" {{{1 Functions
" {{{2 Basic
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
            call <SID>ManageMarker('.', 1, 0)
        endif
    else
        " if no preference configured
        call <SID>ManageMarker('.', 1, 0)
    endif
endfunction

function! s:InsertMarker(pos)
    " Function for the insert marker mappings (logbuch-todo-marker-above
    " & logbuch-todo-marker-below).
    if a:pos == 1
        let l:opt_insert_below = 1
        let l:insert_lnum = line('.')
    else
        let l:opt_insert_below = 0
        let l:insert_lnum = line('.') - 1
    endif
    call <SID>ManageMarker(l:insert_lnum, l:opt_insert_below, 0)
endfunction

function! s:ManageMarker(line, pos, fromvisual)
    " Function to actually insert the marker line
    let l:marker = '* v v v v v v v v v v TODO v v v v v v v v v v'
    let l:wsv = winsaveview()
    let l:insert_lnum = a:line
    call append(l:insert_lnum, l:marker)
    call winrestview(l:wsv)

    " The deletions happen separately because it is easier to restore the
    " cursor's expected position this way.
    let l:wsv = winsaveview()
    if a:fromvisual == 1
        " Move to end of selection.  This is where the cursor would move anyway if
        " we did the select, yank, set cursor actions manually.  Setting the
        " position here explicitly is only necessary to be able to reuse the
        " following expressions internally.
        let l:end_pos = line("'>")
        call setpos('.', [0, l:end_pos, 0, 0])
    endif
    " Delete previous markers
    if a:pos == 1
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
        let author = matchstr(headline, '\zs[a-zA-Z-]\+\ze\ \?') " first name
        let email = matchstr(headline, '<.*>')
        let content_line = getline(v:foldstart + 1)
        let content_line = substitute(content_line, '\s*\*\s', '', '')
        let line = printf('%s - %s - %s', date, author, content_line)
    else
        " default
        let line = substitute(getline(v:foldstart),
              \ '^\s*"\?\s*\|\s*"\?\s*{{' . '{\d*\s*', '', 'g') . ' '
    endif
    let lines_count = v:foldend - v:foldstart + 1
    let lines_count_text = printf(" %s lines", lines_count)
    " cut line at 2/3 of window width
    let summary_line = strpart(line, 0, (winwidth(0)*2)/3)
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

function! s:YankToXSel()
    call <SID>ModifyVisualSelection()
    " yank selection to register *
    silent execute 'normal! "*y'
    call <SID>ManageMarker(line("'>"), 1, 1)
    " Echo copied text
    echohl LogbuchInfo
    echo "Copied to register *:"
    echohl None
    echo @*
endfunction
" 2}}}

" {{{2 Remote editing (Netrw)
function! s:NetrwGetInfo(filename)
    " Return a list of protocol, hostname, filename, e.g.,
    "['scp://', '127.1', '/etc/logbuch.txt'].

    " hostname pattern:       | protocol |   hostname    |optional port |
    let l:hostname_pattern = "^[a-z]\\+://[a-z0-9-\\.@]\\+\\(:[0-9]\\+\\)*"
    if a:filename =~? l:hostname_pattern
        let l:netrw_host = fnamemodify(a:filename,
                    \":s?\\(" . l:hostname_pattern . "\/\\).*?\\1?")
        " protocol
        let l:protocol = substitute(l:netrw_host, "^\\w\\+://\\zs.*", "", "")
        " strip protocol
        let l:hostname = substitute(l:netrw_host, "^[^\/]*", "", "")
        " strip remaining slashes around hostname
        let l:hostname = substitute(l:hostname, "\/", "", "g")
        " get file path by removing protocol+hostname
        let l:path = substitute(a:filename, l:netrw_host, "", "")
        return [l:protocol, l:hostname, l:path]
    endif
        return []
endfunction

function! s:NetrwSSHCmd(hostname, cmd)
    return system("ssh " . a:hostname . " \"" . a:cmd . " \"")
endfunction

" Open file under cursor; like `:e <cfile>` but open on same host as current
" file if using netrw
function! s:RemoteGF()
    let l:netrw_host = s:NetrwGetInfo(expand('%'))
    if ! empty(l:netrw_host)
        let l:linked_file = l:netrw_host[0] . l:netrw_host[1]
                    \ . "/" . expand("<cfile>")
        execute 'edit ' . fnameescape(l:linked_file)
    else
        execute 'edit <cfile>'
    endif
endfunction

" Open an :edit prompt with the remote (<protocol>://<host>) filled in
function! s:NetrwEditFilePrompt()
    let l:netrw_host = s:NetrwGetInfo(expand('%'))
    if ! empty(l:netrw_host)
        let l:path = input("Edit file on " . l:netrw_host[1] . ": ", "")
        if l:path != ""
            execute "edit " . l:netrw_host[0] . l:netrw_host[1] . "/" . l:path
        endif
    else
        " If no netrw host was found, offer a normal :edit prompt.  Actually,
        " this kind of recreates an :edit prompt; there is probably a better
        " way to enter the actual command line.
        let l:path = input(":edit ", "", "file")
        if l:path != ""
            execute "edit " . l:path
        endif
    endif
endfunction

" Open an :edit prompt for a new host
function! s:NetrwNewHostPrompt()
    let l:new_host = input("Edit logbuch on host: ", "scp://root@")
    " return of aborted
    if len(l:new_host) == 0
        " clear prompt
        normal :<ESC>
        return 0
    endif
    execute input("", ":edit " . l:new_host . "//etc/logbuch.txt")
endfunction

" Open an :edit prompt for a new host.  Unlike NetrwNewHostPrompt the new
" hostname is not given directly but determined by a regex that modifies the
" current hostname.
function! s:NetrwNewHostSubstitutePrompt()
    let l:netrw_host = s:NetrwGetInfo(expand('%'))
    " protocol + hostname as string:
    let l:netrw_host = join(l:netrw_host[:1], "")
    let l:regex_input = input("Substitute in hostname: s/", "")
    " This is a dumb regex parser.  It won't recognize escaped slashes or
    " allow alternative separators like Vim would.  Considering that it will
    " only ever be used for hostnames this should be okay.  There should also
    " be no confusion regarding the separators because we dictate '/' in the
    " prompt.
    let l:hostname_subst = split(l:regex_input, '/')
    " Check for correct number of arguments
    if len(l:hostname_subst) == 0
        " clear prompt
        " redraw!
        normal :<ESC>
        return 0
    endif
    if len(l:hostname_subst) < 2 || len(l:hostname_subst) > 3
        echon '\n'
        echohl LogbuchError
        echom "ERROR: Invalid regular expression."
        echohl None
        return 1
    endif
    " substitute() flag in case it was given
    let l:subst_flag = ''
    if len(l:hostname_subst) == 3
        let l:subst_flag = l:hostname_subst[2]
    endif
    let l:new_host = substitute(l:netrw_host, l:hostname_subst[0],
                \ l:hostname_subst[1], subst_flag)
    execute input("", ":edit " . l:new_host . "//etc/logbuch.txt")
endfunction

function! s:NetrwCheckModified(record_new)
    " Fetch modification time of remote file via SSH and compare it to
    " a previous timestamp if possible.

    " Unless the option is explicitly enabled, don't do anything.  After some
    " testing, this default behavior can hopefully be reversed.
    if exists("g:logbuch_cfg_careful_scp")
        " if disabled by user
        if g:logbuch_cfg_careful_scp != 1
            return 0
        endif
    else
        return 0
    endif

    if expand("%") =~ "^scp:\/\/"
        let l:buff  = expand("%")
        let l:conninfo = s:NetrwGetInfo(l:buff)
        let l:hostname = l:conninfo[1]
        let l:path     = l:conninfo[2]

        " modified time via SSH
        let l:sshcmd = "stat -c '%Y' " . l:path
        let l:m = s:NetrwSSHCmd(l:hostname, l:sshcmd)
        if a:record_new == 0 && has_key(g:logbuch_mod_times, l:buff)
            " Compare
            if l:m != g:logbuch_mod_times[l:buff]
                return 1
            endif
        endif
        " Add/update timestamp
        " echom "updating timestamp: " l:buff . l:m
        let g:logbuch_mod_times[l:buff] = l:m
        return 0
    else
        " This has only been implemented for scp
        return 0
    endif
endfunction

function! s:NetrwCheckRemoteSwap()
    " Check via SSH if a Vim swap file is present at the remote, i.e.,
    " .<filename>.swp.  This would indicate that someone else is editing the
    " file which could lead to conflicts.  For local filesystems, Vim does
    " this natively.

    " Unless the option is explicitly enabled, don't do anything.  After some
    " testing, this default behavior can hopefully be reversed.
    if exists("g:logbuch_cfg_careful_scp")
        " if disabled by user
        if g:logbuch_cfg_careful_scp != 1
            return 0
        endif
    else
        return 0
    endif

    if expand("%") =~ "^scp:\/\/"
        let l:buff  = expand("%")
        let l:conninfo = s:NetrwGetInfo(l:buff)
        let l:hostname = l:conninfo[1]
        let l:path     = l:conninfo[2]

        " split path to insert period before filename
        let l:path_list = split(l:path, '/\zs')
        let l:swap_file = join(l:path_list[0:-2] +
                    \ ["." . l:path_list[-1] . ".swp"], "")
        let l:sshcmd = "test -f " . l:swap_file .
                    \" && stat --printf '%y' " . l:swap_file
        let l:m = s:NetrwSSHCmd(l:hostname, l:sshcmd)
        if l:m != ""
            " Use built-in Error instead of LogbuchError because the latter is
            " not defined soon enough.  At least, currently this function is
            " called once at the very beginning.
            echohl Error
            echom "ATTENTION: Found a swap file dated " . l:m . "!"
            echohl None
            return 1
        endif
    endif
endfunction

" BufWriteCmd idea
function! s:NetrwCarefulWrite(path)
    " This function replaces the regular BufWriteCmd for SCP remote files.  It
    " attempts to implement a file time modification check for remote files
    " like Vim already uses for local files.
    "
    " The check involves querying the remote via SSH before and after a write
    " to get the exact timestamp of the remote filesystem.  This could
    " probably be made a little more efficient by skipping the record-on-write
    " step.  Instead, the local systems times could be used and the check for
    " conflicting changes could be made a little fuzzier.  For now, the both
    " simpler and safer method seems preferable.
    let l:check = <SID>NetrwCheckModified(0)
    if l:check == 1
        " TODO: Copy wording of original Vim warning
        echohl LogbuchError
        echom "ERROR: Remote file appears to have changed!  Overwrite? [y/N] "
        echohl None
        let l:response = nr2char(getchar())
        if l:response !=? "y"
          echohl LogbuchError
          echom "File not saved!"
          echohl None
          return 1
        endif
    endif

    " There is no need to handle BufWritePre and Post because Nwrite takes
    " care of that.
    execute 'Nwrite ' . a:path
    " Record new modification time
    call <SID>NetrwCheckModified(1)
endfunction

function! s:NetrwRefreshTimestampOnEdit()
    " This function is a workaround for the CarefulWrite conecpt.
    " CarefulWrite can automatically check the remote file's modification time
    " by highjacking Netrw's BufWrite autocommand.
    " I can't get it to work for :edit/BufRead, however.
    "
    " For now, we'll have to make do with a separate command from :edit that
    " does nothing but record the new timestamp and then run :edit.
    if &modified
        " Print the same error as the :edit command in this situation
        echohl LogbuchError
        echom "E37: No write since last change (add ! to override)"
        echohl None
        return 1
    else
        execute "edit"
        call <SID>NetrwCheckModified(1)
    endif
endfunction
" 2}}}

" {{{2 Screen
function! s:SetUpScreenExchange()
    " Prepare the screen-exchange file and define screen bindings
    let l:termcap=system('env | grep TERMCAP')
    " Check if running in Screen session
    if l:termcap !~? "screen"
        echohl LogbuchError
        echom "ERROR: No Screen session detected."
        echohl None
        return 1
    endif

    " Set 'hidden' to allow automatic switching to the temporary file.
    if &hidden == 0
        setlocal hidden
    endif

    call system('screen -X bind ^e eval "readbuf '
                \ . s:screen_exchange . '" "paste ."')
    " XXX: use shellescape
    call system('screen -X bind e eval "screen -t LogbuchExchange-preview" '
                \ . '"stuff ''more '
                \ . s:screen_exchange
                \ . ' # Contents of ' .  s:screen_exchange
                \ . '\n''"')
    let g:logbuch_exchange_setup = 1
endfunction

function! s:WriteToScreenExchangeFile()
    " Write selected logbuch text to screen exchange file.  This file can be
    " read into screen's paste buffer (readbuf, C-a<).

    " Set exchange file access rights
    call system('touch ' . shellescape(s:screen_exchange)
                \ . ' && chmod 660 ' . shellescape(s:screen_exchange))

    call <SID>ModifyVisualSelection()
    let l:old_register = @l
    " yank selection to register l
    silent execute 'normal! "ly'
    silent execute "edit" . s:screen_exchange .
          \ "| setlocal nofixeol " .
          \ "| %d | 0put l | $d | w | bd" . s:screen_exchange

    " (Maybe) insert TODO marker
    if exists("g:logbuch_cfg_template_marker")
        " if not disabled by user
        if g:logbuch_cfg_template_marker != 0
            call <SID>ManageMarker(line("'>"), 1, 1)
        endif
    else
        " if no preference configured
        call <SID>ManageMarker(line("'>"), 1, 1)
    endif

    " Echo copied text
    echohl LogbuchInfo
    echo "Copied to exchange file:"
    echohl None
    echo @l

    " restore register l
    let @l = l:old_register

    " Check if SetUpScreenExchange() has run before
    if !exists("g:logbuch_exchange_setup")
        echohl LogbuchWarning
        echo "Hint: Screen may not be set up for pasting; run :LogbuchExchange?"
        echohl None
        " Mark this warning as seen, so it won't be displayed again.
        "
        " This variable was originally meant to signify if :LogbuchExchange
        " was run; however since that was always optional, this warning would
        " have probably gotten annoying.
        "
        " To restore the more nagging behavior, remove this variable
        " assignment.
        let g:logbuch_exchange_setup = 1
    endif
endfunction
" 2}}}

" {{{2 Tmux
function! s:TmuxSetPasteBuffer()
    " Load selected logbuch text into a tmux paste buffer.

    let l:tmpfile = tempname()
    let l:buffer_name = 'vim-logbuch'

    call <SID>ModifyVisualSelection()
    let l:old_register = @l
    " yank selection to register l
    silent execute 'normal! "ly'
    silent execute "edit" . l:tmpfile .
          \ "| setlocal noeol nofixeol " .
          \ "| %d | 0put l | $d | w | bd" . l:tmpfile
    call system('tmux load-buffer -b ' . buffer_name . ' ' . l:tmpfile)

    " (Maybe) insert TODO marker
    if exists("g:logbuch_cfg_template_marker")
        " if not disabled by user
        if g:logbuch_cfg_template_marker != 0
            call <SID>ManageMarker(line("'>"), 1, 1)
        endif
    else
        " if no preference configured
        call <SID>ManageMarker(line("'>"), 1, 1)
    endif

    " Echo copied text
    echohl LogbuchInfo
    echo 'Copied to tmux buffer ' . buffer_name . ':'
    echohl None
    echo @l

    " restore register l
    let @l = l:old_register

endfunction
" 2}}}
"
" 1}}}

" Record initial modification time
" Ideally, this wouldn't need to be here but instead be called from something
" like a BufRead autocommand.  That doesn't work yet, however.
call <SID>NetrwCheckModified(0)
call <SID>NetrwCheckRemoteSwap()

" {{{ Autocommands
" XXX: overrides default netrw autocommand
autocmd! Network BufWriteCmd scp://* call <SID>NetrwCarefulWrite(expand("<afile>:p"))
" XXX: There is no BufRead equivalent (yet?); instead, there is
" NetrwRefreshTimestampOnEdit()
" }}}

" vim: fdm=marker et sw=4 ts=4
