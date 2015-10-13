{relative, join} = require 'path-extra'
{_, $, $$, React, ReactBootstrap, ROOT, toggleModal, FontAwesome} = window
{layout, tabbed} = window
{Button, ButtonGroup} = ReactBootstrap
{ProgressBar, OverlayTrigger, Tooltip, Alert, Overlay, Label, Panel, Popover} = ReactBootstrap
{__, __n} = require 'i18n'

DataInterface = require './data-interface'
# PaneBody = require './panebody'

# customized renderers
{LayoutPortrait, LayoutLandscape} = require './renderers'
# ThemeRenderer = window.ThemeRenderer['#{@name}']

# TODO
# [x] 1. prepare data
#    [\] deck cond
#    [\] test code
# [ ] 2. transform renderer
# [ ] 3. rework layout
# [ ] 4. add combined fleet, detailed fleet, battle fleet

escapeId = -1
towId = -1

getStyle = (state) ->
  if state in [0..5]
    # 0: Cond >= 40, Supplied, Repaired, In port
    # 1: 20 <= Cond < 40, or not supplied, or medium damage
    # 2: Cond < 20, or heavy damage
    # 3: Repairing
    # 4: In mission
    # 5: In map
    return ['success', 'warning', 'danger', 'info', 'default', 'primary'][state]
  'default'

