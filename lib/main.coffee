{CompositeDisposable} = require 'atom'

module.exports =
  activate: ->
    @subscriptions = new CompositeDisposable

  deactivate: ->
    @subscriptions.dispose()
    [@subscriptions, cachedTag] = []

  subscribe: (args...) ->
    @subscriptions.add args...

  consumeVim: ({Base}) ->
    {cachedTag, MoveToNextSymbol, MoveToPreviousSymbol} = require "./move-to-symbols"
    @subscribe(
      MoveToNextSymbol.registerCommand()
      MoveToPreviousSymbol.registerCommand()
    )
    @subscribe atom.workspace.observeTextEditors (editor) =>
      @subscribe editor.onDidSave ->
        delete cachedTag[editor.getPath()]
