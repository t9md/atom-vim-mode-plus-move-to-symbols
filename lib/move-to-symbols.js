function requireFrom(pack, path) {
  const packPath = atom.packages.resolvePackagePath(pack)
  return require(`${packPath}/${path}`)
}

const TagGenerator = requireFrom("symbols-view", "lib/tag-generator")

module.exports = function loadVmpCommands(service, CACHED_TAG) {
  class MoveToNextSymbol extends service.getClass("Motion") {
    constructor(...args) {
      super(...args)
      this.requireInput = true
      this.direction = "next"
    }

    initialize() {
      this.prepareTags()
      return super.initialize()
    }

    prepareTags() {
      const filePath = this.editor.getPath()
      if (filePath in CACHED_TAG) {
        this.input = CACHED_TAG[filePath]
      } else {
        const {scopeName} = this.editor.getGrammar()
        new TagGenerator(filePath, scopeName).generate().then(tags => {
          this.input = CACHED_TAG[filePath] = tags
          this.processOperation()
        })
      }
    }

    findTag(cursor) {
      const cursorRow = cursor.getBufferRow()
      const tags = this.input.slice()

      if (this.direction === "next") {
        return tags.find(tag => tag.position.row > cursorRow)
      } else if (this.direction === "previous") {
        tags.reverse()
        return tags.find(tag => tag.position.row < cursorRow)
      }
    }

    moveCursor(cursor) {
      this.moveCursorCountTimes(cursor, () => {
        const tag = this.findTag(cursor)
        if (tag) {
          cursor.setBufferPosition(tag.position)
          cursor.moveToFirstCharacterOfLine()
        }
      })
    }
  }

  class MoveToPreviousSymbol extends MoveToNextSymbol {
    constructor(...args) {
      super(...args)
      this.direction = "previous"
    }
  }

  return {MoveToNextSymbol, MoveToPreviousSymbol}
}
