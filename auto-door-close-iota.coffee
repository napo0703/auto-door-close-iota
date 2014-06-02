process.env.LINDA_BASE  ||= 'http://node-linda-base.herokuapp.com'
process.env.LINDA_SPACE ||= 'iota'

console.log "auto-door-close"

LindaClient = require('linda-socket.io').Client
socket = require('socket.io-client').connect(process.env.LINDA_BASE)
linda = new LindaClient().connect(socket)
ts = linda.tuplespace(process.env.LINDA_SPACE)

linda.io.on 'connect', ->
  console.log "socket.io connect!! <#{process.env.LINDA_BASE}/#{ts.name}>"
  last_value = null
  ts.watch {type: "sensor", name: "light"}, (err, tuple) ->
    return if err
    return if tuple.data.value < 0 or tuple.data.value > 1023  # ˆÙí’l
    if last_value != null and Date.now()
      if tuple.data.value < last_value
        if last_value / (tuple.data.value+1) > 3
          console.log "#{last_value} -> #{tuple.data.value}"
          setTimeout ->
            ts.write {type: "door", cmd: "close"}
          , 10000
          console.log "auto door close!!"
    last_value = tuple.data.value

linda.io.on 'disconnect', ->
  console.log 'socket.io disoconnect..'
