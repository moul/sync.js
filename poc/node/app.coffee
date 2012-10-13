express = require 'express'
app = module.exports = do express
http = require 'http'
server = http.createServer app
io = require('socket.io').listen server

app.configure ->
        app.use express.static "#{__dirname}/public"

app.configure 'development', ->
        app.use express.errorHandler
                dumpExceptions: true
                showStack: true

app.configure 'production', ->
        app.use do express.errorHandler

defaultLatency = 1000
users = []
bgcolorlist = [ "#FF0000", "#00FF00", "#0000FF", "#FFFF00", "#FF00FF", "#00FFFF" ]
color = '#000000'
i = 0

getTime = -> new Date().getTime() - 1337817342

io.sockets.on 'connection', (socket) ->
        socket.on 'disconnect', -> i--

        socket.on 'getTime', (data) ->
                i++
                console.log data
                time = getTime()
                callWithRandomLatency -> (socket.json.emit 'setTime', { time: time, i: i, users: io.sockets.clients().length }), 0

        socket.on 'checkDiff', (data) ->
                latency = do getTime - data.estimatedTime
                console.log ''
                console.log 'checkDiff', data
                console.log do getTime
                console.log latency
                console.log ''

        socket.on 'changeColor', ->
                color = bgcolorlist[i++ % bgcolorlist.length]
                sendAction 'changeColor', { color: color }, defaultLatency

        socket.on 'playSound', ->
                sendAction 'playSound', { url: null }, defaultLatency

        socket.on 'changeCombo', ->
                for l in [1..50]
                        color = bgcolorlist[i++ % bgcolorlist.length]
                        sendAction 'changeColor', { color: color }, defaultLatency + 500 * l


        socket.on 'reloadClients', ->
                sendAction 'reload', null, defaultLatency

callWithRandomLatency = (fn, latency) ->
        if true
                setTimeout fn, do Math.random * latency
        else
                do fn

sendAction = (action, args, latency) ->
        data = { action: action, args: args, time: do getTime + latency + 300 }
        io.sockets.clients().forEach (socket) ->
                data.tim2 = do getTime
                callWithRandomLatency (->
                        data.tim3 = do getTime
                        socket.json.emit 'addAction', data
                        ), latency

console.log ""
server.listen 1337

process.on 'uncaughtException', (-> console.log 'EXIT')
process.on 'exit', (-> console.log 'EXIT')
process.on 'SIGTERM', (-> console.log 'EXIT')
process.on 'SIGKILL', (-> console.log 'EXIT')
process.on 'SIGHUP', (-> console.log 'EXIT')

console.log "Server is listening on port %d in %s mode", server.address().port, app.settings.env