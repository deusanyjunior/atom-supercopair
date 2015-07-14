#atom-supercollider
Controller = require './controller'

module.exports = SuperCopair =
  controller: null
  config:
    growlOnError:
      type: 'boolean'
      default: false
    debug:
      type: 'boolean'
      default: false

#atom-pair
  config:
    hipchat_token:
      type: 'string'
      description: 'HipChat admin token (optional)'
      default: 'null'
    hipchat_room_name:
      type: 'string'
      description: 'HipChat room name for sending invitations (optional)'
      default: 'null'
    pusher_app_key:
      type: 'string'
      description: 'Pusher App Key (sign up at http://pusher.com/signup and change for added security)'
      default: 'd41a439c438a100756f5'
    pusher_app_secret:
      type: 'string'
      description: 'Pusher App Secret'
      default: '4bf35003e819bb138249'
    disable_broadcast:
      type: 'boolean'
      description: 'Select if you do not want to receive any external evaluation'
      default: false

#atom-supercollider
  activate: (state) ->
    if @controller
      return
    @controller = new Controller(atom.project.getDirectories()[0])
    @controller.start()

  deactivate: ->
    @controller.stop()
    @controller = null

  serialize: ->
    {}
