if &softtabstop == 0
    " user not setting &softtabstop, set it to 4
    setlocal softtabstop=4
endif

if shiftwidth() == 8
    " user not setting &shiftwidth, set it to 4
    setlocal shiftwidth=4
endif

function! todo#SetCheckbox (pspace, checkbox, text)
    " <pspace> <checkbox> <bspace> <text>
    let l:cb_len = strdisplaywidth(a:checkbox)
    let l:bspace = &softtabstop - (l:cb_len % &softtabstop)
    call setline('.', a:pspace . a:checkbox . repeat(' ', l:bspace) . a:text)
endfunction

function! todo#SwitchCheckbox (...)
    " check if we need to use user assigned check box
    let l:uacb = (a:0 == 1) && (index(g:todo_checkboxes, a:1) >= 0)
    let l:cln = getline('.')
    let l:pspace = matchstr(l:cln, '^ *')
    for i in range(len(g:todo_checkboxes))
        if l:cln =~# '^ *\V'. g:todo_checkboxes[l:i]
            " found a checkbox, switch it to next checkbox
            let l:text = matchstr(l:cln, '\(^ *\V'. g:todo_checkboxes[l:i] .'\m *\)\@<=\m[^ ].*$')
            let l:checkbox = (l:uacb) ? (a:1) : (g:todo_checkboxes[(l:i + 1) % len(g:todo_checkboxes)])
            call todo#SetCheckbox(l:pspace, l:checkbox, l:text)
            return
        endif
    endfor
    let l:text = matchstr(l:cln, '\(^ *\)\@<=\v[^ ].*$')
    let l:checkbox = (l:uacb) ? (a:1) : (g:todo_checkboxes[0])
    call todo#SetCheckbox(l:pspace, l:checkbox, l:text)
endfunction

if !exists('g:todo_checkboxes')
    let g:todo_checkboxes = ['[ ]', '[v]', '[i]', '[?]', '[!]', '[x]']
endif

if !exists('g:todo_bulleted_items')
    let g:todo_bulleted_items = ['>']
endif
