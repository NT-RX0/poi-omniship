{relative, join} = require 'path-extra'
{_, $, $$, React, ReactBootstrap, ROOT, toggleModal} = window
{$ships, $shipTypes, _ships} = window
{Button, ButtonGroup, OverlayTrigger, Tooltip, Overlay, Popover, ProgressBar} = ReactBootstrap
{__, __n} = require 'i18n'

ShipTile = require './shiptile'
DeckInfo = require './deck-info'
{getShipStatus} = require './statuslabelmini'

repairTimer =
  remain: 0
  total: 0
missionTimer =
  remain: 0
  total: 0
condTimer =
  remain: 0
  total: 0

PaneBody = React.createClass
  condDynamicUpdateFlag: false
  getInitialState: ->
    cond: [0, 0, 0, 0, 0, 0]
    label: [-1, -1, -1, -1, -1, -1]
    repairTimer: Object.clone(repairTimer)
    missionTimer: Object.clone(missionTimer)
    condTimer: Object.clone(condTimer)
  onCondChange: (cond) ->
    condDynamicUpdateFlag = true
    @setState
      cond: cond
  getCondRemain: (deck) ->
    {$ships, $slotitems, _ships} = window
    total = [0, 0, 0, 0, 0, 0]
    remain = [0, 0, 0, 0, 0, 0]
    maxflag = 0
    t = new Date()
    for shipId, i in deck.api_ship
      ship = _ships[shipId]
      if shipId == -1 or ship.api_cond >= 49
        continue
      if @props.condStartTime[shipId]?
        complete = Math.ceil((49 - ship.api_cond) / 3) * 3 * 60 * 1000 + @props.condStartTime[shipId]
        total[i] = complete - @props.condStartTime[shipId]
        remain[i] = complete - Date.now()
    # returns milli second
    maxflag = remain.indexOf(Math.max.apply(Math, remain))
    {
      totalmax: total[maxflag]
      remainmax: remain[maxflag]
    }
  updateTimers: (ndocks) ->
    {missionTimer, repairTimer, condTimer} = @state
    # set repair timer
    repairTimer.total = 0
    repairTimer.remain = 0
    for ndock, i in ndocks
      if ndock.api_complete_time > 0 and ndock.api_ship_id in @props.deck.api_ship
        t = new Date()
        repairTimer.total = ndock.api_complete_time - t
        repairTimer.remain = ndock.api_complete_time - t
    # set cond timer
    timer = @getCondRemain(@props.deck)
    condTimer.total = timer.totalmax
    condTimer.remain = timer.remainmax
    # set mission timer
    if @props.deckIndex != 0
      {$missions} = window
      complete = @props.deck.api_mission[2]
      mId = @props.deck.api_mission[1]
      if mId == 0
        missionTimer.total = 0
        missionTimer.remain = 0
      else
        t = new Date()
        missionTimer.total = $missions[mId].api_time * 60 * 1000
        missionTimer.remain = complete - t
    [missionTimer, repairTimer, condTimer]
  updateLabels: ->
    # refresh label
    {label} = @state
    {_ships} = window
    for shipId, j in @props.deck.api_ship
      continue if shipId == -1
      ship = _ships[shipId]
      status = getShipStatus shipId
      label[j] = status
    label
  handleResponse: (e) ->
    {method, path, body, postBody} = e.detail
    {missionTimer, repairTimer, condTimer, label} = @state
    updateflag = false
    ndocks = []
    switch path
      when '/kcsapi/api_port/port'
        updateflag = true
        ndocks = Object.clone(body.api_ndock)
      when '/kcsapi/api_req_hensei/change'
        updateflag = true
      when '/kcsapi/api_req_mission/start'
        # postBody.api_deck_id is a string starting from 1
        deckIndex = parseInt postBody.api_deck_id
        if @props.deckIndex != 0
          t = new Date()
          total = body.api_complatetime - t
          missionTimer.total = total
          missionTimer.remain = total
          updateflag = true
      when '/kcsapi/api_req_nyukyo/start'
        shipId = parseInt postBody.api_ship_id
        if shipId in @props.deck.api_ship
          i = @props.deck.api_ship.indexOf shipId
          label[i] = 1
          updateflag = true
    if updateflag
      timers = @updateTimers(ndocks)
      missionTimer = timers[0]
      repairTimer = timers[1]
      condTimer = timers[2]
      label = @updateLabels()
      @setState
        condTimer: condTimer
        repairTimer: repairTimer
        missionTimer: missionTimer
        label: label
  componentDidMount: ->
    window.addEventListener 'game.response', @handleResponse
    label = @updateLabels()
    @setState
      label: label
  componentWillUnmount: ->
    window.removeEventListener 'game.response', @handleResponse
  shouldComponentUpdate: (nextProps, nextState) ->
    nextProps.activeDeck is @props.deckIndex
  componentWillReceiveProps: (nextProps) ->
    {_ships} = window
    if @condDynamicUpdateFlag
      @condDynamicUpdateFlag = not @condDynamicUpdateFlag
    else
      cond = [0, 0, 0, 0, 0, 0]
      for shipId, j in nextProps.deck.api_ship
        if shipId == -1
          cond[j] = 49
          continue
        ship = _ships[shipId]
        cond[j] = ship.api_cond
      @setState
        cond: cond
  componentWillMount: ->
    {_ships} = window
    cond = [0, 0, 0, 0, 0, 0]
    for shipId, j in @props.deck.api_ship
      if shipId == -1
        cond[j] = 49
        continue
      ship = _ships[shipId]
      cond[j] = ship.api_cond
    @setState
      cond: cond
  render: ->
    <div>
      <div style={display:"flex", justifyContent:"space-between", margin:"5px 0"}>
        <OverlayTrigger placement="top" overlay={
          <Tooltip>
            <div>
              <DeckInfo.reactClass
                updateCond={@onCondChange}
                messages={@props.messages}
                deckIndex={@props.deckIndex}
                deckName={@props.deckName}
              />
            </div>
          </Tooltip>
          }>
          <span className="ship-more" style={flex:"none"}><FontAwesome key={0} name='clock-o' /></span>
        </OverlayTrigger>
        {# <RecoveryBar style={flex:"auto"} deck={@props.deck} deckIndex = {@props.deckIndex} repairTimer = {@state.repairTimer} missionTimer = {@state.missionTimer} condTimer = {@state.condTimer} /> }
      </div>
      <div className="ship-details">
      {
        {$ships, $shipTypes, _ships} = window
        for shipId, j in @props.deck.api_ship
          continue if shipId == -1
          ship = _ships[shipId]
          shipInfo = $ships[ship.api_ship_id]
          shipType = $shipTypes[shipInfo.api_stype].api_name
          [
            <ShipTile
              ship={ship}
              shipInfo={shipInfo}
              shipType={shipType}
              label={@state.label[j]}
              />
          ]
      }
      </div>
    </div>

module.exports = PaneBody
