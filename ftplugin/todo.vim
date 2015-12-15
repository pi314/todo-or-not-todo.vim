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

function! s:value_ok(option, type)
    if !exists('g:'. a:option) || type(g:[a:option]) != a:type
        return 0
    endif
    return 1
endfunction

function! s:set_default_value(option, type, default_value)
    if !s:value_ok(a:option, a:type)
        let g:[a:option] = a:default_value
    endif
endfunction

if !exists('b:todo_checkbox_initialized')
    call todo#add#checkbox('[ ]', 'White')
    call todo#add#checkbox('[v]', 'LightGreen')
    call todo#add#checkbox('[x]', 'LightRed')
    call todo#add#checkbox('[i]', 'LightYellow', 0)
    call todo#add#checkbox('[?]', 'LightYellow', 0)
    call todo#add#checkbox('[!]', 'LightRed', 0)
    let b:todo_checkbox_initialized = 1
endif

call s:set_default_value('todo_bullet',         type(''), '>')
call s:set_default_value('todo_bullet_color',   type(''), 'LightCyan')
call s:set_default_value('todo_url_color',      type(''), 'LightCyan')
call s:set_default_value('todo_loop_checkbox',  type(''), '<C-c>')
call s:set_default_value('todo_set_bullet',     type(''), '<leader>b')
call s:set_default_value('todo_comment_prefix', type(''), '\v(^| )#')
call s:set_default_value('todo_comment_color',  type(''), 'LightCyan')
call s:set_default_value('todo_highlighter',    type(''),  '<leader>c')

if !s:value_ok('todo_highlighter_start', type(''))
        \|| !s:value_ok('todo_highlighter_end', type(''))
    let g:todo_highlighter_start = '⢝'
    let g:todo_highlighter_end = '⡢'
endif

call s:set_default_value('todo_highlighter_color',      type(''), 'LightYellow')

if !s:value_ok('todo_loop_checkbox', type('')) &&
        \!s:value_ok('todo_loop_checkbox', type(''))
    let g:todo_loop_checkbox = '<C-c>'
    let g:todo_select_checkbox = ''
else
    call s:set_default_value('todo_loop_checkbox', type(''), '')
    call s:set_default_value('todo_select_checkbox', type(''), '')
endif

" -------- "
" mappings "
" -------- "

if g:todo_loop_checkbox !=# ''
    execute 'nnoremap <buffer> <silent> '. g:todo_loop_checkbox .' :call todo#switch_checkbox()<CR>'
    execute 'inoremap <buffer> <silent> '. g:todo_loop_checkbox .' <C-o>:call todo#switch_checkbox()<CR>'
    execute 'vnoremap <buffer> <silent> '. g:todo_loop_checkbox .' :call todo#switch_checkbox()<CR>'
endif

if g:todo_select_checkbox !=# ''
    execute 'nnoremap <buffer> <silent> '. g:todo_select_checkbox .' :call todo#checkbox_menu()<CR>'
    execute 'inoremap <buffer> <silent> '. g:todo_select_checkbox .' <C-r>=todo#checkbox_menu()<CR>'
    autocmd CompleteDone * call todo#recover_menu_state()
endif

if g:todo_set_bullet !=# ''
    execute 'nnoremap <buffer> <silent> '. g:todo_set_bullet .' :call todo#set_bullet()<CR>'
    execute 'inoremap <buffer> <silent> '. g:todo_set_bullet .' <C-o>:call todo#set_bullet()<CR>'
    execute 'vnoremap <buffer> <silent> '. g:todo_set_bullet .' :call todo#set_bullet()<CR>'
endif

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

if g:todo_highlighter !=# ''
    execute 'vnoremap <buffer> <silent> '. g:todo_highlighter .' :call todo#highlighter()<CR>'
    execute 'nnoremap <buffer> <silent> '. g:todo_highlighter .' :call todo#eraser()<CR>'
endif

" prevent syntax/ loaded before ftplugin/, which contains all important
" variables
let g:todo_plugin_loaded = 1
syntax on
