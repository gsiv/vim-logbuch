" ftdetect/logbuch.vim: filetype loader
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

autocmd BufNewFile,BufRead */logbuch.txt set filetype=logbuch
autocmd BufNewFile,BufRead */etc/logbuch.txt echo "logbuch.vim loaded.  "
      \ . "Type ':help logbuch' for more information."
