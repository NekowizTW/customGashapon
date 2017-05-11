headReact = window.React = require("react")
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
      imgAttr = @props.getImage(card, 'head')
      imgAttr['style'] = {color: "white"}
      React.createElement("p", {className: "pure-u-1-12", key: i}, React.createElement("img", imgAttr, null))
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
    alertState: 0

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
      alertState: if nextItems[nextItems.length - 1].special then 2 else 1

    return

  handleShuffle: (e) ->
    re_shuffleDeck = _.shuffle(@state.shuffleDeck);
    @setState
      shuffleDeck: re_shuffleDeck
    return

  getImageAttr: (card, type) ->
    src = ""
    alt = ""
    if card == undefined
      return {src: src, alt: alt}
    else if card.special
      src = @state.special[card.index][type]
      alt = @state.special[card.index].numname
    else
      src = @state.common[card.index][type]
      alt = @state.common[card.index].numname
    return {src: src, alt: alt}

  makeAlert: ->
    if @state.alertState == 0
      return "你發動了非人的意志，抽牌吧"
    if @state.alertState == 1
      return "抽到常駐卡，非人的意志發動，可再抽一張"
    if @state.alertState == 2
      return "你脫非了，非人的意志銷毀，燒"

  render: ->
    createUrl = (id) ->
      if id.length == 0
        React.createElement("span", null, "填入你表格的公開頁面即可產生")
      else
        React.createElement("a", {href: "index.html?id="+id}, "轉蛋機連結")

    cardAttr = @getImageAttr(@state.items[@state.items.length - 1], 'full')
    cardAttr["style"] = {width: 200, height: 293, display: "inline-block", backgroundColor: "black", color: "black"}
    cardStr = if cardAttr['alt'] then ("你抽到了" + cardAttr['alt']) else null
    React.createElement "div", null,
    React.createElement("div", className: "pure-form",
      React.createElement("label", {htmlFor: "urlParse"}, "製作你的「非人的意志」："),
      React.createElement("input", {id: "urlParse", className: "", placeholder: "輸入公開表格網址", onChange: @handleNewGasha}),
      createUrl(@state.id)
    ),
    React.createElement("div", className: "pure-g",
      React.createElement("div", className: "pure-u-1 pure-u-md-1-2", style: {textAlign: "center"}, null,
        React.createElement("img", src: "http://i.tcgplayer.com/66868_200w.jpg", null)
      ),
      React.createElement("div", className: "pure-u-1 pure-u-md-1-2 flex",
        React.createElement("div", className: "pure-alert", @makeAlert())
      )
    ),
    React.createElement("div", className: "pure-g",
      React.createElement("div", className: "pure-u-1 pure-u-md-1-2", style: {textAlign: "center"},
        React.createElement("img", cardAttr, null)
      ),
      React.createElement("div", className: "pure-u-1 pure-u-md-1-2",
        React.createElement("div", className: "pure-popover left flex", style: {width: "100%"},
          React.createElement "div", style: {width: "100%"},
            React.createElement("p", null, cardStr),
            React.createElement("button", {className: "pure-button pure-button-primary", onClick: @handleGashapon, style: {width: "100%", marginTop: 10}}, "抽牌"),
            React.createElement("button", {className: "pure-button pure-button-primary", onClick: @handleShuffle, style: {width: "100%", marginTop: 10}}, "洗牌")
        )
      )
    ),
    React.createElement("div", className: "pure-g",
      React.createElement("div", className: "pure-u-1", null, "目前已使用了 " + @state.stone + " 顆石頭")
    ),
    React.createElement(CardList, {items: @state.items, getImage: @getImageAttr})

)

window.onload = () ->
  SourceLoad.init((data) ->
    Console.log data
    ReactDOM.render React.createElement(CardListApp, {data: {data}}, null), mountNode
  )
