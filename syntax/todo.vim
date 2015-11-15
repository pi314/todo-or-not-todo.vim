" prevent syntax/ loaded before ftplugin/, which contains all important
" variables
if !exists('g:todo_plugin_loaded')
    finish
endif

syn match   todo_string _\v"([^\\"]|\\.)*"_
hi def      todo_string ctermfg=LightMagenta

syn match   todo_emphasis   _\v\*[^*]*\*_
hi def      todo_emphasis   ctermfg=White

syn match   todo_strong_emphasis    _\v\*\*.*\*\*_
hi def      todo_strong_emphasis    ctermfg=LightRed

syn match   todo_url    _\<[a-zA-Z+-.]*://[^ \[\]]*_
hi def      todo_url    ctermfg=LightCyan

" ------------------------------------------- "
" dynamically generate bullet coloring syntax "
" ------------------------------------------- "

execute 'syn match todo_bulleted_item _\v(^ *)@<=\V'. g:todo_bullet .'_'
execute 'hi def    todo_bulleted_item ctermfg='. g:todo_bullet_color

let s:checkbox_flow_number = 1
for c in keys(b:todo_checkbox_color)
    if c != '' && b:todo_checkbox_color[c] != ''
        execute 'syn match checkbox'. s:checkbox_flow_number .' _\v(^ *)@<=\V'. c .'_'
        execute 'hi def    checkbox'. s:checkbox_flow_number .' ctermfg='. b:todo_checkbox_color[c] .''
        let s:checkbox_flow_number = s:checkbox_flow_number + 1
    endif
endfor

execute 'syn match todo_comment _\V'. g:todo_comment_prefix .'\v.*$_'
execute 'hi def    todo_comment ctermfg='. g:todo_comment_color

execute 'syn match todo_highlighter_symbol _\v['. g:todo_highlighter_start . g:todo_highlighter_end .']_ conceal'
execute 'syn match todo_highlighter _\v('. g:todo_highlighter_start .')@<='.
        \'[^'. g:todo_highlighter_start . g:todo_highlighter_end .']*'.
        \'('. g:todo_highlighter_end .')@=_'
execute 'hi def    todo_highlighter ctermfg=Black ctermbg='. g:todo_highlighter_color
