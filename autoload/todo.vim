" --------- "
" functions "
" --------- "

let s:RESET = 0
let s:NORMAL_MODE = 1
let s:INSERT_MODE = 2
let s:state_before_menu_complete = s:RESET

function! s:trim_left (text) " {{{
    return substitute(a:text, '^\s*', '', '')
endfunction " }}}

function! s:startswith (text, pattern) " {{{
    return a:text[:(strlen(a:pattern) - 1)] ==# a:pattern
endfunction " }}}

function! s:endswith (text, pattern) " {{{
    let l:index = strlen(a:text) - strlen(a:pattern)
    return a:text[(l:index):] ==# a:pattern
endfunction " }}}

function! s:parse_line (row) " {{{
    " patterns:
    " <pspace> <checkbox> <bspace> <text>
    " <pspace> <bullet> <bspace> <text>
    " <pspace> <text>

    let l:ret = {}
    if type(a:row) == type(0)
        let l:ret['row'] = a:row
    else
        let l:ret['row'] = line(a:row)
    endif
    let l:ret['text'] = ''
    let l:ret['origin'] = getline(a:row)
    let l:ret['pspace'] = matchstr(l:ret['origin'], '^ *')
    let l:tlc = s:trim_left(l:ret['origin'])

    for c in b:todo_checkbox_total
        if s:startswith(l:tlc, l:c)
            " got a checkbox
            let l:pattern_len = strlen(l:c)
            let l:ret['checkbox'] = l:c
            let l:ret['type'] = 'checkbox'
            let l:text_tmp = l:tlc[(l:pattern_len):]
            let l:ret['bspace'] = matchstr(l:text_tmp, '^ *')
            let l:ret['text'] = s:trim_left(l:text_tmp)
            return l:ret
        endif
    endfor

    if s:startswith(l:tlc, g:todo_bullet)
        " got a bullet
        let l:pattern_len = strlen(g:todo_bullet)
        let l:ret['checkbox'] = g:todo_bullet
        let l:ret['type'] = 'bullet'
        let l:text_tmp = l:tlc[(l:pattern_len):]
        let l:ret['bspace'] = matchstr(l:text_tmp, '^ *')
        let l:ret['text'] = s:trim_left(l:text_tmp)
        return l:ret
    endif

    let l:ret['text'] = l:tlc
    return l:ret
endfunction " }}}

function! s:write_line (plc) " {{{
    if has_key(a:plc, 'checkbox')
        let l:new_line = a:plc['pspace'] . a:plc['checkbox'] . a:plc['bspace'] . a:plc['text']
    else
        let l:new_line = a:plc['pspace'] . a:plc['text']
    endif
    if l:new_line == a:plc['origin']
        return
    endif

    let l:col = col('.')
    call setline(a:plc['row'], l:new_line)

    if a:plc['row'] == line('.')
        if l:col == 0
            return
        endif
        let l:old_line_right = a:plc['origin'][(l:col - 1):]
        if s:endswith(l:new_line, l:old_line_right)
            " cursor right not changed
            call cursor(line('.'), l:col + strlen(l:new_line) - strlen(a:plc['origin']))
        endif
    endif
endfunction " }}}

function! s:vwidth (s) " {{{
    return strdisplaywidth(a:s)
endfunction " }}}

function! s:get_bspace (checkbox) " {{{
    return repeat(' ', &softtabstop - (s:vwidth(a:checkbox) % &softtabstop))
endfunction " }}}

function! s:get_next_checkbox (c) " {{{
    let l:l = len(b:todo_checkbox_loop)
    let l:i = index(b:todo_checkbox_total, a:c)
    if l:i == -1 || l:i >= l:l
        return b:todo_checkbox_loop[0]
    endif
    return b:todo_checkbox_loop[(l:i + 1) % (l:l)]
endfunction " }}}

function! s:valid_checkbox (c) " {{{
    return index(b:todo_checkbox_total, a:c) >= 0
endfunction " }}}

function! s:first_char_of (str) " {{{
    return nr2char(char2nr(a:str))
endfunction " }}}

function! s:set_bullet (plc) " {{{
    let l:pspace = a:plc['pspace']
    if strlen(l:pspace) == 0 && line('.') > 1 && !has_key(a:plc, 'checkbox')
        let l:pspace = s:parse_line(line('.') - 1)['pspace']
    endif
    let a:plc['pspace'] = l:pspace
    let a:plc['checkbox'] = g:todo_bullet
    let a:plc['bspace'] = s:get_bspace(g:todo_bullet)
    call s:write_line(a:plc)
endfunction " }}}

function! todo#set_bullet () " {{{
    call s:set_bullet(s:parse_line('.'))
endfunction " }}}

