syn match   todo_string _\v"([^\\"]|\\.)*"_
hi def      todo_string ctermfg=Magenta

syn match   todo_emphasis   _\v\*[^*]*\*_
hi def      todo_emphasis   ctermfg=White

syn match   todo_strong_emphasis    _\v\*\*.{-}\*\*_
hi def      todo_strong_emphasis    ctermfg=Red

if g:todo_url_color !=# '' && g:todo_url_pattern !=# ''
    execute 'syn match todo_url _'. g:todo_url_pattern .'_'
    execute 'hi def todo_url ctermfg='. g:todo_url_color
endif


" --------------------------------------------------------------------------- "
" dynamically generate bullet color syntax
" --------------------------------------------------------------------------- "
if g:todo_bullet !=# ''
    execute 'syn match todo_bulleted_item _\v(^\s*)@<=\V'. g:todo_bullet .'_'
endif

if g:todo_bullet_color !=# ''
    execute 'hi def todo_bulleted_item ctermfg='. g:todo_bullet_color
endif


" --------------------------------------------------------------------------- "
" Color checkboxes according to user settings
" --------------------------------------------------------------------------- "
function! s:color_checkboxes ()
    for l:item in todo#checkbox#_all()
        execute 'hi def    '. tolower(l:item[1]) .'_checkbox ctermfg='. l:item[1] .''
        execute 'syn match '. tolower(l:item[1]) .'_checkbox _\v(^ *)@<=\V'. l:item[0] .'_'
    endfor
endfunction
call s:color_checkboxes()

if g:todo_highlighter_start !=# '' && g:todo_highlighter_end !=# ''
    " execute 'syn match todo_highlighter_symbol _\V'. g:todo_highlighter_start .'_ conceal'
    " execute 'syn match todo_highlighter_symbol _\V'. g:todo_highlighter_end .'_ conceal'
    execute 'syn match todo_highlighter _\v\V'. g:todo_highlighter_start .'\v'.
            \'.*'.
            \'\V'. g:todo_highlighter_end .'\v_'
endif

if g:todo_highlighter_color !=# ''
    execute 'hi def    todo_highlighter ctermfg=Black ctermbg='. g:todo_highlighter_color
endif

if g:todo_comment_prefix !=# ''
    execute 'syn match todo_comment _\V'. g:todo_comment_prefix .'\v.*$_'
endif

if g:todo_comment_color !=# ''
    execute 'hi def    todo_comment ctermfg='. g:todo_comment_color
endif
