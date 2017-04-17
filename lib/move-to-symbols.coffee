requireFrom = (pack, path) ->
  packPath = atom.packages.resolvePackagePath(pack)
  require "#{packPath}/lib/#{path}"

{Emitter, Point} = require 'atom'
_ = require 'underscore-plus'

TagGenerator = requireFrom('symbols-view', 'tag-generator')
Base = requireFrom('vim-mode-plus', 'base')
Motion = Base.getClass('Motion')

cachedTag = {}

class MoveToNextSymbol extends Motion
  direction: 'next'
  requireInput: true

  initialize: ->
    @emitter = new Emitter
    @getTags()

  onDidGenerateTags: (fn) ->
    @emitter.on 'did-generate-tags', fn

  getTags: ->
    filePath = @editor.getPath()
    tags = cachedTag[filePath]?.slice()
    if tags?
      @input = tags
    else
      scopeName = @editor.getGrammar().scopeName
      new TagGenerator(filePath, scopeName).generate().then (tags) =>
        cachedTag[filePath] = tags
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
    @moveCursorCountTimes cursor, =>
      if (tag = @detectRow(cursor))?
        cursor.setBufferPosition(tag.position)
        cursor.moveToFirstCharacterOfLine()

class MoveToPreviousSymbol extends MoveToNextSymbol
  direction: 'prev'

module.exports = {cachedTag, MoveToNextSymbol, MoveToPreviousSymbol}
