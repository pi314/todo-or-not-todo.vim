let s:true = v:true
let s:false = v:false

let s:todo_curr_pattern = ''
let s:todo_patterns = ['']
let s:todo_checkboxes = {
            \ '': [
                \ [
                    \ ['[ ]', 'white', 'todo'],
                    \ ['[i]', 'yellow', 'working'],
                    \ ['[v]', 'green', 'done'],
                    \ ['[x]', 'red', 'not todo'],
                \ ],
                \ [
                    \ ['[!]', 'red', 'important'],
                \ ]
            \ ]
        \ }
let s:todo_checkbox_freeze = s:false
let s:todo_checkbox_cache_cycle = []
let s:todo_checkbox_cache_nocycle = []


function! todo#checkbox#file (pattern)
    let s:todo_curr_pattern = a:pattern
    if index(s:todo_patterns, s:todo_curr_pattern) == -1
        call add(s:todo_patterns, s:todo_curr_pattern)
        let s:todo_checkboxes[(s:todo_curr_pattern)] = [[], []]
    endif
    let s:todo_checkbox_freeze = s:false
endfunction


function! todo#checkbox#cycle (checkbox, color, ...)
    if a:checkbox == ''
        return
    endif

    if a:0 == 0
        let l:description = ''
    elseif a:0 == 1
        let l:description = a:1
    endif

    call add(s:todo_checkboxes[(s:todo_curr_pattern)][0], [a:checkbox, a:color, l:description])
    let s:todo_checkbox_freeze = s:false
endfunction


function! todo#checkbox#_cycle ()
    if s:todo_checkbox_freeze == s:false
        call s:freeze()
        let s:todo_checkbox_freeze = s:true
    endif
    return s:todo_checkbox_cache_cycle
endfunction


function! todo#checkbox#_nocycle ()
    if s:todo_checkbox_freeze == s:false
        call s:freeze()
        let s:todo_checkbox_freeze = s:true
    endif
    return s:todo_checkbox_cache_nocycle
endfunction


function! todo#checkbox#_all ()
    if s:todo_checkbox_freeze == s:false
        call s:freeze()
        let s:todo_checkbox_freeze = s:true
    endif
    return s:todo_checkbox_cache_cycle + s:todo_checkbox_cache_nocycle
endfunction


function! s:freeze ()
    let s:todo_checkbox_cache_cycle = []
    let s:todo_checkbox_cache_nocycle = []

    let l:enable_default = 1
    for l:ptn in s:todo_patterns
        if l:ptn == ''
            continue
        endif

        if matchstr(@%, l:ptn) ==# @%
            let l:enable_default = 0
            for l:item in s:todo_checkboxes[l:ptn][0]
                call add(s:todo_checkbox_cache_cycle, l:item)
            endfor
            for l:item in s:todo_checkboxes[l:ptn][1]
                call add(s:todo_checkbox_cache_nocycle, l:item)
            endfor
        endif
    endfor

    if l:enable_default
        let s:todo_checkbox_cache_cycle = s:todo_checkboxes[''][0]
        let s:todo_checkbox_cache_nocycle = s:todo_checkboxes[''][1]
    endif
endfunction
