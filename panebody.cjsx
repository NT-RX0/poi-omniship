{relative, join} = require 'path-extra'
{_, $, $$, React, ReactBootstrap, ROOT, toggleModal} = window
{$ships, $shipTypes, _ships} = window
{Button, ButtonGroup, OverlayTrigger, Tooltip, Overlay, Popover, ProgressBar} = ReactBootstrap
{__, __n} = require 'i18n'

ShipTile = require './shiptile'

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
  data:
    decks: @props.data.decks
      # names: ["#{__ 'I'}", "#{__ 'II'}", "#{__ 'III'}", "#{__ 'IV'}"]
      # fullnames: [__('No.%s fleet', 1), __('No.%s fleet', 2), __('No.%s fleet', 3), __('No.%s fleet', 4)]
      # state: [-1, -1, -1, -1]
      # inBattle: [false, false, false, false]
      # akashiTimeStamp: 0
      # ndocks: {}
    ships: @props.data.ships
      # condTimeStamps: {}
    combined: @props.data.combined
      # state: 0
      # goback: []
  getInitialState: ->
    cond: [0, 0, 0, 0, 0, 0]
    label: [-1, -1, -1, -1, -1, -1]
    state: @decks.state
  handleResponse: (e) ->
    {method, path, body, postBody} = e.detail
    ndocks = @decks.ndocks
    switch path
      when '/kcsapi/api_port/port', '/kcsapi/api_req_hensei/change', '/kcsapi/api_req_mission/start', '/kcsapi/api_req_nyukyo/start'
      label = @updateLabels()
      @setState
        label: label
  componentDidMount: ->
    window.addEventListener 'game.response', @handleResponse
  componentWillUnmount: ->
    window.removeEventListener 'game.response', @handleResponse
  shouldComponentUpdate: (nextProps, nextState) ->
    nextProps.activeDeck is @props.deckIndex
  render: ->
    <div>
      <div style={display:"flex", justifyContent:"space-between", margin:"5px 0"}>
          <span className="ship-more" style={flex:"none"}><FontAwesome key={0} name='clock-o' /></span>
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
              />
          ]
      }
      </div>
    </div>

module.exports = PaneBody
