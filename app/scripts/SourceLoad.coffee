RSVP = require('rsvp')
url = require('url')
location = require('location-href')
Console = require('console-browserify')

SourceLoad =
  data: {}
  base: '19i6BNjbgtZieTxl-QDgYW1nXlOEd4FF7VTtsEF7vMXI'
  urls: [
    'https://spreadsheets.google.com/feeds/list/'
    '/1/public/basic?alt=json'
    '/2/public/basic?alt=json'
  ]
  getJSON: (url) ->
    promise = new RSVP.Promise((resolve, reject) ->
      r = new XMLHttpRequest
      r.open 'GET', url, true
      r.onreadystatechange = ->
        if r.readyState != 4 or r.status != 200
          if r.status == 400
            reject(r.statusText)
          # reject(r)
          return
        else
          resolve(JSON.parse(r.response))
        return
      r.send()
    )
    return promise
  commonList: (source) ->
    table = source.feed.entry
    res = []
    if table == undefined
      return res
    table.forEach((card) ->
      newCard = {}
      card.content.$t.split(", ").forEach((item) ->
        info = item.split(": ")
        newCard[info[0]] = info[1]
      )
      res.push newCard
    )
    return res
  specialList: (source) ->
    table = source.feed.entry
    res = []
    if table == undefined
      return res
    table.forEach((card) ->
      newCard = {}
      card.content.$t.split(", ").forEach((item) ->
        info = item.split(": ")
        newCard[info[0]] = info[1]
      )
      res.push newCard
    )
    return res
  init: (f) ->
    url_parse = url.parse(location(), true)
    id = url_parse.query.id || @base
    promises =
      special: @getJSON(@urls[0]+id+@urls[1])
      list: @getJSON(@urls[0]+id+@urls[2])
    func =
      commonList: @commonList
      specialList: @specialList
    RSVP.hash(promises).then((result) ->
      @data = {}
      @data.commonList = func.commonList(result.list)
      @data.specialList =  func.specialList(result.special)
      f(@data)
    ).catch((error) ->
      Console.log "WTF"
      Console.log error
    )


module.exports = SourceLoad
