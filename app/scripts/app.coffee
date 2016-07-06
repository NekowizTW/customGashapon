React = window.React = require("react")
ReactDOM = require("react-dom")
Crypto = require('crypto')
_ = require('lodash')
url = require('url')
Console = require('console-browserify') 
SourceLoad = require('./SourceLoad.coffee')

mountNode = document.getElementById("app")
CardList = React.createClass(
  displayName: "CardList"
  render: ->
    createItem = (url) ->
      React.createElement("p", {className: "pure-u-1-12"}, React.createElement("a", href: url.link, null, React.createElement("img", src: url.image, null)))
    createTotal = (items, keys) ->
      str = ""
      result = _.countBy(items, 'rank')
      for key of keys
        num = result[keys[key]] || 0
        if num == 0
          continue
        str = str.concat(keys[key]+": "+num+" ")
      React.createElement("p", {className: "pure-u-1-1"}, str)

    React.createElement "div", {id: "list", className: "pure-g"}, createTotal(@props.items, @props.keys), @props.items.map(createItem)
)
CardListApp = React.createClass(
  displayName: "CardListApp"
  getInitialState: ->
    items: []
    shuffleDeck: []
    rankDeck: {}
    prob: {}
    id: ""

  componentWillMount: ->
    data = @props.data.data
    shuffleDeck = []
    data.prob.baseProb.prob.forEach((prob, key) ->
      for i in [1..prob]
        shuffleDeck.push(data.prob.baseProb.key[key])
    )
    shuffleDeck = _.shuffle(shuffleDeck);
    @setState(
      rankDeck: data.list
      prob: data.prob
      shuffleDeck: shuffleDeck
    )

  getFileData: (number, rank) ->
    pad = "0000"
    small_filename = pad.substring(0, pad.length - number.toString().length) + number + ".png"
    rand = Math.floor((Math.random() * 4) + 1)
    md5name = Crypto.createHash('md5').update(small_filename).digest('hex')
    card =
      rank: rank
      link: "http://zh.nekowiz.wikia.tw/wiki/卡片資料/" + number
      image: "http://vignette"+rand+".wikia.nocookie.net/nekowiz/images/"+md5name.charAt(0)+"/"+md5name.charAt(0)+md5name.charAt(1)+"/"+small_filename+"/revision/latest?path-prefix=zh"

    return card

  handleNewGasha: (e) ->
    url_source = e.target.value
    url_parse = url.parse(url_source.toString(), true)
    val = url_parse.path.split('/')
    if val.length != 5 or val[4] != 'pubhtml'
      @setState(
        id: ""
      )
      return
    @setState(
      id: val[3]
    )
    return

  handleGashapon: (e) ->
    e.disabled = true
    nextItems = @state.items
    loop
      rank = @state.shuffleDeck[_.random(0, @state.shuffleDeck.length-1)]
      break if typeof @state.rankDeck[rank]
    number = @state.rankDeck[rank][_.random(0, @state.rankDeck[rank].length-1)]
    nextItems.push(@getFileData(number, rank))
    @setState
      items: nextItems
    @checkImage()
    setTimeout(
      () ->
        e.disabled = false
      , 1000)

    return

  handleShuffle: (e) ->
    e.disabled = true
    re_shuffleDeck = _.shuffle(@state.shuffleDeck);
    @setState
      shuffleDeck: re_shuffleDeck
    setTimeout(
      () ->
        e.disabled = false
      , 1000)

    return

  checkImage: () ->
    arr = document.getElementsByTagName('img')
    for ele of arr
      `ele = ele`
      if typeof arr[ele] == 'object'
        width = arr[ele].clientWidth
        height = arr[ele].clientHeight
        if width != height
          arr[ele].src = 'http://vignette4.wikia.nocookie.net/nekowiz/images/6/6e/0000.png/revision/latest?cb=20150218035851&path-prefix=zh'


  render: ->
    createUrl = (id) ->
      if id.length == 0
        React.createElement("span", null, "填入轉蛋機公開頁面即可產生")
      else
        React.createElement("a", {href: "index.html?id="+id}, "轉蛋機連結")

    React.createElement "div", null,
    React.createElement("div", className: "pure-form",
      React.createElement("label", {htmlFor: "urlParse"}, "自訂轉蛋機："),
      React.createElement("input", {id: "urlParse", className: "", placeholder: "輸入公開表格網址", onChange: @handleNewGasha}),
      createUrl(@state.id)
    ),
    React.createElement("div", className: "pure-form", 
      React.createElement("button", {className: "pure-button pure-button-primary", onClick: @handleGashapon}, "轉一下!!"),
      React.createElement("button", {className: "pure-button pure-button-primary", onClick: @handleShuffle, style: {float: "right"}}, "踢一下!!")
    ),
    React.createElement(CardList,{items: @state.items, keys: @state.prob.baseProb.key})
    
)

window.onload = () ->
  SourceLoad.init((data) ->
    # Console.log data
    ReactDOM.render React.createElement(CardListApp, {data: {data}}, null), mountNode
  )
