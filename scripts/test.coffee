MattermostFormatter = require './mattermost_formatter'
RobotHelper = require './robot_helper'

module.exports = (robot) ->
  robot.hear /^heybot$/i, {}, (res) ->
    res.send "Yes, I'm bot!"

  robot.hear /^heybot wow$/i, (res) ->
    res.reply '因果WOWWOWって奴ですね'

  robot.hear /^heybot todo add (.*)$/i, (res) ->
    list = get_todo_list()
    list.push(res.match[1])
    set_todo_list list
    
    res.send 'ToDo \"' + res.match[1] + '\" 覚えた!'

  robot.hear /^heybot todo list$/i, (res) ->
    list = get_todo_list()
    list = MattermostFormatter.to_check_list list
    
    if list.length == 0
      res.send 'ToDo 何も覚えていない…'
    else
      res.send 'ToDo で覚えているのは次の通りだよ!\n\n' + list

  robot.hear /^heybot todo forget$/i, (res) ->
    set_todo_list []
    
    res.send 'ToDo 全部忘れた!'
  
  get_todo_list = ->
    list = robot.brain.get 'todo'
    return if (list == null) then [] else list
  
  set_todo_list = (list) ->
    robot.brain.set 'todo', list

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
    res.send 'calc: ' + res.match[1] + ' = ' + eval(res.match[1])

  robot.hear /^heybot weather$/i, (res) ->
    pref_id = 34
    location_id = 6710
    
    try
      respond_text = await RobotHelper.get_weather_from_yahoo(
        pref_id, location_id
      )
      res.send respond_text
    catch err
      res.send 'お天気わからない… (' + err.toString() + ')'