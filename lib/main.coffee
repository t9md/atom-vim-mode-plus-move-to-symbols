{Emitter, CompositeDisposable} = require 'atom'
_ = require 'underscore-plus'

cachedTags = null # global cache for tags
TagGenerator = null

# Utils
requireFrom = (pack, path) ->
  packPath = atom.packages.resolvePackagePath(pack)
  require "#{packPath}/lib/#{path}"

getActivePackage = (pack) ->
  atom.packages.getActivePackage(pack)

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
    TagGenerator = requireFrom 'symbols-view', 'tag-generator'
    {Point} = require 'atom'
    Motion = Base.getClass('Motion')

    class MoveToNextSymbol extends Motion
      @extend()
      @commandPrefix: 'vim-mode-plus-user'
      direction: 'next'
      requireInput: true

      initialize: ->
        @emitter = new Emitter
        @getTags()

      onDidGenerateTags: (fn) ->
        @emitter.on 'did-generate-tags', fn

      getCachedTags: ->
        cachedTags

      generateTags: (fn) ->
        filePath = @editor.getPath()
        scopeName = @editor.getGrammar().scopeName
        cache = @getCachedTags()
        new TagGenerator(filePath, scopeName).generate().done (tags) ->
          # console.log "generate for #{filePath}"
          cache[filePath] = tags
          fn(tags)

      getTags: ->
        tags = @getCachedTags()[@editor.getPath()]?.slice()
        if tags?
          @input = tags
        else
          @generateTags (tags) =>
            @input = tags
            @vimState.operationStack.process()

      detectRow: (cursor) ->
        tags = @input.slice()
        tags?.reverse() if @direction is 'prev'

        cursorRow = cursor.getBufferRow()
        _.detect tags, (tag) =>
          row = tag.position.row
          switch @direction
            when 'prev' then row < cursorRow
            when 'next' then row > cursorRow

      moveCursor: (cursor) ->
        @countTimes =>
          if (tag = @detectRow(cursor))?
            cursor.setBufferPosition(tag.position)
            cursor.moveToFirstCharacterOfLine()

    class MoveToPreviousSymbol extends MoveToNextSymbol
      @extend()
      direction: 'prev'

    MoveToNextSymbol.registerCommand()
    MoveToPreviousSymbol.registerCommand()
