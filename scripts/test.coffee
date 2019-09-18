MattermostFormatter = require '../lib/mattermost_formatter'
RobotHelper = require './robot_helper'
Conversation = require 'hubot-conversation'

module.exports = (robot) ->
  conversation = new Conversation robot
  
  robot.hear /^heybot$/i, (res) ->
    res.send "Yes, I'm bot!"

  robot.hear /^heybot debug(.*)$/, (res) ->
    YahooWeather = require '../lib/yahoo_weather'
    
    query = if res.match[1].trim().length > 0 then res.match[1].trim() else ''
    
    answer = YahooWeather.search_location query
    
    #console.log answer
    
    #res.send 'Answer Type: ' + answer.type
    
    switch (answer.type)
      when 'location'
        list = answer.result.map(
          (x) -> '- {location_name} ({prefecture_name})' \
            .replace(/\{location_name\}/,   x.location.location_name) \
            .replace(/\{prefecture_name\}/, x.prefecture.prefecture_name)
        ).join('\n')
        res.send '次のような地名がヒットしました\n\n' + list
      when 'prefecture'
        list = answer.result.map(
          (x) -> 
            '- ' + x.prefecture.prefecture_name + '\n' \
             + (
                x.prefecture.locations.map(
                  (y) -> '  - ' + y.location_name
                ).join('\n')
             )
        ).join('\n')
        res.send '次のような都道府県名がヒットしました\n\n' + list
      when 'region'
        list = answer.result.map(
          (x) -> '- ' + x.region.region_name + '\n' \
            + (
              x.region.prefectures.map(
                (y) -> '  - ' + y.prefecture_name
              ).join('\n')
            )
        ).join('\n')
        res.send '次のような地域名がヒットしました\n\n' + list
      when 'error'
        console.log 'error'

  robot.hear /^heybot conv ?(.+)$/, (res) ->
    # Lexer = require '../lib/string_lexer'
    # console.log(Lexer.split_by_space res.match[1])
    
    res.reply 'Are you okay?'
    
    dialog = conversation.startDialog(res)
    dialog.addChoice /^(.+)$/, (res2) ->
      res2.reply 'I know you say "' + res2.match[1] + '"'

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