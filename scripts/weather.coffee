# Description:
#   Utility commands surrounding Hubot uptime.
#
# Commands:
#   hubot weather <location> - Get weather from Yahoo Weather

Conversation        = require 'hubot-conversation'
MattermostFormatter = require '../lib/mattermost_formatter'
YahooWeatherHelper  = require './yahoo_weather_helper'

module.exports = (robot) ->
  DefaultLocation = {
    'location_name': '広島',
    'location_id'  : 6710,
    'prefecture_id': 34
  }
  
  conversation = new Conversation robot
  
  get_weather = (res, answer) ->
    try
      respond_text = await YahooWeatherHelper.get_weather_message(
        answer.location_id, answer.prefecture_id
      )
      res.send respond_text
    catch err
      res.send 'お天気わからない… (' + err.toString() + ')'
  
  location_search_conversation = (res, query) ->
    try
      answer = YahooWeatherHelper.search_location query
      get_weather res, answer
    catch e
      res.reply e.message + '\n\n:point_right: もう一度返信してね!'
      
      dialog = conversation.startDialog(res)
      dialog.addChoice /^(.+)$/, (res2) ->
        query2 = res2.match[1].trim()
        location_search_conversation res2, query2
  
  robot.hear /^heybot weather ?(.*)$/i, (res) ->
    query = res.match[1].trim()
    if query.length == 0
      get_weather res, DefaultLocation
    else
      location_search_conversation res, query
      