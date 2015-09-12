syn match   custom_checkbox         '\[.\]'
syn match   empty_checkbox          '\[ \]'
syn match   empty_checkbox          '☐'
syn match   checked_checkbox        '\[v\]'
syn match   checked_checkbox        '☑'
syn match   canceled_checkbox       '\[x\]'
syn match   canceled_checkbox       '☒'
syn match   doing_checkbox          '\[i\]'
syn match   question_checkbox       '\[?\]'
syn match   exclamation_checkbox    '\[!\]'
hi def      empty_checkbox          cterm=bold ctermfg=white
hi def      custom_checkbox         cterm=bold ctermfg=white
hi def      checked_checkbox        cterm=bold ctermfg=green
hi def      canceled_checkbox       cterm=bold ctermfg=red
hi def      doing_checkbox          cterm=bold ctermfg=yellow
hi def      question_checkbox       cterm=bold ctermfg=yellow
hi def      exclamation_checkbox    cterm=bold ctermfg=red

syn match   todo_string '\v"([^\\"]|\\.)*"'
hi def      todo_string cterm=bold ctermfg=magenta

syn match   todo_emphasis   '\v\*[^*]*\*'
hi def      todo_emphasis   cterm=bold ctermfg=white

syn match   todo_strong_emphasis    '\v\*\*.*\*\*'
hi def      todo_strong_emphasis    cterm=bold ctermfg=red

syn match   todo_url    '\<[a-zA-Z+-.]*://[^ \[\]]*'
hi def      todo_url    cterm=bold ctermfg=cyan

" ------------------------------------------- "
" dynamically generate bullet coloring syntax "
" ------------------------------------------- "

for b in g:todo_bullets
    execute 'syn match todo_bulleted_item /\(^ *\)\@<=\V'. b .'/'
endfor

execute 'hi def todo_bulleted_item ctermfg='. g:todo_bullet_color
