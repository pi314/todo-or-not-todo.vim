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
            let l:text_tmp = l:tlc[(l:pattern_len):]
            let l:ret['bspace'] = matchstr(l:text_tmp, '^ *')
            let l:ret['text'] = s:trim_left(l:text_tmp)
            return l:ret
        endif
    endfor

    for b in g:todo_bullets
        let l:pattern_len = strlen(l:c)
        if s:startswith(l:tlc, l:b)
            " got a bullet
            let l:ret['bullet'] = l:b
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

function! s:set_checkbox (pspace, checkbox, text) " {{{
    " <pspace> <checkbox> <text>
    " <pspace> <checkbox> <bspace> <ttext>
    let l:cb_len = strdisplaywidth(a:checkbox)
    let l:ttext  = s:trim_left(a:text)
    let l:bspace = repeat(' ', &softtabstop - (l:cb_len % &softtabstop))
    call setline('.', a:pspace . a:checkbox . l:bspace . l:ttext)
endfunction " }}}

function! todo#create_checkbox (...) " {{{
    let l:uacb = (a:0 == 1) && (index(g:todo_checkboxes, a:1) >= 0)
    let l:checkbox = (l:uacb) ? (a:1) : (g:todo_checkboxes[0])
    let l:plc = s:parse_line(getline('.'))
    call s:set_checkbox(l:plc['pspace'], l:checkbox, l:plc['text'])
    let l:nclc = getline('.')
    call cursor(line('.'), col('.') + strlen(l:nclc) - strlen(l:plc['origin']))
endfunction "}}}

function! todo#switch_checkbox (...) " {{{
    " check if we need to use user assigned check box
    let l:uacb = (a:0 == 1) && (index(g:todo_checkboxes, a:1) >= 0)

    let l:plc = s:parse_line(getline('.'))
    if has_key(l:plc, 'checkbox')
        " found a checkbox, switch it to next checkbox
        let l:checkbox = (l:uacb) ? (a:1) : (s:get_next_checkbox(l:plc['checkbox']))
        call s:set_checkbox(l:plc['pspace'], l:checkbox, l:plc['text'])
        return
    endif

    if l:uacb
        call todo#create_checkbox(a:1)
    else
        call todo#create_checkbox()
    endif
endfunction " }}}

function! todo#increase_indent () " {{{
    let l:clc = getline('.')
    let l:pspace_len = strlen(matchstr(l:clc, '^ *'))
    let l:prepend_len = l:pspace_len % shiftwidth()
    let l:prepend_len = shiftwidth() - ((l:prepend_len == 0) ? 0 : (l:prepend_len))
    call setline('.', repeat(' ', l:prepend_len) . l:clc)
    call cursor(line('.'), col('.') + &shiftwidth)
endfunction " }}}

function! todo#decrease_indent () " {{{
    let l:clc = getline('.')
    let l:pspace_len = strlen(matchstr(l:clc, '^ *'))
    if l:pspace_len == 0
        return
    endif
    let l:trim_len = (l:pspace_len % shiftwidth())
    if l:trim_len == 0
        let l:trim_len = shiftwidth()
    endif
    call cursor(line('.'), col('.') - &shiftwidth)
    call setline('.', l:clc[(l:trim_len):])
endfunction " }}}

function! todo#create_bullet () " {{{
    let l:clc = getline('.')
    let l:pspace = matchstr(l:clc, '^ *')
    if strlen(l:pspace) == 0
        let l:pspace = matchstr(getline(line('.') - 1), '^ *')
    endif
    let l:bspace = repeat(' ', &softtabstop - strdisplaywidth(g:todo_bullets[0]))
    call setline('.', l:pspace . g:todo_bullets[0] . l:bspace . s:trim_left(l:clc))
    call cursor(line('.'), col('.') + strdisplaywidth(g:todo_bullets[0] . l:bspace))
endfunction " }}}

function! todo#open_new_line () " {{{
    let l:row = line('.')
    let l:col = col('.')
    call append(l:row, '')
    let l:row = l:row + 1
    call cursor(l:row, l:col)
    call todo#create_bullet()
endfunction " }}}

let s:kinds_of_checkbox = -2