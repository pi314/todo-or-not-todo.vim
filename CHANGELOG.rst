* 0.11.1

  - Fix bug of checkbox coloring procedure

* 0.11.0

  - Support file-specific checkbox, just like vim modelines
  - Add colon-separated strings like this at the top of file to define new checkbox ::

      # todo: [c]: cyan: Canceled
      # todo: [n]: cyan: noloop: Canceled

* 0.10.3

  - Make todo_strong_emphasis highlight non-greedy

* 0.10.2

  - Fix bug: ``>`` and ``<`` doesn't work on lines without bullet

* 0.10.1

  - Fix bug: CompleteDone event always send a ``<ESC>``

* 0.10.0

  - We have document now
  - Default mappings now can be disable
  - Default colors 'Light' prefix removed
  - ``todo#add#checkbox()`` is renamed to ``todo#checkbox#add()``

* 0.9.0

  - ``g:todo_checkbox_switch_style`` not supported anymore, replaced with ``g:todo_switch_checkbox`` and ``g:todo_select_checkbox``
