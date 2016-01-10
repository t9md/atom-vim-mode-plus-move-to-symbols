{CompositeDisposable} = require 'atom'

cachedTags = null # global cache for tags

module.exports =
  activate: ->
    cachedTags = {}
    @subscriptions = new CompositeDisposable
    @subscribe atom.workspace.observeTextEditors (editor) =>
      @subscribe editor.onDidSave ->
        delete cachedTags[editor.getPath()]

  deactivate: ->
    @subscriptions.dispose()
    @subscriptions = {}
    cachedTags = null

  subscribe: (args...) ->
    @subscriptions.add args...

  consumeVim: ({Base}) ->
    {state, MoveToNextSymbol, MoveToPreviousSymbol} = require "./move-to-symbols"
    @subscribe MoveToNextSymbol.registerCommand()
    @subscribe MoveToPreviousSymbol.registerCommand()
    state.cachedTags = cachedTags
