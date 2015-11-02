" --------- "
" functions "
" --------- "

function! s:trim_left (text) " {{{
    return substitute(a:text, '^\s*', '', '')
endfunction " }}}

function! s:startswith (text, pattern) " {{{
    return a:text[:(strlen(a:pattern) - 1)] ==# a:pattern
endfunction " }}}

function! s:parse_line (lc) " {{{
    " patterns:
    " <pspace> <checkbox> <bspace> <text>
    " <pspace> <bullet> <bspace> <text>
    " <pspace> <text>

    let l:ret = {}
    let l:ret['text'] = ''
    let l:ret['origin'] = a:lc
    let l:ret['pspace'] = matchstr(a:lc, '^ *')
    let l:tlc = s:trim_left(a:lc)

    for c in g:_todo_checkbox_total
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

function! s:get_next_checkbox (c) " {{{
    let l:l = len(g:_todo_checkbox_loop)
    let l:i = index(g:_todo_checkbox_total, a:c)
    if l:i == -1 || l:i >= l:l
        return g:_todo_checkbox_loop[0]
    endif
    return g:_todo_checkbox_loop[(l:i + 1) % (l:l)]
endfunction " }}}

function! s:valid_checkbox (c) " {{{
    return index(g:_todo_checkbox_total, a:c) >= 0
endfunction " }}}

function! todo#set_bullet () " {{{
    let l:plc = s:parse_line(getline('.'))
    let l:pspace = l:plc['pspace']
    if strlen(l:pspace) == 0 && line('.') > 1 && !has_key(l:plc, 'checkbox')
        let l:pspace = s:parse_line(getline(line('.') - 1))['pspace']
    endif
    let l:bspace = repeat(' ', &softtabstop - (strdisplaywidth(l:plc['pspace'] . g:todo_bullet) % &softtabstop))
    call setline('.', l:pspace . g:todo_bullet . l:bspace . l:plc['text'])

    let l:col = col('.')
    if l:col >= strdisplaywidth(l:plc['origin']) - strdisplaywidth(l:plc['text']) + 1
        let l:nclc = getline('.')
        call cursor(line('.'), l:col + strdisplaywidth(l:nclc) - strdisplaywidth(l:plc['origin']))
    endif
endfunction " }}}

function! todo#set_checkbox (...) " {{{
    let l:plc = s:parse_line(getline('.'))
    if (a:0 == 1) && s:valid_checkbox(a:1)
        " use user assigned check box
        let l:checkbox = (a:1)
    elseif has_key(l:plc, 'checkbox') && l:plc['type'] == 'checkbox'
        " use original checkbox
        let l:checkbox = l:plc['checkbox']
    else
        " set a new checkbox
        let l:checkbox = g:_todo_checkbox_loop[0]
    endif

    let l:bspace = repeat(' ', &softtabstop - (strdisplaywidth(l:plc['pspace'] . l:checkbox) % &softtabstop))
    call setline('.', l:plc['pspace'] . l:checkbox . l:bspace . l:plc['text'])

    let l:col = col('.')
    if l:col >= strdisplaywidth(l:plc['origin']) - strdisplaywidth(l:plc['text']) + 1
        let l:nclc = getline('.')
        call cursor(line('.'), l:col + strdisplaywidth(l:nclc) - strdisplaywidth(l:plc['origin']))
    endif
endfunction "}}}

function! todo#switch_checkbox (...) " {{{
    " check if we need to use user assigned check box
    let l:uacb = (a:0 == 1) && s:valid_checkbox(a:1)

    let l:plc = s:parse_line(getline('.'))
    if has_key(l:plc, 'bspace') && l:plc['type'] == 'checkbox'
        " found a checkbox, switch it to next checkbox
        let l:checkbox = (l:uacb) ? (a:1) : (s:get_next_checkbox(l:plc['checkbox']))
        call todo#set_checkbox(l:checkbox)
        return
    endif

    if l:uacb
        call todo#set_checkbox(a:1)
    else
        call todo#set_checkbox()
    endif
endfunction " }}}

function! todo#increase_indent () " {{{
    let l:plc = s:parse_line(getline('.'))
    let l:sw = shiftwidth()
    let l:prepend_len = l:sw - (strlen(l:plc['pspace']) % l:sw)
    call setline('.', repeat(' ', l:prepend_len) . l:plc['origin'])
    call cursor(line('.'), col('.') + l:prepend_len)
    if has_key(l:plc, 'checkbox')
        if l:plc['type'] == 'checkbox'
            call todo#set_checkbox()
        else
            call todo#set_bullet()
        endif
    endif
endfunction " }}}

function! todo#decrease_indent () " {{{
    let l:plc = s:parse_line(getline('.'))
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

    if l:col < l:trim_len + 1
        call cursor(line('.'), 1)
    else
        call cursor(line('.'), col('.') - l:trim_len)
    endif

    call setline('.', l:plc['origin'][(l:trim_len):])

    if has_key(l:plc, 'checkbox')
        if l:plc['type'] == 'checkbox'
            call todo#set_checkbox()
        else
            call todo#set_bullet()
        endif
    endif
endfunction " }}}

function! todo#open_new_line () " {{{
    let l:row = line('.')
    let l:col = col('.')
    let l:plc = s:parse_line(getline('.'))
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
        let l:plc = s:parse_line(getline(l:nln))
        call setline(l:nln, l:plc['text'])
        normal! J
    endif
endfunction " }}}

function! todo#move_cursor_to_line_start () " {{{
    let l:plc = s:parse_line(getline('.'))
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

    let l:plc = s:parse_line(getline('.'))
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
    let l:plc = s:parse_line(getline('.'))
    if !has_key(l:plc, 'checkbox')
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
    let l:plc = s:parse_line(getline('.'))
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
        let l:line_part1 = (a:1 <= 1) ? ('') : (l:line[:(a:1-2)])
        let l:line_part2 = (a:1 == a:2) ? (l:line[a:1-1]) : (l:line[(a:1-1):(a:2-1)])
        let l:line_part3 = (a:2 >= strlen(l:line) + 1) ? ('') : (l:line[(a:2):])
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
        let [l:row1, l:col1] = getpos("'<")[1:2]
        let [l:row2, l:col2] = getpos("'>")[1:2]
        let l:min_col = min([l:col1, l:col2])
        let l:max_col = max([l:col1, l:col2])
        for l:row in range(l:row1, l:row2)
            call s:highlighter(l:row, l:min_col, l:max_col)
        endfor

    endif

    call cursor(line('.'), col('.') + strlen(g:todo_highlighter_start))
endfunction " }}}
