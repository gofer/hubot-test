# Description:
#   Utility commands surrounding Hubot uptime.
#
# Commands:
#   hubot - Greeting
#   hubot wow - Say '因果WOWWOWって奴ですね'
#   hubot conv - Converstion debug

Conversation        = require 'hubot-conversation'
MattermostFormatter = require '../lib/mattermost_formatter'

module.exports = (robot) ->
  conversation = new Conversation robot
  
  orginal_receive = robot.receive
  robot.receive = (msg) ->
    switch (msg.constructor.name)
      when 'TextMessage'
        console.log('TextMessage', msg.text)
        msg.text = msg.text.replace(/^hubot /, '')
      when 'CatchAllMessage'
        console.log('CatchAllMessage', msg.message.text)
        msg.message.text = msg.message.text.replace(/^hubot /, '')
      else
        throw new Error('Unknown message type')
    
    orginal_receive.bind(robot)(msg)
  
  robot.hear /^(hubot )?heybot$/i, (res) ->
    # console.log(res)
    res.send "Yes, I'm bot!"

  robot.hear /^heybot wow$/i, (res) ->
    res.reply '因果WOWWOWって奴ですね'

  robot.hear /^heybot conv ?(.*)$/, (res) ->
    # Lexer = require '../lib/string_lexer'
    # console.log(Lexer.split_by_space res.match[1])
    
    res.reply 'Are you okay?'
    
    dialog = conversation.startDialog(res)
    dialog.addChoice /^(.+)$/, (res2) ->
      res2.reply 'I know you say "' + res2.match[1] + '"'
  
  robot.hear /^heybot time/i, (res) ->
    moment = require 'moment-timezone'
    moment.locale('ja-JP')
    DateFormat = 'YYYY/MM/DD(ddd) HH:mm:ss (z)'
    
    timezone = process.env.TZ ? 'UTC'
    current_datetime = moment(new Date()).tz(timezone).format(DateFormat)
    
    response = '現在の時刻: ' + current_datetime
    if process.env.TZ
      response += ', ENV[\'TZ\'] = ' + process.env.TZ
    
    res.send response

  robot.hear /^heybot calc (.*)$/i, (res) ->
    ret = null
    do_eval = (s) -> eval('function f(){' + s + '}; ret=f();');
    setTimeout(do_eval, 2000, res.match[1])
    res.send 'calc: ' + res.match[1] + ' = ' + ret