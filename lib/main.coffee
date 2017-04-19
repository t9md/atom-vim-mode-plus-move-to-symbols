{CompositeDisposable} = require 'atom'

module.exports =
  registries: null
  activate: ->
    @subscriptions = new CompositeDisposable

  deactivate: ->
    @subscriptions.dispose()
    @registries?.cachedTag = null
    [@subscriptions, @registries] = []

  consumeVim: ({registerCommandFromSpec}) ->
    getClass = (name) =>
      @registries ?= require "./move-to-symbols"
      @registries[name]

    commandPrefix = 'vim-mode-plus-user'
    @subscriptions.add(
      registerCommandFromSpec('MoveToNextSymbol', {commandPrefix, getClass})
      registerCommandFromSpec('MoveToPreviousSymbol', {commandPrefix, getClass})
    )
    @subscriptions.add atom.workspace.observeTextEditors (editor) =>
      @subscriptions.add editor.onDidSave =>
        delete @registries?.cachedTag[editor.getPath()]
