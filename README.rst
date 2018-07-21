===============================================================================
Todo or not todo
===============================================================================
A plugin for you to manage your TODOs, or NOT TODOs.

This project is still at an early development stage, many features are not
customizable yet.

Ideas, issues and many other things are appreciated!


Installation
-------------------------------------------------------------------------------
Use Vundle_ or vim-plug_

..  _Vundle: https://github.com/VundleVim/Vundle.vim
..  _vim-plug: https://github.com/junegunn/vim-plug


Key Mappings
-------------------------------------------------------------------------------
These mappings should finally be customizable.

Customizable mappings:

* [normal][insert][visual] ``<C-c>``: switch between checkboxes.

  - Customize with ``g:todo_loop_checkbox``

* [normal][insert][visual] ``<Leader>b``: set current line a bulleted item,
  checkbox will be destroyed.

  - Customize with ``g:todo_set_bullet``

* [visual] ``<Leader>c``: colorize selected text with highlighter.

  - Customize with ``g:todo_highlighter``
  - The start marker and end marker of highlighter is also customizable

    ..  code-block:: vim

        let g:todo_highlighter_start = '⢝'
        let g:todo_highlighter_end = '⡢'

* [normal] ``<Leader>c``: erase highlighter of current line.

  - Customize with ``g:todo_highlighter``

Default mappings:

* [normal] ``>`` ``<``: increase and decrease indent
* [visual] ``>`` ``<``: increase and decrease indent of selected lines
* [normal] ``o``: open a new line with bullet
* [insert] ``<CR>``: create a new bulleted item in new line, same indent
* [normal] ``I``: insert text at logical line start
* [normal] ``^``: move cursor to line start smartly
* [normal] ``J``: join two lines, bullet or checkbox on next line will de destroyed
* [insert] ``<TAB>``, ``<S-TAB>``: if cursor is at line start, increase/decrease indent
* [insert] ``<C-d>``, ``<C-t>``: decrease/increase indent of current line

You can disable default mappings with ``let g:todo_default_mappings = 0``


Customizable Settings
-------------------------------------------------------------------------------

Checkboxes
*******************************************************************************
Checkboxes are separated into two types ::

  [ ][i][v][x]
  [!]

These checkboxes are recognized by this plugin, i.e. they are colorized and can
be switched with ``<C-c>``.

Depend on their type, ``<C-c>`` changes them in different way:

* If your cursor is on a bulleted item, press ``<C-c>`` makes that bullet a ``[ ]``
* If your cursor is on the same line with ``[ ]``, ``[i]``, ``[v]`` or ``[x]``,
  ``<C-c>`` makes it the next one (round-robin.)
* If your cursor is on the same line with ``[!]``, ``<C-c>`` makes it a ``[ ]``

To add a checkbox, stick this into your vimrc:

..  code-block:: vim

    call todo#checkbox#cycle('[ ]', 'white', 'Description')

This checkbox can be cycleed with ``<C-c>``.

To add a checkbox that is not participated in ``<C-c>`` cycle, use ``nocycle``:

..  code-block:: vim

    call todo#checkbox#nocycle('[!]', 'red', 'Important')

Here is the default settings of this plugin: ::

    call todo#checkbox#cycle('[ ]', 'white', 'Todo')
    call todo#checkbox#cycle('[i]', 'yellow', 'Working')
    call todo#checkbox#cycle('[v]', 'green', 'Done')
    call todo#checkbox#cycle('[x]', 'red', 'Not todo')
    call todo#checkbox#nocycle('[!]', 'red', 'Important')


The color strings are evaluated into argument ``ctermfg``, if you are new to
vim, you can pick colors here:

* Black
* DarkBlue
* DarkGreen
* DarkCyan
* DarkRed
* DarkMagenta
* Brown, DarkYellow
* LightGray, LightGrey, Gray, Grey
* DarkGray, DarkGrey
* Blue, LightBlue
* Green, LightGreen
* Cyan, LightCyan
* Red, LightRed
* Magenta, LightMagenta
* Yellow, LightYellow
* White


File Specific Checkboxes
*******************************************************************************
Sometimes you need a special todo file for specific kind of todo-items.

This plugin allows you to declare checkboxes by filename:

..  code-block:: vim

    call todo#checkbox#file('special\.todo')
    call todo#checkbox#cycle('[Pending]', 'white')
    call todo#checkbox#cycle('[Working]', 'yellow')
    call todo#checkbox#cycle('[Done]', 'green')

    call todo#checkbox#file('')
    call todo#checkbox#cycle('[?]', 'white')

``todo#checkbox#file()`` accepts a vim regex pattern;
all ``todo#checkbox#cycle()`` and ``todo#checkbox#nocycle()`` follows it will
be registered under the pattern (until next pattern specified.)

The order is important, only the first pattern that matches the filename will
be applied.

When no patterns matches the filename, the default setting will be applied
(Listed above.)


Menu Mode
*******************************************************************************
For those who loves popup menu, this plugin also provides menu mode:

..  code-block:: vim

    let g:todo_select_checkbox = '<C-k>'

Under menu mode, all checkboxes can be selected, no matter they are added with
no-loop option.

Menu mode and loop mode can be configured with different key mappings.


Bullets
*******************************************************************************
Currently only one kind of bullets supported:

..  code-block:: vim

    let g:todo_bullet = '>'


Colors
*******************************************************************************
You can assign color of certain patterns:

..  code-block:: vim

    let g:todo_bullet_color = 'Cyan'
    let g:todo_url_color = 'Cyan'
    let g:todo_comment_prefix = '\v(^| )#'
    let g:todo_comment_color = 'Cyan'
    let g:todo_highlighter_color = 'Yellow'

Currently only foreground color setting supported, no underline or background color yet.


Screenshot
-------------------------------------------------------------------------------
..  image:: screenshot.png


License
-------------------------------------------------------------------------------
This project is released under WTFPL Version 2.
See http://sam.zoy.org/wtfpl/COPYING.
