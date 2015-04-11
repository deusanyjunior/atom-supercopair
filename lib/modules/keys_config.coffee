_ = require 'underscore'

module.exports = SuperCopairConfig =

  getKeysFromConfig: ->
    @app_key = atom.config.get('supercopair.pusher_app_key')
    @app_secret = atom.config.get('supercopair.pusher_app_secret')
    @hc_key = atom.config.get('supercopair.hipchat_token')
    @room_name = atom.config.get('supercopair.hipchat_room_name')

  missingPusherKeys: -> _.any([@app_key, @app_secret], @missing)
  missingHipChatKeys: -> _.any([@hc_key, @room_name], @missing)
  missing: (key) -> key is '' || typeof(key) is "undefined"
