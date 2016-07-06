class Person 
    constructor: (@name) ->

    talk: ->
        console.log "My name is #{@name}"

module.exports = Person