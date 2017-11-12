requireFrom = (pack, path) ->
  packPath = atom.packages.resolvePackagePath(pack)
  require "#{packPath}/#{path}"

{getVimState} = requireFrom 'vim-mode-plus', 'spec/spec-helper'

activatePackageByActivationCommand = (name, fn) ->
  activationPromise = atom.packages.activatePackage(name)
  fn()
  activationPromise

describe "vim-mode-plus-move-to-symbols", ->
  [set, ensure, ensureWait, editor, editorElement, vimState] = []
  beforeEach ->
    atom.keymaps.add "test",
      'atom-text-editor.vim-mode-plus:not(.insert-mode)':
        '(': 'vim-mode-plus-user:move-to-previous-symbol'
        ')': 'vim-mode-plus-user:move-to-next-symbol'
      , 101

    waitsForPromise ->
      activatePackageByActivationCommand 'vim-mode-plus-move-to-symbols', ->
        atom.workspace.open().then (editor) ->
          atom.commands.dispatch(editor.element, 'vim-mode-plus-user:move-to-previous-symbol')

  describe "coffee editor", ->
    pack = 'language-coffee-script'
    beforeEach ->
      waitsForPromise ->
        atom.packages.activatePackage(pack)

      getVimState 'sample.coffee', (state, vim) ->
        vimState = state
        {editor, editorElement} = state
        {set, ensure, ensureWait} = vim

      waitsForPromise ->
        atom.packages.activatePackage('vim-mode-plus-move-to-symbols')

      runs ->
        set cursor: [0, 0]

    afterEach ->
      atom.packages.deactivatePackage(pack)

    it "move next and previous symbols", ->
      ensureWait ')', cursor: [1, 2]
      ensureWait ')', cursor: [3, 2]
      ensureWait ')', cursor: [5, 2]
      ensureWait ')', cursor: [7, 0]
      ensureWait ')', cursor: [8, 2]

      ensureWait '(', cursor: [7, 0]
      ensureWait '(', cursor: [5, 2]
      ensureWait '(', cursor: [3, 2]
      ensureWait '(', cursor: [1, 2]
      ensureWait '(', cursor: [0, 0]

    it "support count", ->
      ensureWait '3 )', cursor: [5, 2]
      ensureWait '2 )', cursor: [8, 2]

      ensureWait '3 (', cursor: [3, 2]
      ensureWait '2 (', cursor: [0, 0]

  describe "github markdown editor", ->
    pack = 'language-gfm'
    beforeEach ->
      waitsForPromise ->
        atom.packages.activatePackage(pack)

      getVimState 'sample.md', (state, vim) ->
        vimState = state
        {editor, editorElement} = state
        {set, ensure, ensureWait} = vim

      runs ->
        set cursor: [0, 0]

    afterEach ->
      atom.packages.deactivatePackage(pack)

    it "move next and previous symbols", ->
      ensureWait ')', cursor: [2, 0]
      ensureWait ')', cursor: [4, 0]
      ensureWait ')', cursor: [5, 0]
      ensureWait ')', cursor: [7, 0]
      ensureWait ')', cursor: [9, 0]
      ensureWait ')', cursor: [10, 0]

      ensureWait '(', cursor: [9, 0]
      ensureWait '(', cursor: [7, 0]
      ensureWait '(', cursor: [5, 0]
      ensureWait '(', cursor: [4, 0]
      ensureWait '(', cursor: [2, 0]
      ensureWait '(', cursor: [0, 0]
