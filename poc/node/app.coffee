express = require 'express'
io = require 'socket.io'

app = module.exports = express()
http = require 'http'
server = http.createServer app
io = require('socket.io').listen server

app.configure ->
        app.use express.static("#{__dirname}/public")

app.configure 'development', ->
        app.use express.errorHandler({
                dumpExceptions: true
                showStack: true
                })

app.configure 'production', ->
        app.use express.errorHandler()

defaultLatency = 1000

users = []
i = 0

bgcolorlist = [ "#FF0000", "#00FF00", "#0000FF", "#FFFF00", "#FF00FF", "#00FFFF" ]
color = '#000000'
i = 0

getTime = ->
        return new Date().getTime() - 1337704000000

io.sockets.on 'connection', (socket) ->
        socket.on 'disconnect', ->
                i--

        socket.on 'getTime', (data) ->
                i++
                console.log data
                #data.id = socket.id
                #users[i] = data
                #socket.player = users[i]
                time = getTime()
                callWithRandomLatency ->
                        socket.json.emit 'setTime', { time: time, i: i, users: io.sockets.clients().length }
                , 0

        socket.on 'checkDiff', (data) ->
                latency = getTime() - data.estimatedTime
                console.log ''
                console.log 'checkDiff', data
                console.log getTime()
                console.log latency
                console.log ''

        socket.on 'changeColor', ->
                color = bgcolorlist[i++ % bgcolorlist.length]
                sendAction 'changeColor', { color: color }, defaultLatency

        socket.on 'playSound', ->
                sendAction 'playSound', { url: 'http://rb-mobile.tm.onouo.com/makinasound/sound/sac-merde.mp3' }, defaultLatency

        socket.on 'changeCombo', ->
                for l in [1..50]
                        color = bgcolorlist[i++ % bgcolorlist.length]
                        sendAction 'changeColor', { color: color }, defaultLatency + 500 * l


        socket.on 'reloadClients', ->
                sendAction 'reload', null, defaultLatency

callWithRandomLatency = (fn, latency) ->
        if true
                setTimeout fn, Math.random() * latency
        else
                fn()

sendAction = (action, args, latency) ->
        data = { action: action, args: args, time: getTime() + latency + 300 }
        io.sockets.clients().forEach (socket) ->
                data.tim2 = getTime()
                callWithRandomLatency (->
                        data.tim3 = getTime()
                        socket.json.emit 'addAction', data
                        ), latency

console.log ""
server.listen 1337

#process.on 'uncaughtException', (-> console.log 'EXIT')
#process.on 'exit', (-> console.log 'EXIT')
#process.on 'SIGTERM', (-> console.log 'EXIT')
#process.on 'SIGKILL', (-> console.log 'EXIT')
#process.on 'SIGHUP', (-> console.log 'EXIT')

console.log "Server is listening on port %d in %s mode", server.address().port, app.settings.env