###
User: ramon
Date: 12/15/12 10:17 PM
###
(->
  class Card
    constructor: (@value) ->

    @setSize: (w, h) ->
      Card.width = w
      Card.height = h
      console.log $.format("card size=({0}, {1})", w, h)

    toString: ->
      @value

    wrapCard: (innerHtml) ->
      $.format "<div class=\"card\">{0}</div>", innerHtml

    createEl: ->
      @wrapCard @value

  class PointCard extends Card
    @calcPointSize: ->
      # TODO: calc pointSize according to card size and max card value
      pointW = 100
      @pointWidth = pointW
      @pointHeight = pointW
      console.log $.format("point size=({0}, {1})", @pointWidth, @pointHeight)

    @_createGrid: ->
      unless Card.width and Card.height
        console.log "create grid fail, since width/height is not set"
        return null

      @calcPointSize() unless @pointWidth and @pointHeight

      @grid =
        init: ->
          @data = []
          @_calcGrid()
          @reset()
          @

        _calcGrid: ->
          @_divide Card.width, PointCard.pointWidth, "xLen", "paddingX"
          @_divide Card.height, PointCard.pointHeight, "yLen", "paddingY"

        _divide: (totalSize, blockSize, lenPropertyName, paddingPropertyName) ->
          totalPadding = totalSize % blockSize
          @[paddingPropertyName] = Math.floor(totalPadding / 2)
          @[lenPropertyName] = Math.floor((totalSize - totalPadding) / blockSize)

        reset: ->
          i = 0

          while i < @xLen
            @data[i] = []
            j = 0

            while j < @yLen
              @data[i][j] = false
              j++
            i++

        isPositioned: (x, y) ->
          !!(@data[x] and @data[x][y])

        positionAt: (x, y) ->
          @data[x][y] = true
          x: @paddingX + x * PointCard.pointWidth
          y: @paddingY + y * PointCard.pointHeight

      @grid.init()

    createEl: ->
      PointCard._createGrid()  unless PointCard.grid
      unless PointCard.grid
        console.error "fail to create PointCard.grid"
        return
      PointCard.grid.reset()
      pointEls = []
      i = 0

      while i < @value
        pointEl = @_createPointEl()
        pointEls[i] = pointEl
        i++
      @wrapCard pointEls.join("")

    _createPointEl: ->
      grid = PointCard.grid
      loop
        x = $.math.randomInt(0, grid.xLen - 1)
        y = $.math.randomInt(0, grid.yLen - 1)
        unless grid.isPositioned(x, y)
          position = grid.positionAt(x, y)
          left = position.x
          top = position.y
          console.log $.format("point[{0}]({1}, {2}): ({3}, {4})", @value, x, y, left, top)
          return $.format("<div class=\"point\" style=\"top:{0}px; left:{1}px; width:{2}px; height:{2}px; background-size: {2}px auto\"></div>", top, left, PointCard.pointWidth)

  class ArithmeticCard extends Card
  class AnimalCard extends Card
  class PlantCard extends Card
  class EnglishVocabularyCard extends Card
  class ChineseCharacterCard extends Card

  cardManager =
    cardCont: null
    
    # TODO: now we only support PointCard
    createCards: (cardType, values) ->
      @cards = []
      unless cardType
        console.error "cardType is not specified!!!"
        return

      if values is null or values is `undefined`
        values = cardType.defaultValues # TODO, set default values for card
      else values = [values]  unless $.type(values) is "array"

      values.forEach (value, index) =>
        @cards[index] = new cardType(value)


    play: ->
      @paused = false
      @finished = false
      return unless @_createCardElements()
      @_showCardAtIndex 0

    _createCardElements: ->
      unless @cardCont
        console.error "cardManager.cardCont is not set"
        return false
      @cardCont.empty()
      @cardWidth = @cardCont.width()
      @cardHeight = @cardCont.height()
      @$cards = []
      Card.setSize @cardWidth, @cardHeight
      @cards.forEach (card, index) =>
        $card = $(card.createEl())
        $card.hide()
        @$cards[index] = $card
        @cardCont.append $card

      true

    _showCardAtIndex: (playCardIndex) ->
      return  if @paused
      console.log "playCardIndex=" + playCardIndex
      if playCardIndex is @cards.length
        @_playOneRound()
        return
      settings = flashCard.settings
      duration = 0 #settings.displayTime / 5; // ; 'fast', 'slow'
      # TODO: animation type
      toggleMethod = "fadeToggle" # 'toggle', 'fadeToggle', 'slideToggle'
      __showCurrentCard = (currentCardIndex) =>
        currentCard = @$cards[currentCardIndex]
        currentCard[toggleMethod] duration, =>
          window.setTimeout (=>
            @_showCardAtIndex currentCardIndex + 1
          ), settings.displayTime


      previousCard = (if playCardIndex is 0 then @$cards[@$cards.length - 1] else @$cards[playCardIndex - 1])
      if previousCard and previousCard.is(":visible")
        previousCard[toggleMethod] duration, ->
          __showCurrentCard playCardIndex

      else
        __showCurrentCard playCardIndex

    _playOneRound: ->
      console.log "play one round"
      if flashCard.settings.repeatPlay
        @_showCardAtIndex 0
      else
        console.log "play over"
        @finished = true

    pause: ->
      me = this
      me.paused = true

    reset: ->

  flashCard =
    
    # TODO: it should be configurable
    settings:
      displayTime: 1500 # ms, effect when autoPlay is true
      animation: "fade" # blind, drop, explode, clip, puff
      autoPlay: true
      randomPlay: true
      repeatPlay: false

    type:
      pointCard: PointCard

    cardManager: cardManager

  window.flashCard = flashCard
)()
