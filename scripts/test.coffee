MattermostFormatter = require './mattermost_formatter'
RobotHelper = require './robot_helper'

module.exports = (robot) ->
  robot.hear /^heybot$/i, {}, (res) ->
    res.send "Yes, I'm bot!"

  robot.hear /^heybot wow$/i, (res) ->
    res.send '因果WOWWOWって奴ですね'

  robot.hear /^heybot time/i, (res) ->
    format = require 'dateformat'
    DateFormat = 'yyyy/MM/dd(ddd) hh:mm:ss [Z]'
    
    response = '現在の時刻: ' + (format new Date, DateFormat)
    if process.env.TZ
       response += ', ENV[\'TZ\'] = ' + process.env.TZ
    
    res.send response

  robot.hear /^heybot calc (.*)$/i, (res) ->
    res.send 'calc: ' + res.match[1] + ' = ' + eval(res.match[1])

  robot.hear /^heybot weather$/i, (res) ->
    pref_id = 34
    location_id = 6710
    
    try
      respond_text = await RobotHelper.get_weather_from_yahoo pref_id, location_id
      res.send(respond_text)
    catch err
      res.send('お天気わからない… (' + err.toString() + ')')