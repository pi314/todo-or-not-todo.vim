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

setlocal conceallevel=3
setlocal concealcursor=n

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

if !exists('g:_todo_checkbox_initialized')
    call todo#add#checkbox('[ ]', 'White')
    call todo#add#checkbox('[v]', 'LightGreen')
    call todo#add#checkbox('[x]', 'LightRed')
    call todo#add#checkbox('[i]', 'LightYellow', 0)
    call todo#add#checkbox('[?]', 'LightYellow', 0)
    call todo#add#checkbox('[!]', 'LightRed', 0)
    let g:_todo_checkbox_initialized = 1
endif

if !exists('g:todo_bullet') || s:not_string_array(g:todo_bullet)
    let g:todo_bullet = '>'
endif

if !exists('g:todo_bullet_color') || type(g:todo_bullet_color) != type('')
    let g:todo_bullet_color = 'LightCyan'
endif

if !exists('g:todo_url_color') || type(g:todo_url_color) != type('')
    let g:todo_url_color = 'LightCyan'
endif

if !exists('g:todo_loop_checkbox') || type (g:todo_loop_checkbox) != type('') || g:todo_loop_checkbox == ''
    let g:todo_loop_checkbox = '<C-c>'
endif

if !exists('g:todo_set_bullet') || type (g:todo_set_bullet) != type('') || g:todo_set_bullet == ''
    let g:todo_set_bullet = '<leader>b'
endif

if !exists('g:todo_comment_prefix') || type(g:todo_comment_prefix) != type('')
    let g:todo_comment_prefix = '\v(^| )#'
endif

if !exists('g:todo_comment_color') || type(g:todo_comment_color) != type('')
    let g:todo_comment_color = 'LightCyan'
endif

if !exists('g:todo_highlighter') || type(g:todo_highlighter) != type('')
    let g:todo_highlighter = '<leader>c'
endif

if !exists('g:todo_highlighter_start') || type(g:todo_highlighter_start) != type('')
        \|| !exists('g:todo_highlighter_end') || type(g:todo_highlighter_end) != type('')
    let g:todo_highlighter_start = '⢝'
    let g:todo_highlighter_end = '⡢'
endif

if !exists('g:todo_highlighter_color') || type(g:todo_highlighter_color) != type('')
    let g:todo_highlighter_color = 'LightYellow'
endif

" -------- "
" mappings "
" -------- "

execute 'nnoremap <buffer> <silent> '. g:todo_loop_checkbox .' :call todo#switch_checkbox()<CR>'
execute 'inoremap <buffer> <silent> '. g:todo_loop_checkbox .' <C-o>:call todo#switch_checkbox()<CR>'
execute 'vnoremap <buffer> <silent> '. g:todo_loop_checkbox .' :call todo#switch_checkbox()<CR>'

execute 'nnoremap <buffer> <silent> '. g:todo_set_bullet .' :call todo#set_bullet()<CR>'
execute 'inoremap <buffer> <silent> '. g:todo_set_bullet .' <C-o>:call todo#set_bullet()<CR>'
execute 'vnoremap <buffer> <silent> '. g:todo_set_bullet .' :call todo#set_bullet()<CR>'

nnoremap <buffer> <silent> > :call todo#increase_indent()<CR>
nnoremap <buffer> <silent> < :call todo#decrease_indent()<CR>
vnoremap <buffer> <silent> > :call todo#increase_indent()<CR>gv
vnoremap <buffer> <silent> < :call todo#decrease_indent()<CR>gv

nnoremap <buffer> <silent> o A<C-r>=todo#carriage_return()<CR>
inoremap <buffer> <silent> <CR> <C-r>=todo#carriage_return()<CR>

nnoremap <buffer> <silent> I I<C-o>:call todo#move_cursor_to_line_start()<CR>
nnoremap <buffer> <silent> ^ :call todo#move_cursor_to_line_start()<CR>

nnoremap <buffer> <silent> J :call todo#join_two_lines()<CR>

inoremap <buffer> <silent> <TAB> <C-r>=todo#tab()<CR>
inoremap <buffer> <silent> <S-TAB> <C-\><C-o>:call todo#shift_tab()<CR>

execute 'vnoremap <buffer> <silent> '. g:todo_highlighter .' :call todo#highlighter()<CR>'

" prevent syntax/ loaded before ftplugin/, which contains all important
" variables
let g:todo_plugin_loaded = 1
syntax on