module.exports =
  name: 'OmniShip'
  priority: 100000.1
  displayName: <span><FontAwesome key={0} name='bars' /> 全能舰队</span>
  description: '舰队展示页面，展示所有舰队信息'
  DI: new DataInterface()
  reactClass: React.createClass
    getInitialState: ->
      activeDeck: 0
      dataVersion: 0
      showDataVersion: 0
      data:
        decks:
          names: ["#{__ 'I'}", "#{__ 'II'}", "#{__ 'III'}", "#{__ 'IV'}"]
          fullnames: [__('No.%s fleet', 1), __('No.%s fleet', 2), __('No.%s fleet', 3), __('No.%s fleet', 4)]
          # priority: ready | not suggested | can't sortie
          # 0: Cond > 30, Supplied, Repaired, In port   --- green
          # 1: Akashi Repairing                         --- bright blue
          # 2: low Cond < 30, but supplied              --- light orange
          # 3: not supplied or medium damaged           --- orange
          # 4: heavy damage                             --- red
          # 5: Repairing                                --- blue
          # 6: In mission                               --- grey
          # 7: In map                                   --- primary / high contrast
          state: [-1, -1, -1, -1]
          inBattle: [false, false, false, false]
          akashiTimeStamp: 0
          ndocks: {}
        ships:
          condTimeStamps: {}
        combined:
          # 0 is single fleet, 1 for aerial fleet, 2 for water surface fleet
          state: 0
          goback: []
    handleClick: (idx) ->
      if idx isnt @state.activeDeck
        @setState
          activeDeck: idx
          dataVersion: @state.dataVersion + 1
    handleResponse: (e) ->
      {method, path, body, postBody} = e.detail
      data = @state.data
      switch path
        when '/kcsapi/api_port/port'
          {_decks} = window
          # update combined state
          if body.api_combined_flag?
            data.combined.state = body.api_combined_flag
          # update cond
          data.ships.condTimeStamps = DI.getShipCondStamps(data.ships.condTimeStamps)
          # update akashi
          if DI.isAkashiRepairing(_decks[0])
            if data.decks.akashiTimeStamp == 0
              data.decks.akashiTimeStamp = Date.now()
          else
            data.decks.akashiTimeStamp = 0
          # save ndocks
          data.decks.ndocks = body.api_ndock
        when '/kcsapi/api_req_hensei/change'
          {_decks} = window
          # update akashi
          if DI.isAkashiRepairing(_decks[0])
            if data.decks.akashiTimeStamp == 0
              data.decks.akashiTimeStamp = Date.now()
          else
            data.decks.akashiTimeStamp = 0
        when '/kcsapi/api_req_hokyu/charge', '/kcsapi/api_get_member/deck', '/kcsapi/api_get_member/ship_deck', '/kcsapi/api_get_member/ship2', '/kcsapi/api_get_member/ship3', '/kcsapi/api_req_kaisou/powerup', '/kcsapi/api_get_member/ndock', '/kcsapi/api_req_nyukyo/start', '/kcsapi/api_req_nyukyo/speedchange'
          # update cond
          data.ships.condTimeStamps = DI.getShipCondStamps(data.ships.condTimeStamps)
        when '/kcsapi/api_req_kousyou/destroyship'
          # update cond
          shipId = parseInt postBody.api_ship_id
          delete data.ships.condTimeStamps[shipId]
        when '/kcsapi/api_req_map/start'
          # update deck state
          deckId = parseInt(postBody.api_deck_id) - 1
          data.decks.inBattle[deckId] = true
        when '/kcsapi/api_req_sortie/battleresult', '/kcsapi/api_req_combined_battle/battleresult'
          {_decks} = window
          # update goback ids
          if body.api_escape_flag? and body.api_escape_flag > 0
            escapeIdx = body.api_escape.api_escape_idx[0] - 1
            towIdx = body.api_escape.api_tow_idx[0] - 1
            escapeId = _decks[escapeIdx // 6].api_ship[escapeIdx % 6]
            towId = _decks[towIdx // 6].api_ship[towIdx % 6]
        when '/kcsapi/api_req_combined_battle/goback_port'
          if escapeId != -1 and towId != -1
            # console.log "退避：#{_ships[escapeId].api_name} 护卫：#{_ships[towId].api_name}"
            data.combined.goback.push escapeId
            data.combined.goback.push towId
        when '/kcsapi/api_req_map/start', '/kcsapi/api_req_map/next'
          combined = data.combined.state > 0
          {inBattle} = data.decks
          {goback} = data.combined
          {_ships, _slotitems, _decks} = window
          if path == '/kcsapi/api_req_map/start'
            if combined && parseInt(postBody.api_deck_id) == 1
              deckId = 0
              inBattle[0] = inBattle[1] = true
            else
              deckId = parseInt(postBody.api_deck_id) - 1
              inBattle[deckId] = true
          # Heavy damaged Alert
          escapeId = towId = -1
          damagedShips = []
          for deckId in [0..3]
            continue unless inBattle[deckId]
            deck = _decks[deckId]
            for shipId, idx in deck.api_ship
              continue if shipId == -1 or idx == 0
              ship = _ships[shipId]
              if ship.api_nowhp / ship.api_maxhp < 0.250001 and shipId not in goback
                # 应急修理要员/女神
                safe = false
                for slotId in ship.api_slot.concat(ship.api_slot_ex || -1)
                  continue if slotId == -1
                  safe = true if _slotitems[slotId].api_type[3] is 14
                if !safe
                  damagedShips.push("Lv. #{ship.api_lv} - #{ship.api_name}")
          if damagedShips.length > 0
            toggleModal __('Attention!'), damagedShips.join(' ') + __('is heavily damaged!')
      data.decks.state = _decks.map DI.getDeckState()
      @setState
        dataVersion: @state.dataVersion + 1
        data: data
    componentDidMount: ->
      window.addEventListener 'game.response', @handleResponse
    componentWillUnmount: ->
      window.removeEventListener 'game.response', @handleResponse
    shouldComponentUpdate: (nextProps, nextState)->
      # if ship-pane is visibile and dataVersion is changed, this pane should update!
      if nextProps.selectedKey is @props.index and nextState.dataVersion isnt @showDataVersion and !_.isEqual(prevState, nextState)
        @showDataVersion = nextState.dataVersion
        return true
      false
    # Conditional Renderer Sample
    # componentWillMount: ->
    #   if layout == 'horizontal'
    #     @render = ThemeRenderer || LayoutPortrait
    #   else
    #     @render = ThemeRenderer || LayoutLandscape
    render: ->
      <Panel bsStyle="default" >
        <link rel="stylesheet" href={join(relative(ROOT, __dirname), 'assets', 'omniship.css')} />
        <link rel="stylesheet" href={join(relative(ROOT, __dirname), 'assets', 'flex.css')} />
        <ButtonGroup>
        {
          for i in [0..3]
            <Button key={i} bsSize="small"
                            bsStyle={getStyle @state.data.decks.state[i]}
                            onClick={@handleClick.bind(this, i)}
                            className={if @state.activeDeck == i then 'active' else ''}>
              {@state.data.decks.names[i]}
            </Button>
        }
        </ButtonGroup>
        {
          {_decks} = window
          for deck, i in _decks
            <div className="ship-deck" className={if @state.activeDeck is i then 'show' else 'hidden'} key={i}>
              <PaneBody
                key={i}
                activeDeck={@state.activeDeck}
                data={@state.data}
              />
            </div>
          }
        }
      </Panel>
