Robot   = require('hubot').Robot
Adapter = require('hubot').Adapter
TextMessage = require('hubot').TextMessage
HTTPS = require 'https'
SocketIO = require('socket.io-client')

class Hubrooms extends Adapter

  send: (envelope, strings...) ->
    console.log "---------- send -----------"
    console.log envelope
    console.log strings
    console.log "-------- end send ---------"

  reply: (envelope, strings...) ->
    console.log "--------- reply -----------"
    console.log envelope
    console.log strings
    user = if envelope.user then envelope.user else envelope
    for str in strings
      @send envelope, "@#{user.mention_name} #{str}"
    console.log "------- end reply ---------"

  run: ->
    self = @
    options =
      query: 'login=tedkulp&apikey=123456'

    process.on 'uncaughtException', (err) =>
      @robot.logger.error err.stack

    socket = SocketIO.connect 'http://localhost:3000', options

    socket.on 'connect_failed', ->
      console.log 'connect failed'

    socket.on 'error', (error) ->
      console.log 'error'
      console.log error

    socket.on 'connect', (data) =>
      self.emit "connected"
      console.log "Connected to Hubrooms!"

      socket.on 'new-message', (data) =>
        user = self.robot.brain.userForId data.user_id, name: data.login, room: data.channel_id
        tm = new TextMessage(user, data.msg, data._id)
        console.log "12345", tm instanceof TextMessage
        self.receive tm

      # socket.on 'active-user', (data) ->
      #   console.log data

      # socket.on 'inactive-user', (data) ->
      #   console.log data

      socket.on 'disconnect', () ->
        console.log 'disconnected'

exports.use = (robot) ->
  new Hubrooms robot