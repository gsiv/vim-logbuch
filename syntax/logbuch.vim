scriptencoding utf-8

" TODO:
" - folding gets confused with asterisks in body text

if exists('b:current_syntax') | finish |  endif

syntax clear
syntax sync fromstart

setlocal foldmethod=syntax
" Treat asterisks as regular list bullets, not multi-line comment prefixes
setlocal comments-=mb:*
setlocal comments+=fb:*
if v:version > 703
    setlocal conceallevel=2
endif

" Styling {{{
hi def link   logbuchDate              Title
hi def link   logbuchPreambleItem      PreProc
hi def link   logbuchPreambleSection   Todo
hi def link   logbuchTitleHostname     ErrorMsg
hi def link   logbuchTitleIP           Number
hi def link   logbuchItemBullet        String
hi def link   logbuchItemCmd           Statement
hi def link   logbuchItemComment       Function
hi def link   logbuchItemBody          Comment
hi def link   logbuchItemFile          Underlined
hi def link   logbuchItemMarker        CursorLineNr

" Formatting for script messages
highlight default link LogbuchWarning WarningMsg
highlight default link LogbuchError ErrorMsg
" }}}

" Preamble {{{
syntax region logbuchPreamble start=/^Logbuch\ \(fuer\|mit\)/
            \ end=/^[0-9]\{2}\.[0-9]\{2}\.[0-9]\{4}\t/me=s-1 transparent
            \ contains=logbuchTitleHostname,logbuchTitleIP,logbuchPreambleEntry
syntax match  logbuchPreambleSection /^[0-9A-Z][0-9A-Z\ ]\+:$/ contained
syntax region logbuchPreambleEntry start=/^[0-9A-Z][0-9A-Z\ ]\+:$/ end=/^[A-Z]/me=s-1
            \ end=/^$/me=s-1 transparent contained
            \ contains=logbuchPreambleSection,logbuchPreambleItem
" optional: fold:
syntax region logbuchPreambleItem start=/^\*\s/ end=/^\*\s/me=s-1
            \ end=/^$/me=s-1 contained
syntax region logbuchTitleHostname
            \ start=/^Logbuch\ fuer\ /ms=e+1
            \ start=/^Logbuch\ mit\ Änderungen\ für\ die\ virtuellen\ Instanzen\ auf\ /ms=e+1
            \ end=/\.$/me=s-1 end=/$/
            \ end=/\ (/me=s-1 end=/$/  contained
syntax region logbuchTitleIP start=/(/ms=e+1 end=/)/me=s-1 contained
" }}}

" Entries {{{
syntax region logbuchEntry start=/^[0-9]/ end=/^[0-9]/me=s-1 end=/^$/me=s-1
            \ fold transparent contains=logbuchDate,logbuchItem fold
syntax region logbuchItem start=/^\*\s/
            \ end=/^\*\s/me=s-1
            \ end=/^\S/me=s-1
            \ end=/[0-9]\{2}\.[0-9]\{2}\.[0-9]\{4}\t/me=s-1
            \ fold transparent contained contains=logbuchItem.\+
syntax match  logbuchItemCmd /.\+$/ contained
            \ contains=logbuchItemComment,logbuchItemFile
syntax match  logbuchItemBody /^\s\s\+.*$/ contained
            \ contains=logbuchItemComment,logbuchItemFile
syntax match  logbuchItemComment /#\s.*$/ contained
" TODO: improve:
syntax match  logbuchItemFile /[~\/\.]\+.\+:$/ contained
syntax match  logbuchItemMarker
            \ /^\*\sv\sv\sv\sv\sv\sv\sv\sv\sv\sv\sTODO\sv\sv\sv\sv\sv\sv\sv\sv\sv\sv$/
            \ contained

" date and author
syntax match logbuchDate /^[0-9]\{2}\.[0-9]\{2}\.[0-9]\{4}\t/
            \ nextgroup=logbuchAuthor contained
" conceal author name
syntax match logbuchAuthor /[^<]\+/ contained nextgroup=logbuchEmail
syntax match logbuchEmail /<.\+>/ conceal transparent cchar=@
            \ contained
" }}}

let b:current_syntax = 'logbuch'
" vim: set fdm=marker foldlevel=0 et sw=4 ts=4
