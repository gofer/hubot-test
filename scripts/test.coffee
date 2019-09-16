MattermostFormatter = require './mattermost_formatter'

module.exports = (robot) ->
  robot.hear /^heybot$/i, {}, (res) ->
    robot.logger.info 'heybot'
    res.send "Yes, I'm bot!"

  robot.hear /^heybot wow$/i, (res) ->
    res.send '因果WOWWOWって奴ですね'

  robot.hear /^heybot time$/i, (res) ->
    res.send '現在の時刻: ' + new Date().toString()

  robot.hear /^heybot weather$/i, (res) ->
    YahooWeather = require './yahoo_weather'
    
    pref_id = 34
    location_id = 6710
    
    try
      json = await YahooWeather.get_async(location_id)
      
      format = require 'date-format'
      LastUpdateFormat = 'yyyy/MM/dd hh:mm'
      
      link_uri = YahooWeather.get_link_uri location_id, pref_id
      
      header = [
          MattermostFormatter.to_link \
            link_uri,
            '{location}の天気 (by Yahoo!天気・災害)'
          ,
          '(最終更新日: {last_update})'
        ]
        .join(' ')
        .replace(/\{location\}/g, json.location)
        .replace(/\{last_update\}/g, format(LastUpdateFormat, json.last_update))
      
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
      res.send(header + '\n\n' + table)
    catch err
      res.send('お天気わからない… (' + err.toString() + ')')
