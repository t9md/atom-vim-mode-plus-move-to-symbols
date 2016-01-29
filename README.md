[![Build Status](https://travis-ci.org/t9md/atom-vim-mode-plus-move-to-symbols.svg?branch=master)](https://travis-ci.org/t9md/atom-vim-mode-plus-move-to-symbols)

# atom-vim-mode-plus-move-to-symbols

Provide symbols motion for [vim-mode-plus](https://atom.io/packages/vim-mode-plus).  

Depending on TagGenerator of [symbols-view](https://github.com/atom/symbols-view).  
But you don't have to enable `symbols-view` to use this motion.  

## keymap

```coffeescipt
'atom-text-editor.vim-mode-plus:not(.insert-mode)':
  '(': 'vim-mode-plus-user:move-to-previous-symbol'
  ')': 'vim-mode-plus-user:move-to-next-symbol'
```
