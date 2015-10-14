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
    decks: []
    decksAddition: {}
      # names: ["#{__ 'I'}", "#{__ 'II'}", "#{__ 'III'}", "#{__ 'IV'}"]
      # fullnames: [__('No.%s fleet', 1), __('No.%s fleet', 2), __('No.%s fleet', 3), __('No.%s fleet', 4)]
      # state: [-1, -1, -1, -1]
      # inBattle: [false, false, false, false]
      # akashiTimeStamp: 0
      # ndocks: {}
      # condRemain: [0, 0, 0, 0]
    ships: {}
    shipsAddition: {}
      # condTimeStamps: {}
    combined: {}
      # 0 is single fleet, 1 for aerial fleet, 2 for water surface fleet
      # state: 0
      # goback: []
  getInitialState: ->
    null
  handleResponse: (e) ->
    {method, path, body, postBody} = e.detail
    null
  componentDidMount: ->
    window.addEventListener 'game.response', @handleResponse
  componentWillUnmount: ->
    window.removeEventListener 'game.response', @handleResponse
  shouldComponentUpdate: (nextProps, nextState) ->
    nextProps.activeDeck is @props.deckIndex and !_.isEqual(nextState, @state)
  render: ->
    <div>
      <div style={display:"flex", justifyContent:"space-between", margin:"5px 0"}>
          <span className="ship-more" style={flex:"none"}><FontAwesome key={0} name='clock-o' />{@props.data.decksAddition.fullnames[@props.deckIndex]}</span>
      </div>
      <div className="ship-details">
      {
        {$ships, $shipTypes, _ships} = window
        for shipId, j in @props.data.decks[@props.deckIndex].api_ship
          continue if shipId == -1
          ship = _ships[shipId]
          shipInfo = $ships[ship.api_ship_id]
          shipType = $shipTypes[shipInfo.api_stype].api_name
          [
            <ShipTile
              key={j}
              shipIndex={j}
              ship={ship}
              shipInfo={shipInfo}
              shipType={shipType}
              />
          ]
      }
      </div>
    </div>

module.exports = PaneBody
