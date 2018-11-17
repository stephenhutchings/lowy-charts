Application =
  initialize: ->
    MainView = require("views/main")
    new MainView(el: "body")

module.exports = Application
