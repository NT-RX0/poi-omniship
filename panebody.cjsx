{relative, join} = require 'path-extra'
{_, $, $$, React, ReactBootstrap, ROOT, toggleModal} = window
{$ships, $shipTypes, _ships} = window
{Button, ButtonGroup, OverlayTrigger, Tooltip, Overlay, Popover, ProgressBar} = ReactBootstrap
{__, __n} = require 'i18n'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

ShipTile = require './shiptile'
DeckInfo = require './deckinfo'
RecoveryBar = require './recoverybar'

PaneBody = React.createClass
  mixins: [PureRenderMixin]
  componentDidMount: ->
    window.addEventListener 'game.response', @handleResponse
  componentWillUnmount: ->
    window.removeEventListener 'game.response', @handleResponse
  nowTime: 0
  componentWillUpdate: (nextProps, nextState) ->
    @nowTime = (new Date()).getTime()
  componentDidUpdate: (prevProps, prevState) ->
    cur = (new Date()).getTime()
    console.log "the cost of panebody-module's render: #{cur-@nowTime}ms" if process.env.DEBUG?
  render: ->
    <div>
      <OverlayTrigger placement={if (!window.doubleTabbed) && (window.layout == 'vertical') then 'left' else 'top'} overlay={
          <Tooltip>
            <div>
              <DeckInfo decksAddition={@props.data.decksAddition}
                        deckIndex={@props.deckIndex}/>
            </div>
          </Tooltip>
        }>
        <div className="ship-header flex-row">
          <FontAwesome key={0} name='clock-o' />
          <RecoveryBar deckIndex={@props.deckIndex}
                       decksAddition={@props.data.decksAddition} />
          {@props.data.decksAddition.fullnames[@props.deckIndex]}
        </div>
      </OverlayTrigger>
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
              ship={@props.data.decksAddition.shipDetails[@props.deckIndex][j].ship}
              shipInfo={@props.data.decksAddition.shipDetails[@props.deckIndex][j].shipInfo}
              shipType={@props.data.decksAddition.shipDetails[@props.deckIndex][j].shipType}
              goback={@props.data.combined.goback}
              label={@props.label[j]}
              />
          ]
      }
      </div>
    </div>

module.exports = PaneBody
