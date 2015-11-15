function! todo#add#checkbox (checkbox, color, ...)
    if !exists('b:todo_checkbox_initialized') || b:todo_checkbox_initialized != 1
        let b:todo_checkbox_loop = []
        let b:todo_checkbox_total = []
        let b:todo_checkbox_color = {}
        let b:todo_checkbox_initialized = 1
    endif
    if index(b:todo_checkbox_loop, a:checkbox) == -1
        if (a:0 == 0 || (a:1 == 1))
            let b:todo_checkbox_loop = b:todo_checkbox_loop + [a:checkbox]
        endif
        let b:todo_checkbox_total = b:todo_checkbox_total + [a:checkbox]
    endif
    let b:todo_checkbox_color[a:checkbox] = a:color
endfunction
