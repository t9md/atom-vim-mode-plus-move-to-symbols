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

  consumeVim(service) {
    const commands = require("./move-to-symbols")(service, CACHED_TAG)
    for (const command of Object.values(commands)) {
      command.commandPrefix = "vim-mode-plus-user"
      this.subscriptions.add(command.registerCommand())
    }

    this.subscriptions.add(
      atom.workspace.observeTextEditors(editor => {
        this.subscriptions.add(editor.onDidSave(() => delete CACHED_TAG[editor.getPath()]))
      })
    )
  },
}