function! s:set_checkbox (plc, ...) " {{{
    if (a:0 == 1) && s:valid_checkbox(a:1)
        " use user assigned check box
        let l:checkbox = (a:1)
    elseif has_key(a:plc, 'checkbox') && a:plc['type'] == 'checkbox'
        " use original checkbox
        let l:checkbox = a:plc['checkbox']
    else
        " set a new checkbox
        let l:checkbox = b:todo_checkbox_loop[0]
    endif

    let l:bspace = s:get_bspace(l:checkbox)
    let a:plc['checkbox'] = l:checkbox
    let a:plc['bspace'] = l:bspace
    call s:write_line(a:plc)
endfunction "}}}

function! todo#switch_checkbox (...) " {{{
    " check if we need to use user assigned check box
    let l:uacb = (a:0 == 1) && s:valid_checkbox(a:1)

    let l:plc = s:parse_line('.')
    if has_key(l:plc, 'bspace') && l:plc['type'] == 'checkbox'
        " found a checkbox, switch it to next checkbox
        let l:checkbox = (l:uacb) ? (a:1) : (s:get_next_checkbox(l:plc['checkbox']))
        call s:set_checkbox(l:plc, l:checkbox)
        return
    endif

    if l:uacb
        call s:set_checkbox(l:plc, a:1)
    else
        call s:set_checkbox(l:plc)
    endif
endfunction " }}}

function! todo#increase_indent () " {{{
    let l:plc = s:parse_line('.')
    let l:sw = shiftwidth()
    let l:prepend_len = l:sw - (strlen(l:plc['pspace']) % l:sw)
    let l:plc['pspace'] .= repeat(' ', l:prepend_len)
    if has_key(l:plc, 'checkbox')
        if l:plc['type'] == 'checkbox'
            call s:set_checkbox(l:plc)
        else
            call s:set_bullet(l:plc)
        endif
    endif
endfunction " }}}

function! todo#decrease_indent () " {{{
    let l:plc = s:parse_line('.')
    let l:sw = shiftwidth()
    let l:col = col('.')

    let l:pspace_len = strlen(l:plc['pspace'])
    if l:pspace_len == 0
        return
    endif

    let l:trim_len = (l:pspace_len % l:sw)
    if l:trim_len == 0
        let l:trim_len = l:sw
    endif

    let l:plc['pspace'] = l:plc['pspace'][(l:trim_len):]

    if has_key(l:plc, 'checkbox')
        if l:plc['type'] == 'checkbox'
            call s:set_checkbox(l:plc)
        else
            call s:set_bullet(l:plc)
        endif
    endif
endfunction " }}}

function! todo#open_new_line () " {{{
    let l:row = line('.')
    let l:col = col('.')
    let l:plc = s:parse_line('.')
    call append(l:row, '')
    let l:row = l:row + 1
    call cursor(l:row, l:col)
    if has_key(l:plc, 'bullet') || has_key(l:plc, 'checkbox')
        call todo#set_bullet()
    endif
endfunction " }}}

function! todo#join_two_lines () " {{{
    let l:nln = line('.') + 1
    if l:nln <= line('$')
        let l:plc = s:parse_line(l:nln)
        call setline(l:nln, l:plc['text'])
        normal! J
    endif
endfunction " }}}

function! todo#move_cursor_to_line_start () " {{{
    let l:plc = s:parse_line('.')
    let l:logic_line_start = strlen(l:plc['origin']) - strlen(l:plc['text']) + 1
    if col('.') == l:logic_line_start
        call cursor(line('.'), strlen(l:plc['pspace']) + 1)
    else
        call cursor(line('.'), l:logic_line_start)
    endif
endfunction " }}}

function! todo#carriage_return () " {{{
    if pumvisible()
        " say yes to completion
        return "\<C-y>"
    endif

    let l:plc = s:parse_line('.')
    if !has_key(l:plc, 'bullet') && !has_key(l:plc, 'checkbox')
        return "\<CR>"
    endif

    if col('.') == strlen(l:plc['origin']) - strlen(l:plc['text']) + 1
        call append(line('.') - 1, '')
        return ""
    endif

    return "\<CR>\<C-o>:call todo#set_bullet()\<CR>"
endfunction " }}}

function! todo#tab () " {{{
    let l:plc = s:parse_line('.')
    if !has_key(l:plc, 'checkbox')
        return "\<TAB>"
    endif

    let l:bspace_checkbox_len = strdisplaywidth(l:plc['bspace'] . l:plc['checkbox'])
    if l:bspace_checkbox_len > &softtabstop || l:bspace_checkbox_len % &softtabstop != 0
        " make up bspace
        return "\<TAB>"
    endif

    let l:logic_line_start = strlen(l:plc['origin']) - strlen(l:plc['text']) + 1
    if col('.') == l:logic_line_start
        return "\<C-o>:call todo#increase_indent()\<CR>"
    else
        return "\<TAB>"
    endif
