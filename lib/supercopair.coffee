#atom-supercollider
Controller = require './controller'

module.exports =
#atom-supercollider
  controller: null
  configDefaults:
    classicRepl: true
    growlOnError: false



#atom-pair
  config:
    hipchat_token:
      type: 'string'
      description: 'HipChat admin token (optional)'
      default: ''
    hipchat_room_name:
      type: 'string'
      description: 'HipChat room name for sending invitations (optional)'
      default: ''
    pusher_app_key:
      type: 'string'
      description: 'Pusher App Key (sign up at http://pusher.com/signup and change for added security)'
      default: 'd41a439c438a100756f5'
    pusher_app_secret:
      type: 'string'
      description: 'Pusher App Secret'
      default: '4bf35003e819bb138249'
    broadcast_bypass:
      type: 'boolean'
      description: 'Set true if you want to be asked before evaluating external code'
      default: false

  activate: (state) ->
  #atom-supercollider
    @controller = new Controller(
      atom.workspaceView,
      atom.project.getRootDirectory())
    @controller.start()

  deactivate: ->
    @controller.stop()

  serialize: ->
    {}
