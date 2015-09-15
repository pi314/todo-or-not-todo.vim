" ----------------------------------- "
" extract and set tab related options "
" ----------------------------------- "

if &softtabstop == 0
    " user not setting &softtabstop, set it to 4
    setlocal softtabstop=4
endif

if shiftwidth() == 8
    " user not setting &shiftwidth, set it to 4
    setlocal shiftwidth=4
endif

" -------- "
" mappings "
" -------- "

nnoremap <buffer> <silent> <C-c> :call todo#switch_checkbox()<CR>
inoremap <buffer> <silent> <C-c> <C-o>:call todo#switch_checkbox()<CR>

nnoremap <buffer> <silent> > :call todo#increase_indent()<CR>
nnoremap <buffer> <silent> < :call todo#decrease_indent()<CR>
vnoremap <buffer> <silent> > :call todo#increase_indent()<CR>gv
vnoremap <buffer> <silent> < :call todo#decrease_indent()<CR>gv

nnoremap <buffer> <silent> o :call todo#open_new_line()<CR>A
inoremap <buffer> <silent> <CR> <CR><C-o>:call todo#set_bullet()<CR>

nnoremap <buffer> <silent> I I<C-o>:call todo#move_cursor_to_line_start()<CR>
nnoremap <buffer> <silent> ^ :call todo#move_cursor_to_line_start()<CR>

nnoremap <buffer> <silent> J :call todo#join_two_lines()<CR>

" --------------------- "
" set default variables "
" --------------------- "

function! s:not_string_array (ary) " {{{
    if type(a:ary) != type([])
        return 1
    endif
    for i in a:ary
        if type(l:i) != type('')
            return 1
        endif
    endfor

    return 0
endfunction " }}}

if !exists('g:todo_checkboxes') || s:not_string_array(g:todo_checkboxes)
    let g:todo_checkboxes = ['[ ]', '[v]', '[x]', '', '[i]', '[?]', '[!]']
endif

if !exists('g:todo_bullets') || s:not_string_array(g:todo_bullets)
    let g:todo_bullets = ['>']
endif

if !exists('g:todo_bullet_color') || type(g:todo_bullet_color) != type('')
    let g:todo_bullet_color = 'LightCyan'
endif

if !exists('g:todo_url_color') || type(g:todo_url_color) != type('')
    let g:todo_url_color = 'LightCyan'
endif
