================
Todo or not todo
================

A plugin for you to manage your TODOs, or NOT TODOs.

This project is still at an early development stage, many features are not customizable yet.

Ideas and many other things are appreciated!

Installation
------------

Use Vundle_

..  _Vundle: https://github.com/VundleVim/Vundle.vim

Default Key Mappings
--------------------

These mappings should finally be customizable

* [normal][insert] ``<C-c>``: switch between checkboxes
* [normal] ``>`` ``<``: increase and decrease indent
* [visual] ``>`` ``<``: increase and decrease indent of selected lines
* [normal] ``o``: open a new line with bullet
* [insert] ``<CR>``: create a new bulleted item in new line, same indent
* [insert] ``<TAB>``: when pressed before text, increase indent, otherwise just ``<TAB>``
* [insert] ``<S-TAB>``: when pressed before text, decrease indent, otherwise nothing happened
* [normal] ``I``: insert text at logical line start
* [normal] ``^``: move cursor to line start smartly
* [normal] ``J``: join two lines, bullet or checkbox on next line will de destroyed

Customizable Settings
---------------------

* Checkboxes

  - ``let g:todo_checkboxes = ['[ ]', '[v]', '[x]', '', '[i]', '[?]', '[!]']``
  - All checkboxes must be placed into this array
  - The checkboxes before empty string (``''``) will be looped with ``<C-c>``

* Bullets

  - ``let g:todo_bullets = ['>']``

* Colors

  - ``let g:todo_bullet_color = 'LightCyan'``
  - ``let g:todo_url_color = 'LightCyan'``

Screenshot
----------

..  image:: screenshot.png

License
-------

This project in released under WTFPL Version 2
