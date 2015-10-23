{Emitter,Disposable} = require('atom')
path                 = require('path')
CSON                 = require('season')

# ------------------------------------------------------------------------------

module.exports =

  ## Language package settings -------------------------------------------------

  config:
    levelCodeFileTypes:
      title: 'Level Code File Types'
      description: ''
      type: 'array'
      default: []
      items:
        type: 'string'
    objectCodeFileType:
      title: 'Object Code File Type'
      description: ''
      type: 'string'
      default: ''
    lineCommentPattern:
      title: 'Line Comment Pattern'
      description: ''
      type: 'string'
      default: ''
    executionCommandPatterns:
      title: 'Execution Command Patterns'
      description: ''
      type: 'array'
      default: []
      items:
        type: 'string'

  ## Language package activation and deactivation ------------------------------

  activate: ->
    @emitter = new Emitter

    @pkgDirPath = path.dirname(__dirname)
    pkgMetadataFilePath = CSON.resolve(path.join(@pkgDirPath,'package'))
    @pkgMetadata = CSON.readFileSync(pkgMetadataFilePath)

    @configFilePath = @getConfigFilePath()
    @executablePath = @getExecutablePath()

    pkgSubscr = atom.packages.onDidActivatePackage (pkg) =>
      if pkg.name is @pkgMetadata.name
        @dummyGrammar = pkg.grammars[0]
        atom.grammars.removeGrammar(@dummyGrammar)
        @startUsingLevels() if @levelsIsActive
        @onDidActivateLevels => @startUsingLevels()
        @onDidDeactivateLevels => @stopUsingLevels()
        pkgSubscr.dispose()

  deactivate: ->
    @languageRegistry.removeLanguage(@language) if @levelsIsActive

  ## Activation helpers --------------------------------------------------------

  getConfigFilePath: ->
    CSON.resolve(path.join(@pkgDirPath,'language','config'))

  getExecutablePath: ->
    executableDirPath = path.join(@pkgDirPath,'language','executable')
    switch process.platform
      when 'darwin' then path.join(executableDirPath,'darwin','run')
      when 'linux'  then path.join(executableDirPath,'linux','run')
      when 'win32'  then path.join(executableDirPath,'win32','run.exe')

  ## Interacting with the Levels package ---------------------------------------

  onDidActivateLevels: (callback) ->
    @emitter.on('did-activate-levels',callback)

  onDidDeactivateLevels: (callback) ->
    @emitter.on('did-deactivate-levels',callback)

  consumeLevels: ({@languageRegistry}) ->
    @levelsIsActive = true
    @emitter.emit('did-activate-levels')
    new Disposable =>
      @levelsIsActive = false
      @emitter.emit('did-deactivate-levels')

  startUsingLevels: ->
    unless @language?
      @language = @languageRegistry.readLanguageSync\
        (@configFilePath,@executablePath)
      @dummyGrammar.name = @language.getGrammarName()
      @dummyGrammar.scopeName = @language.getScopeName()
      @dummyGrammar.fileTypes = @language.getLevelCodeFileTypes()
      @language.setDummyGrammar(@dummyGrammar)
      @initializeLanguageSettings()
    atom.grammars.addGrammar(@dummyGrammar)
    @languageRegistry.addLanguage(@language)

  stopUsingLevels: ->
    atom.grammars.removeGrammar(@dummyGrammar)

  ## Language configuration management -----------------------------------------

  initializeLanguageSettings: ->
    pkgName = @pkgMetadata.name
    atom.config.set "#{pkgName}.levelCodeFileTypes", \
      @language.getLevelCodeFileTypes()
    atom.config.onDidChange "#{pkgName}.levelCodeFileTypes", ({newValue}) =>
      @language.setLevelCodeFileTypes(newValue)
    atom.config.set "#{pkgName}.objectCodeFileType", \
      @language.getObjectCodeFileType()
    atom.config.onDidChange "#{pkgName}.objectCodeFileType", ({newValue}) =>
      @language.setObjectCodeFileType(newValue)
    atom.config.set "#{pkgName}.lineCommentPattern", \
      @language.getLineCommentPattern()
    atom.config.onDidChange "#{pkgName}.lineCommentPattern", ({newValue}) =>
      @language.setLineCommentPattern(newValue)

# ------------------------------------------------------------------------------
