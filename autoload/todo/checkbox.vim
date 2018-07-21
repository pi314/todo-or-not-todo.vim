let s:true = v:true
let s:false = v:false

let s:todo_curr_pattern = ''
let s:todo_patterns = []
let s:todo_checkboxes = {}
let s:todo_checkboxes_default = [
    \ [
        \ ['[ ]', 'white', 'Todo'],
        \ ['[i]', 'yellow', 'Working'],
        \ ['[v]', 'green', 'Done'],
        \ ['[x]', 'red', 'Not todo'],
    \ ],
    \ [
        \ ['[!]', 'red', 'Important'],
    \ ]
\ ]
let b:todo_checkbox_cache_cycle = []
let b:todo_checkbox_cache_nocycle = []


function! todo#checkbox#file (pattern)
    let s:todo_curr_pattern = a:pattern
endfunction


function! todo#checkbox#cycle (checkbox, color, ...)
    if a:0 == 0 || type(a:1) != type('')
        let l:desc = ''
    else
        let l:desc = a:1
    endif
    call s:todo_checkbox_add(a:checkbox, a:color, l:desc, 0)
endfunction


function! todo#checkbox#nocycle (checkbox, color, ...)
    if a:0 == 0 || type(a:1) != type('')
        let l:desc = ''
    else
        let l:desc = a:1
    endif
    call s:todo_checkbox_add(a:checkbox, a:color, l:desc, 1)
endfunction


function! s:todo_checkbox_add (checkbox, color, desc, idx)
    if a:checkbox == ''
        return
    endif

    if index(s:todo_patterns, s:todo_curr_pattern) == -1
        call add(s:todo_patterns, s:todo_curr_pattern)
        let s:todo_checkboxes[(s:todo_curr_pattern)] = [[], []]
    endif

    call add(s:todo_checkboxes[(s:todo_curr_pattern)][(a:idx)], [a:checkbox, a:color, a:desc])
endfunction


function! todo#checkbox#_cycle ()
    if !exists('b:todo_checkbox_freeze') || b:todo_checkbox_freeze == s:false
        call s:freeze()
    endif
    return b:todo_checkbox_cache_cycle
endfunction


function! todo#checkbox#_nocycle ()
    if !exists('b:todo_checkbox_freeze') || b:todo_checkbox_freeze == s:false
        call s:freeze()
    endif
    return b:todo_checkbox_cache_nocycle
endfunction


function! todo#checkbox#_all ()
    if !exists('b:todo_checkbox_freeze') || b:todo_checkbox_freeze == s:false
        call s:freeze()
    endif
    return b:todo_checkbox_cache_cycle + b:todo_checkbox_cache_nocycle
endfunction


function! s:freeze ()
    let b:todo_checkbox_cache_cycle = []
    let b:todo_checkbox_cache_nocycle = []

    let l:enable_default = s:true
    for l:ptn in s:todo_patterns
        if match(@%, l:ptn) != -1
            let l:enable_default = s:false
            for l:item in s:todo_checkboxes[l:ptn][0]
                call add(b:todo_checkbox_cache_cycle, l:item)
            endfor
            for l:item in s:todo_checkboxes[l:ptn][1]
                call add(b:todo_checkbox_cache_nocycle, l:item)
            endfor
            break
        endif
    endfor

    if l:enable_default == s:true
        let b:todo_checkbox_cache_cycle = s:todo_checkboxes_default[0]
        let b:todo_checkbox_cache_nocycle = s:todo_checkboxes_default[1]
    endif
    let b:todo_checkbox_freeze = s:true
endfunction
