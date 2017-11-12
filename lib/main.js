const {CompositeDisposable} = require("atom")

let CACHED_TAG

module.exports = {
  activate() {
    CACHED_TAG = {}
    this.subscriptions = new CompositeDisposable()
  },

  deactivate() {
    this.subscriptions.dispose()
    CACHED_TAG = null
  },

  consumeVim({Base, registerCommandFromSpec}) {
    let vimCommands

    const spec = {
      prefix: "vim-mode-plus-user",
      getClass(name) {
        if (!vimCommands) vimCommands = require("./move-to-symbols")(Base, CACHED_TAG)
        return vimCommands[name]
      },
    }

    this.subscriptions.add(
      registerCommandFromSpec("MoveToNextSymbol", spec),
      registerCommandFromSpec("MoveToPreviousSymbol", spec),
      atom.workspace.observeTextEditors(editor => {
        this.subscriptions.add(editor.onDidSave(() => delete CACHED_TAG[editor.getPath()]))
      })
    )
  },
}
