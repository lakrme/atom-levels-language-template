path   = require('path')

configManager = require('./config')

# ------------------------------------------------------------------------------

module.exports =

  # config: configManager.getPackageConfigurations()

  activate: ->
    # set up paths
    @configFilePath = path.join(path.dirname(__dirname),'language','config.json')

    atom.grammars.onDidAddGrammar (grammar) ->
      if grammar.scopeName is 'levels.source.dummy'
        console.log "now grammar change"
        grammar.name = 'Ruby (Levels)'
        grammar.fileTypes = ['rb']

    atom.packages.onDidActivatePackage (pkg) ->
      if pkg.name is 'levels-language-test'
        console.log "activated"
        console.log pkg

    # atom.packages.onDidActivatePackage (pkg) ->
    #   if pkg.name is 'atom-levels-language-test'
    #     console.log pkg
    #     grammar = atom.grammars.grammarForScopeName('levels.source.ruby')
    #     console.log grammar

  deactivate: ->
    @languageRegistry.removeLanguage(@language)

  ## Consumed services ---------------------------------------------------------

  consumeLevels: ({@languageRegistry}) ->
    console.log "now consume"
    @language = @languageRegistry.loadLanguage(@configFilePath)

# ------------------------------------------------------------------------------
