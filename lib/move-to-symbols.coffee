requireFrom = (pack, path) ->
  packPath = atom.packages.resolvePackagePath(pack)
  require "#{packPath}/lib/#{path}"

{Emitter, Point} = require 'atom'
_ = require 'underscore-plus'

TagGenerator = requireFrom 'symbols-view', 'tag-generator'
Base = requireFrom 'vim-mode-plus', 'base'
Motion = Base.getClass('Motion')

state = {}

class MoveToNextSymbol extends Motion
  @commandPrefix: 'vim-mode-plus-user'
  direction: 'next'
  requireInput: true

  initialize: ->
    @emitter = new Emitter
    @getTags()

  onDidGenerateTags: (fn) ->
    @emitter.on 'did-generate-tags', fn

  getCachedTags: ->
    state.cachedTags

  generateTags: (fn) ->
    filePath = @editor.getPath()
    scopeName = @editor.getGrammar().scopeName
    cache = @getCachedTags()
    new TagGenerator(filePath, scopeName).generate().then (tags) ->
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
  direction: 'prev'

module.exports = {state, MoveToNextSymbol, MoveToPreviousSymbol}
