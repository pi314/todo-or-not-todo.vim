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

    for c in g:todo_checkboxes
        let l:pattern_len = strlen(l:c)
        if s:startswith(l:tlc, l:c)
            " got a checkbox
            let l:ret['checkbox'] = l:c
            let l:ret['type'] = 'checkbox'
            let l:text_tmp = l:tlc[(l:pattern_len):]
            let l:ret['bspace'] = matchstr(l:text_tmp, '^ *')
            let l:ret['text'] = s:trim_left(l:text_tmp)
            return l:ret
        endif
    endfor

    for b in g:todo_bullets
        let l:pattern_len = strlen(l:b)
        if s:startswith(l:tlc, l:b)
            " got a bullet
            let l:ret['checkbox'] = l:b
            let l:ret['type'] = 'bullet'
            let l:text_tmp = l:tlc[(l:pattern_len):]
            let l:ret['bspace'] = matchstr(l:text_tmp, '^ *')
            let l:ret['text'] = s:trim_left(l:text_tmp)
            return l:ret
        endif
    endfor

    let l:ret['text'] = l:tlc
    return l:ret
endfunction " }}}

function! s:get_kinds_of_checkbox () " {{{
    if s:kinds_of_checkbox == -2
        let s:kinds_of_checkbox = index(g:todo_checkboxes, '')
        if s:kinds_of_checkbox == -1
            let s:kinds_of_checkbox = len(g:todo_checkboxes)
        endif
    endif
    return s:kinds_of_checkbox
endfunction " }}}

function! s:get_next_checkbox (c) " {{{
    let l:l = s:get_kinds_of_checkbox()
    let l:i = index(g:todo_checkboxes, a:c)
    if l:i == -1 || l:i >= l:l
        return g:todo_checkboxes[0]
    endif
    return g:todo_checkboxes[(l:i + 1) % (l:l)]
endfunction " }}}

function! todo#set_bullet () " {{{
    let l:plc = s:parse_line(getline('.'))
    let l:pspace = l:plc['pspace']
    if strlen(l:pspace) == 0 && line('.') > 1
        let l:pspace = s:parse_line(getline(line('.') - 1))['pspace']
    endif
    let l:bspace = repeat(' ', &softtabstop - (strlen(l:plc['pspace'] . g:todo_bullets[0]) % &softtabstop))
    call setline('.', l:pspace . g:todo_bullets[0] . l:bspace . l:plc['text'])

    let l:col = col('.')
    if l:col >= strlen(l:plc['origin']) - strlen(l:plc['text']) + 1
        let l:nclc = getline('.')
        call cursor(line('.'), l:col + strlen(l:nclc) - strlen(l:plc['origin']))
    endif
endfunction " }}}

function! todo#set_checkbox (...) " {{{
    let l:plc = s:parse_line(getline('.'))
    if (a:0 == 1) && (index(g:todo_checkboxes, a:1) >= 0)
        " use user assigned check box
        let l:checkbox = (a:1)
    elseif has_key(l:plc, 'checkbox') && l:plc['type'] == 'checkbox'
        " use original checkbox
        let l:checkbox = l:plc['checkbox']
    else
        " set a new checkbox
        let l:checkbox = g:todo_checkboxes[0]
    endif

    let l:bspace = repeat(' ', &softtabstop - (strlen(l:plc['pspace'] . l:checkbox) % &softtabstop))
    call setline('.', l:plc['pspace'] . l:checkbox . l:bspace . l:plc['text'])

    let l:col = col('.')
    if l:col >= strlen(l:plc['origin']) - strlen(l:plc['text']) + 1
        let l:nclc = getline('.')
        call cursor(line('.'), l:col + strlen(l:nclc) - strlen(l:plc['origin']))
    endif
endfunction "}}}

function! todo#switch_checkbox (...) " {{{
    " check if we need to use user assigned check box
    let l:uacb = (a:0 == 1) && (index(g:todo_checkboxes, a:1) >= 0)

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
    call append(l:row, '')
    let l:row = l:row + 1
    call cursor(l:row, l:col)
    call todo#set_bullet()
endfunction " }}}

function! todo#join_two_lines ()
    let l:nln = line('.') + 1
    if l:nln <= line('$')
        let l:plc = s:parse_line(getline(l:nln))
        call setline(l:nln, l:plc['text'])
        normal! J
    endif
endfunction

function! todo#move_cursor_to_line_start ()
    let l:plc = s:parse_line(getline('.'))
    let l:logic_line_start = strlen(l:plc['origin']) - strlen(l:plc['text']) + 1
    if col('.') == l:logic_line_start
        call cursor(line('.'), strlen(l:plc['pspace']) + 1)
    else
        call cursor(line('.'), l:logic_line_start)
    endif
endfunction

let s:kinds_of_checkbox = -2
