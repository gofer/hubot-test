class RobotHelper
  MattermostFormatter = require './mattermost_formatter'
  YahooWeather = require './yahoo_weather'
  
  @get_weather_from_yahoo: (pref_id, location_id) ->
    json = await YahooWeather.get_async location_id
    
    moment = require 'moment-timezone'
    moment.locale('ja-JP')
    LastUpdateFormat = 'YYYY/MM/DD hh:mm'
    last_update = moment(json.last_update).format(LastUpdateFormat)
    
    link_uri = YahooWeather.get_link_uri location_id, pref_id
    
    header = [
        MattermostFormatter.to_link(
          link_uri,
          '{location}の天気 (by Yahoo!天気・災害)'
        ),
        '(最終更新日時: {last_update})'
      ]
      .join('　')
      .replace(/\{location\}/g, json.location)
      .replace(/\{last_update\}/g, last_update)
    
    weather2emoji = (text) ->
      text = text
        .replace(/晴れ?/, ':sunny:')
        .replace(/曇り?/, ':cloud:')
        .replace(/雨/,    ':umbrella:')
        .replace(/雪/,    ':snowman:')
        .replace(/時々/,  ' / ')
        .replace(/のち/,  ' → ')
      if /一時/.test(text)
        text = text.replace(/一時/, '（') + '）'
      return text
    
    table_head = ['日付', '天気', '最高気温', '最低気温']
    
    DateFormat = '{day}日 ({wday})'
    table_body = json.forecast
      .map((obj) ->
        [
          DateFormat
            .replace(/\{day\}/g,  obj.date.day)
            .replace(/\{wday\}/g, obj.date.wday),
          weather2emoji(obj.weather.weather),
          obj.weather.max_temp.toString(),
          obj.weather.min_temp.toString()
        ]
      )
    
    table = MattermostFormatter.build_table table_head, table_body
    
    return header + '\n\n' + table

exports.get_weather_from_yahoo = RobotHelper.get_weather_from_yahoo