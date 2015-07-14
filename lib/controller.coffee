#atom-supercollider
url = require('url')
Repl = require('./repl')
## {$, Range} = require 'atom'
{$, Range} = require 'atom-space-pen-views'

#atom-pair
StartView = require './views/start-view'
InputView = require './views/input-view'
AlertView = require './views/alert-view'

require './pusher/pusher'
require './pusher/pusher-js-client-auth'

randomstring = require 'randomstring'
_ = require 'underscore'
chunkString = require './helpers/chunk-string'

HipChatInvite = require './modules/hipchat_invite'
Marker = require './modules/marker'
GrammarSync = require './modules/grammar_sync'
SuperCopairConfig = require './modules/keys_config'

{CompositeDisposable, Range} = require 'atom'


module.exports =
class Controller

#atom-pair
  SuperCopairView: null
  modalPanel: null
  subscriptions: null

  constructor: (directory) ->
  #atom-supercollider
    @defaultURI = "sclang://localhost:57120"
    @projectRoot = if directory then directory.path else ''
    @repls = {}
    @activeRepl = null
    @markers = []

  start: ->
  #atom-pair
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable
    @editorListeners = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'supercopair:start-new-pairing-session': => @startSession()
    @subscriptions.add atom.commands.add 'atom-workspace', 'supercopair:join-pairing-session': => @joinSession()
    @subscriptions.add atom.commands.add 'atom-workspace', 'supercopair:set-configuration-keys': => @setConfig()
    @subscriptions.add atom.commands.add 'atom-workspace', 'supercopair:invite-over-hipchat': => @inviteOverHipChat()
    @subscriptions.add atom.commands.add 'atom-workspace', 'supercopair:custom-paste': => @customPaste()

    atom.commands.add 'atom-workspace', 'supercopair:hide-views': => @hidePanel()
    atom.commands.add '.session-id', 'supercopair:copyid': => @copyId()

    @colours = require('./helpers/colour-list')
    @friendColours = []
    @timeouts = []
    @events = []
    _.extend(@, HipChatInvite, Marker, GrammarSync, SuperCopairConfig)

  #atom-supercopair
    @subscriptions.add atom.commands.add 'atom-workspace', "supercopair:broadcast-eval", => @broadcastEval(false)
    @subscriptions.add atom.commands.add 'atom-workspace', "supercopair:broadcast-cmd-period", => @broadcastCmdPeriod(false)
    @subscriptions.add atom.commands.add 'atom-workspace', "supercopair:broadcast-eval-exclusively", => @broadcastEval(true)
    @subscriptions.add atom.commands.add 'atom-workspace', "supercopair:broadcast-cmd-period-exclusively", => @broadcastCmdPeriod(true)

  #atom-supercollider
    @subscriptions.add atom.commands.add 'atom-workspace', "supercopair:open-post-window", => @openPostWindow(@defaultURI)
    @subscriptions.add atom.commands.add 'atom-workspace', "supercopair:clear-post-window", => @clearPostWindow()
    @subscriptions.add atom.commands.add 'atom-workspace', "supercopair:recompile", => @recompile()
    @subscriptions.add atom.commands.add 'atom-workspace', "supercopair:cmd-period", => @cmdPeriod()
    @subscriptions.add atom.commands.add 'atom-workspace', "supercopair:eval", => @eval()
    @subscriptions.add atom.commands.add 'atom-workspace', "supercopair:open-help-file", => @openHelpFile()

    # open a REPL for sclang on this host/port
    atom.workspace.addOpener (uri, options) =>
      try
        {protocol, hostname, port} = url.parse(uri)
      catch error
        return
      return unless protocol is 'sclang:'

      onClose = =>
        if @activeRepl is repl
          @destroyRepl()
        delete @repls[uri]

      repl = new Repl(uri, @projectRoot, onClose)
      @activateRepl repl
      @repls[uri] = repl
      window = repl.createPostWindow()
      repl.startSCLang()
      window


