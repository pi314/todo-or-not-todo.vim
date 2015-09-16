function! todo#add#checkbox (checkbox, color, ...)
    if !exists('g:_todo_checkbox_initialized') || g:_todo_checkbox_initialized != 1
        let g:_todo_checkbox_loop = []
        let g:_todo_checkbox_total = []
        let g:_todo_checkbox_color = {}
        let g:_todo_checkbox_initialized = 1
    endif
    if index(g:_todo_checkbox_loop, a:checkbox) == -1
        if (a:0 == 0 || (a:1 == 1))
            let g:_todo_checkbox_loop = g:_todo_checkbox_loop + [a:checkbox]
        endif
        let g:_todo_checkbox_total = g:_todo_checkbox_total + [a:checkbox]
    endif
    let g:_todo_checkbox_color[a:checkbox] = a:color
endfunction
