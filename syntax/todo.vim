syn match   todo_custom_checkbox        '\[.\]'
syn match   todo_empty_checkbox         '\[ \]'
syn match   todo_empty_checkbox         '☐'
syn match   todo_checked_checkbox       '\[v\]'
syn match   todo_checked_checkbox       '☑'
syn match   todo_canceled_checkbox      '\[x\]'
syn match   todo_canceled_checkbox      '☒'
syn match   todo_doing_checkbox         '\[i\]'
syn match   todo_question_checkbox      '\[?\]'
syn match   todo_exclamation_checkbox   '\[!\]'
hi def      todo_empty_checkbox         ctermfg=White
hi def      todo_custom_checkbox        ctermfg=White
hi def      todo_checked_checkbox       ctermfg=LightGreen
hi def      todo_canceled_checkbox      ctermfg=LightRed
hi def      todo_doing_checkbox         ctermfg=LightYellow
hi def      todo_question_checkbox      ctermfg=LightYellow
hi def      todo_exclamation_checkbox   ctermfg=LightRed

syn match   todo_string '\v"([^\\"]|\\.)*"'
hi def      todo_string ctermfg=LightMagenta

syn match   todo_emphasis   '\v\*[^*]*\*'
hi def      todo_emphasis   ctermfg=White

syn match   todo_strong_emphasis    '\v\*\*.*\*\*'
hi def      todo_strong_emphasis    ctermfg=LightRed

syn match   todo_url    '\<[a-zA-Z+-.]*://[^ \[\]]*'
hi def      todo_url    ctermfg=LightCyan

" ------------------------------------------- "
" dynamically generate bullet coloring syntax "
" ------------------------------------------- "

for b in g:todo_bullets
    execute 'syn match todo_bulleted_item /\(^ *\)\@<=\V'. b .'/'
endfor

execute 'hi def todo_bulleted_item ctermfg='. g:todo_bullet_color
