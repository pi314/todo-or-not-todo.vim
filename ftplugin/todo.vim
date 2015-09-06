" -----------------------------------
" extract and set tab related options
" -----------------------------------

if &softtabstop == 0
    " user not setting &softtabstop, set it to 4
    setlocal softtabstop=4
endif

if shiftwidth() == 8
    " user not setting &shiftwidth, set it to 4
    setlocal shiftwidth=4
endif


function! TrimLeft (text)
    return substitute(a:text, '^\s*', '', '')
endfunction


function! StartsWith (text, pattern)
    return a:text[:(strlen(a:pattern) - 1)] ==# a:pattern
endfunction


function! todo#SetCheckbox (pspace, checkbox, text)
    " <pspace> <checkbox> <text>
    " <pspace> <checkbox> <bspace> <ttext>
    let l:cb_len = strdisplaywidth(a:checkbox)
    let l:ttext  = TrimLeft(a:text)
    let l:bspace = repeat(' ', &softtabstop - (l:cb_len % &softtabstop))
    call setline('.', a:pspace . a:checkbox . l:bspace . l:ttext)
endfunction


function! todo#SwitchCheckbox (...)
    " check if we need to use user assigned check box
    let l:uacb = (a:0 == 1) && (index(g:todo#checkboxes, a:1) >= 0)

    " current line content
    let l:clc = getline('.')
    let l:pspace = matchstr(l:clc, '^ *')
    let l:tclc = TrimLeft(l:clc)
    for i in range(len(g:todo#checkboxes))
        " iterate through predefined checkboxes to match string
        let l:pattern_len = strlen(g:todo#checkboxes[l:i])
        if StartsWith(l:tclc, g:todo#checkboxes[l:i])
            " found a checkbox, switch it to next checkbox
            let l:text = l:tclc[(l:pattern_len):]
            let l:checkbox = (l:uacb) ? (a:1) : (g:todo#checkboxes[(l:i + 1) % len(g:todo#checkboxes)])
            call todo#SetCheckbox(l:pspace, l:checkbox, l:text)
            return
        endif
    endfor

    let l:checkbox = (l:uacb) ? (a:1) : (g:todo#checkboxes[0])
    call todo#SetCheckbox(l:pspace, l:checkbox, l:tclc)
endfunction


" ---------------------
" set default variables
" ---------------------

if !exists('todo#checkboxes')
    let todo#checkboxes = ['[ ]', '[v]', '[i]', '[?]', '[!]', '[x]']
endif

if !exists('todo#bulleted_items')
    let todo#bulleted_items = ['>']
endif
