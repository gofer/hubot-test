class YahooWeatherLocationHelper
  @LocationConfig = require '../resource/yahoo_weather_location.json'
  
  search_by_region = (json, query) ->
    result = []
    json.forEach (region) ->
      if region.region_name.includes query
        result.push({'region': region})
    return result
  
  search_by_prefecture = (region, query) ->
    result = []
    region.prefectures.forEach (prefecture) ->
      if prefecture.prefecture_name.includes query
        result.push({'region': region, 'prefecture': prefecture})
    return result
  
  search_by_location = (prefecture, query) ->
    result = []
    prefecture.locations.forEach (location) ->
      if location.location_name.includes query
        result.push({'prefecture': prefecture, 'location': location})
    return result
  
  search_by_prefecture_for_all_region = (json, query) ->
    result = []
    json.forEach (region) ->
      ret = search_by_prefecture region, query
      if ret.length > 0
        ret.forEach((x) -> result.push(x))
    return result
    
  search_by_location_for_all_prefecture = (region, query) ->
    result = []
    region.prefectures.forEach (prefecture) ->
      ret = search_by_location prefecture, query
      if ret.length > 0
        ret.forEach((x) -> result.push(x))
    return result
  
  search_by_location_for_all_region = (json, query) ->
    result = []
    json.forEach (region) ->
      ret = search_by_location_for_all_prefecture region, query
      if ret.length > 0
        ret.forEach((x) -> result.push({
          'region': region, 
          'prefecture': x.prefecture, 
          'location': x.location
        }))
    return result
  
  @search_location : (query) ->
    locations = search_by_location_for_all_region YahooWeatherLocationHelper.LocationConfig, query
    if locations.length > 0
      return {'answer_type': 'location', 'result': locations}
    
    prefectures = search_by_prefecture_for_all_region YahooWeatherLocationHelper.LocationConfig, query
    if prefectures.length > 0
      return {'answer_type': 'prefecture', 'result': prefectures}
    
    regions = search_by_region YahooWeatherLocationHelper.LocationConfig, query
    if regions.length > 0
      return {'answer_type': 'region', 'result': regions}
    
    return {'answer_type': 'error', 'result': null}

class YahooWeather
  @LinkBaseURI = 'https://weather.yahoo.co.jp/weather/jp/'
    .concat '{pref_id}/{location_id}.html'
  
  @RSSBaseURI = 'https://rss-weather.yahoo.co.jp/rss/days/'
    .concat '{location_id}.xml'
  
  @get_link_uri: (location_id, pref_id) ->
    YahooWeather.LinkBaseURI
      .replace(/\{location_id\}/g, location_id)
      .replace(/\{pref_id\}/g, pref_id)

  @get_rss_uri: (location_id) ->
    YahooWeather.RSSBaseURI
      .replace(/\{location_id\}/, location_id)
  
  xml_raw_json_formater = (json) ->
    last_update = new Date(json.rss.channel.lastBuildDate)
    
    location = json.rss.channel.title
      .replace(/^(.+) - (.+)の天気$/, '$2')
      .replace(/（/, '(').replace(/）/, ')')
    
    forecast = json.rss.channel.item
      .map( (x) ->
        title = x.title
          .replace(/^【(\s*)(.+)(\s*)】(.*)/, '$2')
          .replace(/^(\d+)日（(.+?)）\s*(.+?)\s*$/, '$1,$2,$3')
          .split(',')
        
        desc = x.description
          .replace(/^(.+) - (\-?\d+)℃\/(\-?\d+)℃$/, '$1,$2,$3')
          .split(',')
        
        {'title': title, 'desc': desc}
      )
      .filter( (x) ->
        x.title.length == 3 && x.desc.length == 3
      )
      .map( (x) ->
        {
          'date': {
            'day':  x.title[0],
            'wday': x.title[1]
          },
          'weather': {
            'weather':  x.desc[0],
            'max_temp': parseInt(x.desc[1]),
            'min_temp': parseInt(x.desc[2])
          }
        }
      )
    
    return {
      'last_update': last_update,
      'location':    location,
      'forecast':    forecast
    }
  
  @get_async: (location_id) ->
    new Promise (resolve, reject) ->
      request = require 'request'
      rss_uri = YahooWeather.get_rss_uri location_id
      
      try
        request.get(
          {
            uri: rss_uri
            json: true
          },
          (http_error, http_response, http_body) ->
            try
              if http_error or http_response.statusCode != 200
                throw http_error
              
              xml2json = require 'xml2json'
              json = xml2json.toJson http_body, { object: true }
              
              resolve( xml_raw_json_formater(json) )
            catch err
              reject(err)
        )
      catch err
        reject(err)

exports.get_link_uri = YahooWeather.get_link_uri
exports.get_rss_uri  = YahooWeather.get_rss_uri
exports.get_async    = YahooWeather.get_async

exports.search_location = YahooWeatherLocationHelper.search_location