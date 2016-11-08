function! todo#checkbox#add (checkbox, color, ...)
    if !exists('b:todo_checkbox_all')
        call todo#checkbox#clear()
        call todo#checkbox#init()
    endif
    if a:0 == 0
        let l:description = ''
        let l:loop = 1
    elseif a:0 == 1 && a:1 == 'noloop'
        let l:description = ''
        let l:loop = 0
    elseif a:0 == 1 && a:1 !=# 'noloop'
        let l:description = a:1
        let l:loop = 1
    elseif a:0 >= 2 && a:1 ==# 'noloop'
        let l:description = a:2
        let l:loop = 0
    elseif a:0 >= 2 && a:1 ==# ''
        let l:description = a:2
        let l:loop = 1
    elseif a:0 >= 2 && a:1 !=# 'noloop'
        let l:description = a:1
        let l:loop = 1
    endif

    if !has_key(b:todo_checkbox_color, a:checkbox)
        if l:loop
            call add(b:todo_checkbox_loop, a:checkbox)
        endif
        call add(b:todo_checkbox_all, a:checkbox)
    endif
    let b:todo_checkbox_color[a:checkbox] = a:color
    let b:todo_checkbox_desc[a:checkbox] = l:description
endfunction

function! todo#checkbox#clear ()
    let b:todo_checkbox_loop = []
    let b:todo_checkbox_all = []
    let b:todo_checkbox_color = {}
    let b:todo_checkbox_desc = {}
endfunction

function! todo#checkbox#init ()
    call todo#checkbox#add('[ ]', 'White', 'Todo')
    call todo#checkbox#add('[v]', 'Green', 'Done')
    call todo#checkbox#add('[x]', 'Red', 'Not todo')
    call todo#checkbox#add('[i]', 'Yellow', 'noloop', 'Doing')
    call todo#checkbox#add('[?]', 'Yellow', 'noloop', 'Not sure')
    call todo#checkbox#add('[!]', 'Red', 'noloop', 'Important')
endfunction
