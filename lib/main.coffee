# ------------------------------------------------------------------------------

module.exports =

  activate: (state) ->
    path = require "path"
    console.log path.dirname(__dirname)

  deactivate: ->

  serialize: ->

  ## Consumed services ---------------------------------------------------------

  consumeLevels: (levels) ->
    path = require "path"
    console.log levels
    configFilePath = path.join(path.dirname(__dirname),'config.json')
    levels.languageRegistry.loadLanguage(configFilePath)

# ------------------------------------------------------------------------------
