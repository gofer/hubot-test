MattermostFormatter = require '../lib/mattermost_formatter'
RobotHelper = require './robot_helper'
Conversation = require 'hubot-conversation'

module.exports = (robot) ->
  conversation = new Conversation robot
  
  robot.hear /^heybot$/i, (res) ->
    res.send "Yes, I'm bot!"

  location_candidates_to_reply_message = (answer) ->
    switch (answer.type)
      when 'location'
        list = answer.result.map(
          (x) -> '- {location_name} ({prefecture_name})' \
            .replace(/\{location_name\}/,   x.location.location_name) \
            .replace(/\{prefecture_name\}/, x.prefecture.prefecture_name)
        ).join('\n')
        return '次のような地名がヒットしました\n\n' + list
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
        return '次のような都道府県名がヒットしました\n\n' + list
      when 'region'
        list = answer.result.map(
          (x) -> '- ' + x.region.region_name + '\n' \
            + (
              x.region.prefectures.map(
                (y) -> '  - ' + y.prefecture_name
              ).join('\n')
            )
        ).join('\n')
        return '次のような地域名がヒットしました\n\n' + list
      when 'error'
        return '何もヒットしませんでした……'
  
  location_search = (query) ->
    YahooWeather = require '../lib/yahoo_weather'
    answer = YahooWeather.search_location query
    
    if answer.result && answer.type == 'location' && answer.result.length == 1
      return {
        'location_name': answer.result[0].location.location_name,
        'location_id':   answer.result[0].location.location_id,
        'prefecture_id': answer.result[0].prefecture.prefecture_id
      }
    
    throw new Error location_candidates_to_reply_message answer
  
  get_query = (match) ->
    if match.trim() then match.trim() else 'wow'
  
  get_weather = (res, answer) ->
    try
      respond_text = await RobotHelper.get_weather_from_yahoo(
        answer.location_id, answer.prefecture_id
      )
      res.send respond_text
    catch err
      res.send 'お天気わからない… (' + err.toString() + ')'
  
  location_search_conversation = (res, query) ->
    try
      answer = location_search query
      get_weather res, answer
      # console.log answer
      # res.send 'Location: ' + answer.location_name
    catch e
      # console.log e
      res.reply e.message
      res.reply 'もう一度返信してね!'
      
      dialog = conversation.startDialog(res)
      dialog.addChoice /^(.+)$/, (res2) ->
        query2 = get_query res2.match[1]
        location_search_conversation res2, query2
  
  robot.hear /^heybot debug(.*)$/, (res) ->
    query = get_query res.match[1]
    location_search_conversation res, query

  robot.hear /^heybot conv ?(.*)$/, (res) ->
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
    prefecture_id = 34
    location_id = 6710
    
    try
      respond_text = await RobotHelper.get_weather_from_yahoo(
        location_id, prefecture_id
      )
      res.send respond_text
    catch err
      res.send 'お天気わからない… (' + err.toString() + ')'