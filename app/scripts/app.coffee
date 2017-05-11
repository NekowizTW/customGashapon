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
    React.createElement "div", {id: "list", className: "pure-g"}, @props.items.map(((card, i) ->
      url = @props.getImage(card.special, card.index, 'head')
      React.createElement("p", {className: "pure-u-1-12", key: i}, React.createElement("img", src: url, null))
    ).bind(this))
)
CardListApp = React.createClass(
  displayName: "CardListApp"
  getInitialState: ->
    id: ""
    common: []
    special: []
    shuffleDeck: []
    items: []
    stone: 0

  componentWillMount: ->
    data = @props.data.data
    shuffleDeck = []
    data.commonList.forEach((card, index) ->
      count = parseInt(card.count)
      for i in [1..count]
        shuffleDeck.push({special: false, index: index})
    )
    data.specialList.forEach((card, index) ->
      count = parseInt(card.count)
      for i in [1..count]
        shuffleDeck.push({special: true, index: index})
    )
    shuffleDeck = _.shuffle(shuffleDeck);
    @setState(
      common: data.commonList
      special: data.specialList
      shuffleDeck: shuffleDeck
    )

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
    nextItems = @state.items
    nextShuffle = @state.shuffleDeck
    nextItems.push(nextShuffle.shift())
    @setState
      items: nextItems
      shuffleDeck: nextShuffle
      stone: @state.stone + 5

    return

  handleShuffle: (e) ->
    re_shuffleDeck = _.shuffle(@state.shuffleDeck);
    @setState
      shuffleDeck: re_shuffleDeck
    return

  getImagePath: (special, key, type) ->
    if special
      return @state.special[key][type]
    else
      return @state.common[key][type]


  render: ->
    createUrl = (id) ->
      if id.length == 0
        React.createElement("span", null, "填入你表格的公開頁面即可產生")
      else
        React.createElement("a", {href: "index.html?id="+id}, "轉蛋機連結")

    React.createElement "div", null,
    React.createElement("div", className: "pure-form",
      React.createElement("label", {htmlFor: "urlParse"}, "製作你的「非人的意志」："),
      React.createElement("input", {id: "urlParse", className: "", placeholder: "輸入公開表格網址", onChange: @handleNewGasha}),
      createUrl(@state.id)
    ),
    React.createElement("div", className: "pure-form",
      React.createElement("button", {className: "pure-button pure-button-primary", onClick: @handleGashapon}, "抽牌"),
      React.createElement("button", {className: "pure-button pure-button-primary", onClick: @handleShuffle, style: {float: "right"}}, "洗牌")
    ),
    React.createElement("div", className: "pure-g",
      React.createElement("div", className: "pure-u-1", null, "目前已使用了 " + @state.stone + " 顆石頭")
    ),
    React.createElement(CardList,{items: @state.items, getImage: @getImagePath})

)

window.onload = () ->
  SourceLoad.init((data) ->
    Console.log data
    ReactDOM.render React.createElement(CardListApp, {data: {data}}, null), mountNode
  )
