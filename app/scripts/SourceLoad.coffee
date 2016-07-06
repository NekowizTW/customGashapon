RSVP = require('rsvp')
url = require('url')
location = require('location-href')
Console = require('console-browserify')

SourceLoad = 
  data: {}
  base: '19i6BNjbgtZieTxl-QDgYW1nXlOEd4FF7VTtsEF7vMXI'
  urls: [
    'http://spreadsheets.google.com/feeds/list/'
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
  sortList: (source) ->
    table = source.feed.entry
    res = {}
    table.forEach((card) ->
      if not res[card.content.$t.split("稀有度: ")[1]]
        res[card.content.$t.split("稀有度: ")[1]] = []
      res[card.content.$t.split("稀有度: ")[1]].push(card.title.$t)
    )
    return res
  probList: (source) ->
    table = source.feed.entry
    res = 
      baseProb: 
        key: []
        prob: []
      subProb: {}
    table[0].content.$t.split(",").forEach((str) ->
      prob = str.split(":")
      res.baseProb.prob.push(prob[1].trim())
    )
    table[1].content.$t.split(",").forEach((str) ->
      prob = str.split(":")
      res.baseProb.key.push(prob[1].trim())
      res.subProb[prob[1].trim()] = []
    )
    for i in [2..table.length-1]
      j = 0
      table[i].content.$t.split(",").forEach((str) ->
        prob = str.split(":")
        res.subProb[res.baseProb.key[j]].push(prob[1].trim())
        j++
      )
    return res
  init: (f) ->
    url_parse = url.parse(location(), true)
    id = url_parse.query.id || @base
    promises = 
      prob: @getJSON(@urls[0]+id+@urls[1])
      list: @getJSON(@urls[0]+id+@urls[2])
    func = 
      sortList: @sortList
      probList: @probList
    RSVP.hash(promises).then((result) ->
      @data = 
        list: func.sortList(result.list)
        prob: func.probList(result.prob)
      f(@data)
    ).catch((error) ->
      Console.log "WTF"
      Console.log error
    )


module.exports = SourceLoad