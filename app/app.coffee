
  Field = undefined
  Game = undefined
  Helper = undefined
  Informer = undefined
  Level = undefined
  app = undefined

  Game = ->
    @parentGameElementTag = 'body'
    @gameElementId = 'game'
    @level = 1
    @hiScore = 0
    @score = 0
    @playerLabel = 1
    @compLabel = -1
    @standOffLabel = 'standoff'
    @helperObj = new Helper
    @startNewLevel()
    return

  Game.prototype =
    startNewLevel: ->
      self = undefined
      self = this
      if self.levelObj
        self.levelObj.finalization()
        delete self.levelObj
      self.levelObj = new Level(self)
      return
    levelScreenDisplay: (parentElementTag, level) ->
      $('<div class="level_begin_label" id="levelBeginLabel">Уровень: ' + level + '</div>').appendTo parentElementTag
      setTimeout (->
        $('<div class="any_key_invitation" id="anyKeyInvitation">Нажмите любую клавишу (также можете кликнут мышкой) для старта</div>').appendTo '#levelBeginLabel'

        document.onkeypress = ->
          document.onkeypress = undefined
          $('#levelBeginLabel').remove()
          return

        document.onclick = ->
          document.onkeypress = undefined
          $('#levelBeginLabel').remove()
          return

        return
      ), 1000
      return
    numLevelCompute: (winner) ->
      self = undefined
      self = this
      if winner == self.playerLabel
        self.level += 1
      else if winner == self.compLabel
        self.level = 1
      return

  Level = (gameObj) ->
    self = undefined
    self = this
    @gameObj = gameObj
    @stepsCount = 0
    @fieldObj = new Field(this, @gameObj)
    @informerObj = new Informer(@gameObj)
    @gameObj.levelScreenDisplay 'body', @gameObj.level
    @stepsPlayerOn()
    return

  Level.prototype =
    finalization: ->
      @fieldObj.finalization()
      delete @fieldObj
      @informerObj.finalization()
      delete @informerObj
      return
    stepsPlayerOn: ->
      fieldElem = undefined
      self = undefined
      self = this
      fieldElem = document.getElementById(self.fieldObj.fieldElementId)

      fieldElem.onclick = (e) ->
        h_coord = undefined
        resultLevel = undefined
        target = undefined
        w_coord = undefined
        e = e or event
        target = e.target or e.srcElement
        w_coord = e.target.attributes['data-w'].value
        h_coord = e.target.attributes['data-h'].value
        resultLevel = undefined
        switch self.fieldObj.fieldArr[w_coord][h_coord]
          when 0
            self.fieldObj.changeFieldArr w_coord, h_coord, self.gameObj.playerLabel
            self.stepsCount++
            self.fieldObj.cellsRender()
            resultLevel = self.checkLevelEnd(self.gameObj.playerLabel, self.fieldObj.fieldArr)
            if resultLevel
              self.gameObj.numLevelCompute self.checkLevelEnd(self.gameObj.playerLabel, self.fieldObj.fieldArr)
              self.sendFimalMessage resultLevel
              self.scoreCalculated resultLevel
              self.stopLevel()
            else
              self.compStep()
          when 1
            self.informerObj.refreshMessage 'В эту клетку вы уже ходили', 'red'
          when -1
            self.informerObj.refreshMessage 'Эта клетка уже занята', 'red'
          else

          ###console.log('Error analyze!'); ###

            break
        return

      return
    compStep: ->
      h_coord = undefined
      i = undefined
      resultLevel = undefined
      self = undefined
      w_coord = undefined
      self = this
      w_coord = undefined
      h_coord = undefined
      resultLevel = undefined
      i = 0
      while i < 1000
        w_coord = self.gameObj.helperObj.randomIntFromZero(3)
        h_coord = self.gameObj.helperObj.randomIntFromZero(3)
        if self.fieldObj.fieldArr[w_coord][h_coord] == 0
          self.fieldObj.changeFieldArr w_coord, h_coord, self.gameObj.compLabel
          self.stepsCount++
          self.fieldObj.cellsRender self.fieldElementId, self.fieldArr
          resultLevel = self.checkLevelEnd(self.gameObj.compLabel, self.fieldObj.fieldArr)
          if resultLevel
            self.gameObj.numLevelCompute self.checkLevelEnd(self.gameObj.compLabel, self.fieldObj.fieldArr)
            self.sendFimalMessage resultLevel
            self.scoreCalculated resultLevel
            self.stopLevel()
          break
        i++
      return
    scoreCalculated: (resultLevel) ->
      self = undefined
      self = this
      if resultLevel == self.gameObj.compLabel
        if self.gameObj.score > self.gameObj.hiScore
          self.gameObj.hiScore = self.gameObj.score
        self.gameObj.score = 0
      else if resultLevel == self.gameObj.playerLabel
        self.gameObj.score += 500
      else if resultLevel == self.gameObj.standOffLabel
        self.gameObj.score += 100
      return
    sendFimalMessage: (resultLevel) ->
      self = undefined
      self = this
      if resultLevel == self.gameObj.compLabel
        self.informerObj.refreshMessage 'Вы проиграли', 'red'
      else if resultLevel == self.gameObj.playerLabel
        self.informerObj.refreshMessage 'Вы выиграли!', 'lime'
      else if resultLevel == self.gameObj.standOffLabel
        self.informerObj.refreshMessage 'Ничья, переиграем уровень заново', 'orange'
      return
    stopLevel: ->
      fieldElem = undefined
      self = undefined
      self = this
      fieldElem = document.getElementById(self.fieldObj.fieldElementId)
      fieldElem.onclick = undefined
      setTimeout (->
        self.gameObj.startNewLevel()
        return
      ), 2000
      return
    checkLevelEnd: (label, fieldArr) ->
      result = undefined
      result = undefined
      if @checkWin(label, fieldArr)
        result = label
      else if @checkStandoff()
        result = @gameObj.standOffLabel
      result
    checkStandoff: ->
      if @stepsCount >= 9
        return @gameObj.standOffLabel
      return
    checkWin: (label, fieldArr) ->
      h_coord = undefined
      w_coord = undefined
      winnerMark = undefined
      winnerMark = undefined
      if fieldArr[0][0] == label and fieldArr[1][1] == label and fieldArr[2][2] == label
        winnerMark = label
      if fieldArr[0][2] == label and fieldArr[1][1] == label and fieldArr[2][0] == label
        winnerMark = label
      h_coord = 0
      while h_coord <= 2
        if fieldArr[h_coord][0] == label and fieldArr[h_coord][1] == label and fieldArr[h_coord][2] == label
          winnerMark = label
        h_coord++
      w_coord = 0
      while w_coord <= 2
        if fieldArr[0][w_coord] == label and fieldArr[1][w_coord] == label and fieldArr[2][w_coord] == label
          winnerMark = label
        w_coord++
      winnerMark

  Helper = ->

    @randomIntFromZero = (maxExclusive) ->
      Math.floor Math.random() * maxExclusive

    return

  Informer = (gameObj) ->
    @messageCount = 0
    @informerElementId = 'informer'
    @hiScoreElementId = 'hiScore'
    @messagerElementId = 'messager'
    @levelValueId = 'levelValue'
    @scoreValueId = 'scoreValue'
    @hiScoreValueId = 'hiScoreValue'
    @gameObj = gameObj
    @create @gameObj.gameElementId, @informerElementId, @levelValueId, @scoreValueId
    @refreshHiScore @gameObj.hiScore
    @refreshMessage 'Игра началась. Ваш ход', 'orange'
    @refreshInfo @scoreValueId, @levelValueId,
      'score': @gameObj.score
      'level': @gameObj.level
    return

  Informer.prototype =
    finalization: (hiScore) ->
      hiScoreElem = undefined
      informerElem = undefined
      messagerElem = undefined
      informerElem = document.getElementById(@informerElementId)
      hiScoreElem = document.getElementById(@hiScoreElementId)
      messagerElem = document.getElementById(@messagerElementId)
      informerElem.parentNode.removeChild informerElem
      hiScoreElem.parentNode.removeChild hiScoreElem
      messagerElem.parentNode.removeChild messagerElem
      return
    create: (gameElementId, informerElementId, levelValueId, scoreValueId) ->
      $('<table class="informer" id="' + informerElementId + '">         <tr><td class="label level_label">уровень: </td><td class="value level_value" id="' + levelValueId + '"></td></tr>         <tr><td class="label score_label">счёт: </td><td class="value score_value" id="' + scoreValueId + '"></td></tr>       </table>').appendTo '#' + gameElementId
      $('<div class="messager" id="messager"></div>').appendTo '#' + @gameObj.gameElementId
      $('<div class="hi_score" id="hiScore">Рекордный счёт: <span class="hi_score_value" id="hiScoreValue"></div>').appendTo @gameObj.parentGameElementTag
      return
    refreshHiScore: (hiScore) ->
      document.getElementById(@hiScoreValueId).innerHTML = hiScore
      return
    refreshMessage: (message, textColor) ->
      $('<div class="message_unit" id="messageUnit_' + @messageCount + '" >' + message + '</div>').css(color: textColor).appendTo '#messager'
      setTimeout (->
        $('#messager div:first-child').remove()
        return
      ), 3000
      @messageCount++
      return
    refreshInfo: (scoreValueId, levelValueId, infoArr) ->
      document.getElementById(scoreValueId).innerHTML = infoArr['score']
      document.getElementById(levelValueId).innerHTML = infoArr['level']
      return

  Field = (levelObj, gameObj) ->
    self = undefined
    self = this
    @gameObj = gameObj
    @levelObj = levelObj
    @fieldArr = []
    @fieldElementId = 'field'
    @cellSize = 100
    @width = 3
    @height = 3
    @fillFieldArr()
    @fieldElementCreate()
    @cellsRender()
    return

  Field.prototype =
    finalization: ->
      fieldElem = undefined
      fieldElem = document.getElementById(@fieldElementId)
      fieldElem.parentNode.removeChild fieldElem
      return
    fillFieldArr: ->
      h_coord = undefined
      w_coord = undefined
      w_coord = 0
      while w_coord < @width
        @fieldArr[w_coord] = new Array
        h_coord = 0
        while h_coord < @height
          @fieldArr[w_coord][h_coord] = 0
          h_coord++
        w_coord++
      return
    changeFieldArr: (w_coord, h_coord, value) ->
      @fieldArr[w_coord][h_coord] = value
      return
    fieldElementCreate: ->
      gameElement = undefined
      gameElement = $('#' + @gameObj.gameElementId)
      $('<div class="field" id="field"></div>').css(
        width: @cellSize * 3 + 'px'
        height: @cellSize * 3 + 'px').appendTo gameElement
      return
    cellsRender: ->
      bgImage = undefined
      h_coord = undefined
      w_coord = undefined
      bgImage = undefined
      document.getElementById(@fieldElementId).innerHTML = ''
      w_coord = 0
      while w_coord < @width
        h_coord = 0
        while h_coord < @height
          bgImage = ''
          if @fieldArr[w_coord][h_coord] == 0
          else if @fieldArr[w_coord][h_coord] == 1
            bgImage = '/img/cross.png'
          else if @fieldArr[w_coord][h_coord] == -1
            bgImage = '/img/zero.png'
          $('<div class="cell" id="Cell_' + w_coord + '_' + h_coord + '" data-w="' + w_coord + '" data-h="' + h_coord + '" ></div>').css(
            background: 'url("' + bgImage + '") left top no-repeat'
            backgroundSize: 'cover'
            width: @cellSize - 1 + 'px'
            height: @cellSize - 1 + 'px'
            left: w_coord * @cellSize + 'px'
            top: h_coord * @cellSize + 'px').appendTo '#' + @fieldElementId
          h_coord++
        w_coord++
      return
  app = new Game