#atom-supercollider
  stop: ->
    for repl in @repls
      repl.stop()
    @destroyRepl()
    @repls = {}

  activateRepl: (repl) ->
    @activeRepl = repl
    @activeRepl.unsubscriber = repl.emit.subscribe (event) =>
      @handleReplEvent(event)

  destroyRepl: () ->
    @activeRepl?.unsubscriber()
    @activeRepl = null

  handleReplEvent: (event) ->
    error = event.value()
    # only expecting compile errors for now
    if error.index == 0
      @openToSyntaxError(error.file, error.line, error.char)

  openPostWindow: (uri) ->
    repl = @repls[uri]

    if repl
      @activateRepl repl
    else
      # open links on click
      fileOpener = (event) =>

        # A or child of A
        link = event.target.href
        unless link
          link = $(event.target).parents('a').attr('href')

        return unless link

        event.preventDefault()

        if link.substr(0, 7) == 'file://'
          path = link.substr(7)
          atom.workspace.open(path, split: 'left', searchAllPanes: true)
          return

        if link.substr(0, 10) == 'scclass://'
          link = link.substr(10)
          [path, charPos] = link.split(':')
          if ',' in charPos
            [lineno, char] = charPos.split(',')
            @openFile(
              path,
              null,
              parseInt(lineno),
              parseInt(char),
              'line',
              'line-highlight')
          else
            @openFile(
              path,
              parseInt(charPos),
              null,
              null,
              'line',
              'line-highlight')

      options =
        split: 'right'
        searchAllPanes: true
      atom.workspace.open(uri, options)
        .then () =>
          @activateRepl @repls[uri]
          $('.post-window').on 'click', fileOpener

  clearPostWindow: ->
    @activeRepl?.clearPostWindow()

  recompile: ->
    @destroyMarkers()
    if @activeRepl
      @activeRepl.recompile()
    else
      @openPostWindow(@defaultURI)

  cmdPeriod: ->
    @activeRepl?.cmdPeriod()

  editorIsSC: ->
    editor = atom.workspace.getActiveTextEditor()
    editor and editor.getGrammar().scopeName is 'source.supercollider'

  currentExpression: ->
    editor = atom.workspace.getActiveTextEditor()
    return unless editor?

    selection = editor.getLastSelection()
    expression = selection.getText()
    if expression
      range = selection.getBufferRange()
    else
      # execute the line you are on
      pos = editor.getCursorBufferPosition()
      row = editor.getCursorScreenPosition().row
      if row?
        range = new Range([row, 0], [row + 1, 0])
        expression = editor.lineTextForBufferRow(row)
      else
        range = null
        expression = null
    [expression, range]

  currentPath: ->
    editor = atom.workspace.getActiveTextEditor()
    return unless editor?
    editor.getPath()

  eval: ->
    return unless @editorIsSC()
    [expression, range] = @currentExpression()
    @evalWithRepl(expression, @currentPath(), range)

  evalWithRepl: (expression, path, range) ->
    @destroyMarkers()

    return unless expression

    doIt = () =>
      if range?
        unflash = @evalFlash(range)

      onSuccess = () ->
        unflash?('eval-success')

      onError = (error) =>
        if error.type is 'SyntaxError'
          unflash?('eval-syntax-error')
          if path
            # offset syntax error by position of selected text in file
            row = range.getRows()[0] + error.error.line
            col = error.error.charPos
            @openToSyntaxError(path, parseInt(row), parseInt(col))
        else
          # runtime error
          unflash?('eval-error')

      @activeRepl.eval(expression, false, path)
        .then(onSuccess, onError)

    if @activeRepl
      # if stuck in compile error
      # then post warning and return
      unless @activeRepl.isCompiled()
        @activeRepl.warnIsNotCompiled()
        return
      doIt()
    else
      @openPostWindow(@defaultURI)
        .then doIt

  openToSyntaxError: (path, line, char) ->
    @openFile(path, null, line, char)

  openHelpFile: ->
    unless @editorIsSC()
      return false
    [expression, range] = @currentExpression()

    base = null

    # Klass.openHelpFile
    klassy = /^([A-Z]{1}[a-zA-Z0-9\_]*)$/
    match = expression.match(klassy)
    if match
      base = expression
    else
      # 'someMethod'.openHelpFile
      # starts with lowercase has no punctuation, wrap in ''
      # TODO match ops
      methody = /^([a-z]{1}[a-zA-Z0-9\_]*)$/
      match = expression.match(methody)
      if match
        base = "'#{expression}'"
      else
        # anything else just do a search
        stringy = /^([^"]+)$/
        match = expression.match(stringy)
        if match
          base = '"' + expression + '"'

    if base
      @evalWithRepl("#{base}.openHelpFile")

  openFile: (uri, charPos, row, col, markerType="line", cssClass="line-error")->
    options =
      initialLine: row
      initialColumn: col
      split: 'left'
      activatePane: false
      searchAllPanes: true

    atom.workspace.open(uri, options)
      .then (editor) =>
        setMark = (point) =>
          editor.setCursorBufferPosition(point)
          expression = editor.lineForBufferRow(point[0])
          range = [point, [point[0], expression.length - 1]]
          @destroyMarkers()

          marker = editor.markBufferRange(range, invalidate: 'touch')
          decoration = editor.decorateMarker(marker,
            type: markerType,
            class: cssClass)
          @markers.push marker

        if row?
          # mark is zero indexed
          return setMark([row - 1, col])

        text = editor.getText()
        cursor = 0
        li = 0
        for ll in text.split('\n')
          cursor += (ll.length + 1)
          if cursor > charPos
            return setMark([li, cursor - charPos - ll.length])
          li += 1

  destroyMarkers: () ->
    @markers.forEach (m) ->
      m.destroy()
    @markers = []

  evalFlash: (range) ->
    editor = atom.workspace.getActiveTextEditor()
    if editor
      marker = editor.markBufferRange(range, invalidate: 'touch')
      decoration = editor.decorateMarker(marker,
                      type: 'line',
                      class: "eval-flash")
      # return fn to flash error/success and destroy the flash
      (cssClass) ->
        decoration.update(type: 'line', class: cssClass)
        destroy = ->
          marker.destroy()
        setTimeout(destroy, 100)


#atom-pair
  customPaste: ->
    text = atom.clipboard.read()
    if text.length > 800
      chunks = chunkString(text, 800)
      _.each chunks, (chunk, index) =>
        setTimeout(( =>
          atom.clipboard.write(chunk)
          @editor.pasteText()
          if index is (chunks.length - 1) then atom.clipboard.write(text)
        ), 180 * index)
    else
      @editor.pasteText()

  disconnect: ->
    @pusher.disconnect()
    @editorListeners.dispose()
    _.each @friendColours, (colour) => @clearMarkers(colour)
    @clearMarkers(@markerColour)
    @markerColour = null
    atom.views.getView(@editor).removeAttribute('id')
    @hidePanel()

  copyId: ->
    atom.clipboard.write(@sessionId)
    @startPanel.hide()

  hidePanel: ->
    _.each atom.workspace.getModalPanels(), (panel) -> panel.hide()

  joinSession: ->

    if @markerColour
      alreadyPairing = new AlertView "It looks like you are already in a pairing session. Please open a new window (cmd+shift+N) to start/join a new one."
      atom.workspace.addModalPanel(item: alreadyPairing, visible: true)
      return

    @joinView = new InputView("Enter the session ID here:")
    @joinPanel = atom.workspace.addModalPanel(item: @joinView, visible: true)
    @joinView.miniEditor.focus()

    @joinView.on 'core:confirm', =>
      @sessionId = @joinView.miniEditor.getText()
      keys = @sessionId.split("-")
      [@app_key, @app_secret] = [keys[0], keys[1]]
      @joinPanel.hide()

      atom.workspace.open().then => @pairingSetup() #starts a new tab to join pairing session

  startSession: ->
    @getKeysFromConfig()

    if @missingPusherKeys()
      alertView = new AlertView "Please set your Pusher keys."
      atom.workspace.addModalPanel(item: alertView, visible: true)
    else
      if @markerColour
        alreadyPairing = new AlertView "It looks like you are already in a pairing session. Please disconnect or open a new window to start/join a new one."
        atom.workspace.addModalPanel(item: alreadyPairing, visible: true)
        return
      @generateSessionId()
      @startView = new StartView(@sessionId)
      @startPanel = atom.workspace.addModalPanel(item: @startView, visible: true)
      @startView.focus()
      @markerColour = @colours[0]
      @pairingSetup()
      @activeRepl?.postMessage('SuperCopair: Session started!')

  generateSessionId: ->
    @sessionId = "#{@app_key}-#{@app_secret}-#{randomstring.generate(11)}"

  pairingSetup: ->
    @editor = atom.workspace.getActiveTextEditor()
    if !@editor then return atom.workspace.open().then => @pairingSetup()
    atom.views.getView(@editor).setAttribute('id', 'SuperCopair')
    @connectToPusher()
    @synchronizeColours()
    @subscriptions.add atom.commands.add 'atom-workspace', 'SuperCopair:disconnect': => @disconnect()

  connectToPusher: ->
    @pusher = new Pusher @app_key,
      authTransport: 'client'
      clientAuth:
        key: @app_key
        secret: @app_secret
        user_id: @markerColour || "blank"

    @pairingChannel = @pusher.subscribe("presence-session-#{@sessionId}")

  synchronizeColours: ->
    @pairingChannel.bind 'pusher:subscription_succeeded', (members) =>
      @membersCount = members.count
      return @resubscribe() unless @markerColour
      colours = Object.keys(members.members)
      @friendColours = _.without(colours, @markerColour)
      _.each(@friendColours, (colour) => @addMarker 0, colour)
      @startPairing()

  resubscribe: ->
    @pairingChannel.unsubscribe()
    @markerColour = @colours[@membersCount - 1]
    @connectToPusher()
    @synchronizeColours()

  startPairing: ->

    @triggerPush = true
    buffer = @buffer = @editor.buffer

    # listening for Pusher events

    @pairingChannel.bind 'pusher:member_added', (member) =>
      noticeView = new AlertView "Your pair buddy has joined the session."
      atom.workspace.addModalPanel(item: noticeView, visible: true)
      @sendGrammar()
      @shareCurrentFile()
      @friendColours.push(member.id)
      @addMarker 0, member.id

    @pairingChannel.bind 'client-grammar-sync', (syntax) =>
      grammar = atom.grammars.grammarForScopeName(syntax)
      @editor.setGrammar(grammar)

    @pairingChannel.bind 'client-share-whole-file', (file) =>
      @triggerPush = false
      buffer.setText(file)
      @triggerPush = true

    @pairingChannel.bind 'client-share-partial-file', (chunk) =>
      @triggerPush = false
      buffer.append(chunk)
      @triggerPush = true

    @pairingChannel.bind 'client-change', (events) =>
      _.each events, (event) =>
        @changeBuffer(event) if event.eventType is 'buffer-change'
        if event.eventType is 'buffer-selection'
          @updateCollaboratorMarker(event)
#atom-supercopair
        if event.eventType is 'broadcast-event'
          @pairEval(event)

    @pairingChannel.bind 'pusher:member_removed', (member) =>
      @clearMarkers(member.id)
      disconnectView = new AlertView "Your pair buddy has left the session."
      atom.workspace.addModalPanel(item: disconnectView, visible: true)

    @triggerEventQueue()

    # listening for buffer events
    @editorListeners.add @listenToBufferChanges()
    @editorListeners.add @syncSelectionRange()
    @editorListeners.add @syncGrammars()

    # listening for its own demise
    @listenForDestruction()

  listenForDestruction: ->
    @editorListeners.add @buffer.onDidDestroy => @disconnect()
    @editorListeners.add @editor.onDidDestroy => @disconnect()

  listenToBufferChanges: ->
    @buffer.onDidChange (event) =>
      return unless @triggerPush
      if !(event.newText is "\n") and (event.newText.length is 0)
        changeType = 'deletion'
        event = {oldRange: event.oldRange}
      else if event.oldRange.containsRange(event.newRange)
        changeType = 'substitution'
        event = {oldRange: event.oldRange, newRange: event.newRange, newText: event.newText}
      else
        changeType = 'insertion'
        event  = {newRange: event.newRange, newText: event.newText}

      event = {changeType: changeType, event: event, colour: @markerColour, eventType: 'buffer-change'}
      @events.push(event)

  changeBuffer: (data) ->
    if data.event.newRange then newRange = Range.fromObject(data.event.newRange)
    if data.event.oldRange then oldRange = Range.fromObject(data.event.oldRange)
    if data.event.newText then newText = data.event.newText

    @triggerPush = false

    @clearMarkers(data.colour)

    switch data.changeType
      when 'deletion'
        @buffer.delete oldRange
        actionArea = oldRange.start
      when 'substitution'
        @buffer.setTextInRange oldRange, newText
        actionArea = oldRange.start
      else
        @buffer.insert newRange.start, newText
        actionArea = newRange.start

    #@editor.scrollToBufferPosition(actionArea)
    @addMarker(actionArea.toArray()[0], data.colour)

    @triggerPush = true

  syncSelectionRange: ->
    @editor.onDidChangeSelectionRange (event) =>
      rows = event.newBufferRange.getRows()
      return unless rows.length > 1
      @events.push {eventType: 'buffer-selection', colour: @markerColour, rows: rows}

  triggerEventQueue: ->
    @eventInterval = setInterval(=>
      if @events.length > 0
        @pairingChannel.trigger 'client-change', @events
        @events = []
    , 120)

  shareCurrentFile: ->
    currentFile = @buffer.getText()
    return if currentFile.length is 0

    if currentFile.length < 950
      @pairingChannel.trigger 'client-share-whole-file', currentFile
    else
      chunks = chunkString(currentFile, 950)
      _.each chunks, (chunk, index) =>
        setTimeout(( => @pairingChannel.trigger 'client-share-partial-file', chunk), 180 * index)



#atom-supercopair
  broadcastEval: (exclusively) -> #broadcast evaluation exclusively or not
    return unless @editorIsSC()
    [expression, range] = @currentExpression()
    changeType = 'evaluation'
    event  = {newRange: range, newExpression: expression}

    event = {changeType: changeType, event: event, colour: @markerColour, eventType: 'broadcast-event'}
    @events.push(event)
    @activeRepl?.postMessage("You had broadcast: \n"+expression)
    if not exclusively
      @eval()


  broadcastCmdPeriod: (exclusively) -> #broadcast command+period exclusively or not
    changeType = 'cmd-period'
    event  = {}

    event = {changeType: changeType, event: event, colour: @markerColour, eventType: 'broadcast-event'}
    @events.push(event)
    if not exclusively
      @activeRepl?.cmdPeriod()
      @activeRepl?.postMessage("You had broadcast: Stop!")

  pairEval: (data) -> #pair evaluation
    if data.event.newRange then newRange = Range.fromObject(data.event.newRange)
    if data.event.newExpression then newExpression = data.event.newExpression
    if data.colour then buddyColour = data.colour

    if atom.config.get('supercopair.disable_broadcast')
      return
    if atom.config.get('supercopair.broadcast_bypass')
      if not confirm("Your "+buddyColour+" buddy wants to evaluate:\n"+newExpression)
        return;

    switch data.changeType
      when 'evaluation'
        @evalWithRepl(newExpression, @currentPath(), newRange)
        @activeRepl?.postMessage("Your "+buddyColour+" buddy evaluated: \n"+newExpression)
        # noticeView = new AlertView "Your "+buddyColour+" buddy evaluated: \n"+newExpression
        # atom.workspace.addModalPanel(item: noticeView, visible: true)
      when 'cmd-period'
        @activeRepl?.cmdPeriod()
        @activeRepl?.postMessage("Your "+buddyColour+" buddy evaluated: Stop!")
        # noticeView = new AlertView "Your "+buddyColour+" buddy evaluated: Stop!"
        # atom.workspace.addModalPanel(item: noticeView, visible: true)
      else
        ;