endfunction " }}}

function! todo#shift_tab () " {{{
    let l:plc = s:parse_line('.')
    let l:logic_line_start = strlen(l:plc['origin']) - strlen(l:plc['text']) + 1
    if col('.') == l:logic_line_start
        call todo#decrease_indent()
    endif
endfunction " }}}

function! s:highlighter (row, ...) " {{{
    let l:line = getline(a:row)
    if strlen(l:line) == 0
        return
    endif

    if a:0 == 2
        """ row, col1, col2
        let l:col2 = (a:2) + strlen(s:first_char_of(l:line[(a:2-1):])) - 1
        let l:line_part1 = (a:1 <= 1) ? ('') : (l:line[:(a:1-2)])
        let l:line_part2 = (a:1 == l:col2) ? (l:line[a:1-1]) : (l:line[(a:1-1):(l:col2-1)])
        let l:line_part3 = (l:col2 >= strlen(l:line) + 1) ? ('') : (l:line[(l:col2):])
    elseif a:0 == 1
        """ row, col, _
        let l:line_part1 = (a:1 <= 1) ? ('') : (l:line[:(a:1-2)])
        let l:line_part2 = (a:1 == strlen(l:line) + 1) ? ('') : (l:line[(a:1-1):])
        let l:line_part3 = ''
    else
        """ row, _, _
        let l:line_part1 = ''
        let l:line_part2 = l:line
        let l:line_part3 = ''
    endif

    call setline(a:row,
        \l:line_part1 .
        \g:todo_highlighter_start .
        \l:line_part2 .
        \g:todo_highlighter_end .
        \l:line_part3
    \)
endfunction " }}}

function! todo#highlighter () range " {{{
    normal! gv
    let l:mode = mode()
    execute "normal! \<ESC>"
    if l:mode ==# 'v'
        let [l:row1, l:col1] = getpos("'<")[1:2]
        let [l:row2, l:col2] = getpos("'>")[1:2]
        if l:row1 == l:row2
            call s:highlighter(l:row1, l:col1, l:col2)
        else
            call s:highlighter(l:row1, l:col1)
            for l:row in range(l:row1 + 1, l:row2 - 1)
                call s:highlighter(l:row)
            endfor
            call s:highlighter(l:row2, 1, l:col2)
        endif

    elseif l:mode ==# 'V'
        for l:row in range(a:firstline, a:lastline)
            call s:highlighter(l:row)
        endfor

    elseif l:mode ==# ''
        normal! gv
        execute "normal! A". g:todo_highlighter_end
        execute "normal! gvI". g:todo_highlighter_start
        execute "normal! \<ESC>"

    endif

    call cursor(line('.'), col('.') + strlen(g:todo_highlighter_start))
endfunction " }}}

function! todo#eraser () " {{{
    call setline('.', substitute(getline('.'), '\v['. g:todo_highlighter_start . g:todo_highlighter_end .']', '', 'g'))
endfunction " }}}

function! todo#checkbox_menu () " {{{
    " check if we need to use user assigned check box
    if pumvisible()
        return "\<C-n>"
    endif

    if mode() ==# 'n'
        let s:state_before_menu_complete = s:NORMAL_MODE
        call feedkeys("i\<C-r>=todo#checkbox_menu()\<CR>")
        return ''
    endif

    if s:state_before_menu_complete == s:RESET
        let s:state_before_menu_complete = s:INSERT_MODE
    endif

    let l:plc = s:parse_line('.')
    if !has_key(l:plc, 'type') || !(l:plc['type'] == 'checkbox' || l:plc['type'] == 'bullet')
        " current line is an ordinary line
        " or it's not checkbox item nor bulleted list item
        call todo#switch_checkbox()
        let l:plc = s:parse_line('.')
    endif

    call cursor(
        \line('.'),
        \strlen(l:plc['pspace'] . l:plc['checkbox'] . l:plc['bspace']) + 1)

    let l:checkbox_str = []
    for l:checkbox in b:todo_checkbox_total + [g:todo_bullet]
        call add(l:checkbox_str, l:checkbox . s:get_bspace(l:checkbox))
    endfor
    call complete(strlen(l:plc['pspace']) + 1, l:checkbox_str)

    return ''
endfunction " }}}

function! todo#recover_insert_mode () " {{{
    if s:state_before_menu_complete == s:NORMAL_MODE
        let s:state_before_menu_complete = s:RESET
        call feedkeys("\<ESC>^", 't')
    endif
endfunction " }}}
