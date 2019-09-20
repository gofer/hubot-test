class HubotYahooWeatherHelper
  MattermostFormatter = require '../lib/mattermost_formatter'
  YahooWeather = require '../lib/yahoo_weather'
  
  @get_weather_message: (location_id, prefecture_id) ->
    json = await YahooWeather.get_async location_id
    
    moment = require 'moment-timezone'
    moment.locale('ja-JP')
    LastUpdateFormat = 'YYYY/MM/DD hh:mm'
    last_update = moment(json.last_update).format(LastUpdateFormat)
    
    link_uri = YahooWeather.get_link_uri location_id, prefecture_id
    
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
  
  @search_location: (query) ->
    YahooWeather = require '../lib/yahoo_weather'
    answer = YahooWeather.search_location query
    
    if answer.result && answer.type == 'location' && answer.result.length == 1
      return {
        'location_name': answer.result[0].location.location_name,
        'location_id':   answer.result[0].location.location_id,
        'prefecture_id': answer.result[0].prefecture.prefecture_id
      }
    
    throw new Error location_candidates_to_reply_message answer

exports.get_weather_message = HubotYahooWeatherHelper.get_weather_message
exports.search_location = HubotYahooWeatherHelper.search_location