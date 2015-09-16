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
for c in keys(g:_todo_checkbox_color)
    if c != '' && g:_todo_checkbox_color[c] != ''
        execute 'syn match checkbox'. s:checkbox_flow_number .' _\v(^ *)@<=\V'. c .'_'
        execute 'hi def    checkbox'. s:checkbox_flow_number .' ctermfg='. g:_todo_checkbox_color[c] .''
        let s:checkbox_flow_number = s:checkbox_flow_number + 1
    endif
endfor
