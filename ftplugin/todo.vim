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


function! s:TrimLeft (text)
    return substitute(a:text, '^\s*', '', '')
endfunction


function! s:StartsWith (text, pattern)
    return a:text[:(strlen(a:pattern) - 1)] ==# a:pattern
endfunction


function! s:KindsOfCheckbox ()
    if s:kinds_of_checkbox == -2
        let s:kinds_of_checkbox = index(g:todo_checkboxes, '')
        if s:kinds_of_checkbox == -1
            let s:kinds_of_checkbox = len(g:todo_checkboxes)
        endif
    endif
    return s:kinds_of_checkbox
endfunction


function! s:NextCheckbox (i)
    let l:l = s:KindsOfCheckbox()
    if a:i >= l:l
        return g:todo_checkboxes[0]
    endif
    return g:todo_checkboxes[(a:i + 1) % (l:l)]
endfunction


function! s:SetCheckbox (pspace, checkbox, text)
    " <pspace> <checkbox> <text>
    " <pspace> <checkbox> <bspace> <ttext>
    let l:cb_len = strdisplaywidth(a:checkbox)
    let l:ttext  = s:TrimLeft(a:text)
    let l:bspace = repeat(' ', &softtabstop - (l:cb_len % &softtabstop))
    call setline('.', a:pspace . a:checkbox . l:bspace . l:ttext)
endfunction


function! TodoSwitchCheckbox (...)
    " check if we need to use user assigned check box
    let l:uacb = (a:0 == 1) && (index(g:todo_checkboxes, a:1) >= 0)

    " current line content
    let l:clc = getline('.')
    let l:pspace = matchstr(l:clc, '^ *')
    let l:tclc = s:TrimLeft(l:clc)
    for i in range(len(g:todo_checkboxes))
        " iterate through predefined checkboxes to match string
        let l:pattern_len = strlen(g:todo_checkboxes[l:i])
        if s:StartsWith(l:tclc, g:todo_checkboxes[l:i])
            " found a checkbox, switch it to next checkbox
            let l:text = l:tclc[(l:pattern_len):]
            let l:checkbox = (l:uacb) ? (a:1) : (s:NextCheckbox(l:i))
            call s:SetCheckbox(l:pspace, l:checkbox, l:text)
            return
        endif
    endfor

    let l:checkbox = (l:uacb) ? (a:1) : (g:todo_checkboxes[0])
    call s:SetCheckbox(l:pspace, l:checkbox, l:tclc)
endfunction


" ---------------------
" set default variables
" ---------------------

function! s:IsNotStringArray (ary)
    if type(a:ary) != type([])
        return 0
    endif
    for i in a:ary
        if type(l:i) != type('')
            return 0
        endif
    endfor

    return 1
endfunction


if !exists('g:todo_checkboxes') || s:IsNotStringArray(g:todo_checkboxes)
    let g:todo_checkboxes = ['[ ]', '[v]', '[x]', '', '[i]', '[?]', '[!]']
endif

let s:kinds_of_checkbox = -2

if !exists('g:todo_bulleted_items') || s:IsNotStringArray(g:todo_bulleted_items)
    let g:todo_bulleted_items = ['>']
endif
