(($, window, console) ->

        pluginName = 'sync'
        document = window.document
        log = () -> console.log.apply console, arguments
        defaults =
                a: 42
                b: 43

        class Sync
        	constructor: (options) ->
                        @connected = false
                        @options = $.extend {}, defaults, options
                        @socket = null
                        @keepConnection()
                        return @

                keepConnection: ->
                        that = @

                        @socket = io.connect '', @options

                        @socket.on 'connecting', ->
                                console.log 'connecting'

                        @socket.on 'connect', ->
                                that.connected = true
                                console.log 'connect'
                                @emit 'getTime'

                        @socket.on 'connect_failed', ->
                                console.log 'connect failed'

                        @socket.on 'disconnect', ->
                                that.connected = false
                                console.log 'disconnect'
                                setTimeout that.keepConnection, 1000

                        @socket.on 'setTime', (data) ->
                                socket = @
                                that.serverDiff = data.time - new Date().getTime()
                                console.log 'i', data.i
                                console.log 'users', data.users
                                console.log 'serverDiff', that.serverDiff
                                setTimeout (->
                                        estimatedServerTime = new Date().getTime() + that.serverDiff
                                        socket.emit 'checkDiff', { diff: that.serverDiff, estimatedTime: estimatedServerTime }
                                        ), Math.random() * 100


                        @socket.on 'addAction', (data) ->
                                console.log 'addAction', data
                                time = new Date().getTime()
                                estimatedServerTime = time + that.serverDiff
                                diff = data.time - estimatedServerTime
                                console.log 'diff', diff
                                console.log 'tim1', data.time
                                console.log 'tim2', data.tim2
                                console.log 'tim3', data.tim3
                                console.log 'tim0', time
                                console.log 'tim4', time + diff
                                setTimeout (->
                                        if data.action == 'changeColor'
                                                $('body').css 'background', data.args.color
                                        else if data.action == 'reload'
                                                document.location.href = document.location.href
                                        else if data.action == 'playSound'
                                                $('#sound')[0].play()
                                        ), diff

                emit: (event, hash) ->
                        if @connected
                                @socket.emit event, hash
                        else
                                console.log 'you are not connected, please wait..'

                on: (event, fn) ->
                        console.log @socket
                        @socket.on event, fn

        main = ->
                options =
                        b: 44
                        c: 45
                s = new Sync options
                $('input').click ->
                        console.log $(this).attr('data-action')
                        s.emit $(this).attr('data-action')
                return s

        $(document).ready main

)(jQuery, window, console)