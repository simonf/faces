$ ->
  counter = 0
  numhappy = 0
  numsad = 0
  totpics = 20
  picsperrow = 5
  gameAttempts = 0
  games = []
  gameStartTime = 0
  sessionStartTime = 0
  in_session = false
  session_secs = 0

  calcStats = (ga) ->
    stats = {
      game_count: ga.length
      fastest_time: 600.0,
      slowest_time: 0.0,
      average_time: 0.0,
      tot_time: 0.0
      perfect_count: 0,
      max_trys: 0,
      min_trys: 99,
      tot_trys: 0,
      average_trys: 0
    }
    for g in ga
      stats.tot_trys += g.trys
      stats.tot_time += g.secs
      stats.fastest_time = g.secs if g.secs < stats.fastest_time
      stats.slowest_time = g.secs if g.secs > stats.slowest_time
      stats.max_trys = g.trys if g.trys > stats.max_trys
      stats.min_trys = g.trys if g.trys < stats.min_trys
      stats.perfect_count += 1 if g.trys == 1
    stats.average_time = parseInt(stats.tot_time / ga.length)
    stats.average_trys = parseInt(stats.tot_trys / ga.length)
    return stats

  showScores = ->
    stats = calcStats(games)
    $("#game_count").text(stats.game_count)
    $("#perfect_count").text(stats.perfect_count)
    $("#latest_time").text(games[games.length-1].secs)
    $("#fastest_time").text(stats.fastest_time)
#    $("#slowest_time").text(stats.slowest_time)
#    $("#avg_time").text(stats.average_time)
#    $("#max_trys").text(stats.max_trys)
#    $("#min_trys").text(stats.min_trys)
#    $("#avg_trys").text(stats.average_trys)
    return

  prefetch = ->
    $.get "/happy", (data) ->
      numhappy = data.count
      for picnum in [1..numhappy]
        happyObj[picnum] = new Image()
        happyObj[picnum].onload = imageLoaded()
        happyObj[picnum].src = "/public/happy/happy#{picnum}.jpg"
      return
    $.get "/sad", (data) ->
      numsad = data.count
      for picnum in [1..numsad]
        sadObj[picnum] = new Image()
        sadObj[picnum].onload = imageLoaded()
        sadObj[picnum].src = "/public/sad/sad#{picnum}.jpg" 
      return

  imageLoaded = ->
    counter += 1
#    console.log "Loaded #{counter}"
    if counter == numhappy + numsad
      showLinks()
    return

  showLinks = ->
    $("#links").show()
    return

  hideLinks = ->
    $("#links").hide()

  startGameTimer = ->
    gameStartTime = (new Date()).getTime()
    return

  startSessionTimer = (secs)->
    sessionStartTime = (new Date()).getTime()
    session_secs = secs
    in_session = true
    return

    
  getGameElapsedSecs = ->
    secs = parseInt(((new Date()).getTime() - gameStartTime)/100)/10.0

  endGame = ->
#    game_count += 1
    games.push { secs: getGameElapsedSecs(), trys: gameAttempts}
    $("#facetable").empty()
    showScores()
    checkIfSession()
    return

  checkIfSession = ->
    if in_session
      now = (new Date()).getTime()
      if session_secs > (now - sessionStartTime)/1000
        setTimeout startGame, 1000
      else
        session_secs = 0
        in_session = false
        showLinks()
    else
      showLinks()
    return

  correctPick = ->
    gameAttempts += 1
    endGame()
    return

  incorrectPick = ->
    gameAttempts += 1
    return

  appendpic = (ids,picnum, tgt) ->
    startofrow = (picnum % picsperrow == 1)
    endofrow = (picnum % picsperrow == 0) and (picnum > 0) 
    if startofrow == true
      $("#facetable").append("<tr>")
    if picnum == tgt
      rh = parseInt(Math.random() * numhappy + 1)
      $("#facetable tr").last().append("<td><img class='smallpic happy' src='/public/happy/happy#{rh}.jpg'></td>")
    else
      $("#facetable tr").last().append("<td><img class='smallpic sad' src='/public/sad/sad#{ids[picnum-1]}.jpg'></td>")
    return

  findRandomFalseEntry = (boolArray, len) ->
    r = parseInt(Math.random()*len)
    if boolArray[r] == true
      cnt = 0
      while r < len-1 and boolArray[r] == true and cnt < 100
          r += 1
          cnt += 1
          r=0 if r == len
      if cnt == 100
        console.log "Failed 100 times to find a false entry"
    return r
    
  makeSadIds= ->
    sadUsed = []
    for snum in [1..numsad]
      sadUsed.push(false)
    sadids = []
    for snum in [1..totpics]
      n = findRandomFalseEntry(sadUsed,numsad)
      sadUsed[n]=true
#      sadids[snum-1]=n+1
      sadids.push(n+1)
    return sadids

  showFaceMatrix = ->
    sadids=makeSadIds()
    htgt = parseInt(Math.random()*20 + 1)
    appendpic(sadids,picnum,htgt) for picnum in [1..totpics]
    $(".happy").click ->
      correctPick()
      return false
    $(".sad").click ->
      incorrectPick()
      return false
    return

  startGame = ->
    showFaceMatrix()
    gameAttempts = 0
    hideLinks()
    startGameTimer()
    return

  sadObj=[]
  happyObj=[]
  prefetch()
  $("#startgame").click ->
    startGame()
    return false
  $("#start60").click ->
    startSessionTimer(60)
    startGame(60)
    return false
  return