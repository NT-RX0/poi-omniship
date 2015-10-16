{relative, join} = require 'path-extra'
{_, $, $$, React, ReactBootstrap, ROOT, toggleModal, FontAwesome} = window
{layout, tabbed} = window
{Button, ButtonGroup} = ReactBootstrap
{ProgressBar, OverlayTrigger, Tooltip, Alert, Overlay, Label, Panel, Popover} = ReactBootstrap
{__, __n} = require 'i18n'

DataInterface = require './data-interface'
PaneBody = require './panebody'

# customized renderers
{LayoutPortrait, LayoutLandscape} = require './renderers'
ThemeRenderer = window.ThemeRenderer?['#{@name}']

# TODO
# [x] 1. prepare data
#    [X] deck cond
#    [x] test code
#    [ ] akashi repair
# [X] 2. transform renderer
# [\] 3. rework layout
# [X] 4. add theme support
# [\] 5. add combined fleet, detailed fleet, battle fleet
# [ ] 6. add fleet title to data

escapeId = -1
towId = -1

#TODO: use css class instead of inline css
getStyle = (state) ->
  if state in [0..7]
    # priority: ready | not suggested | can't sortie
    # 0: Cond > 30, Supplied, Repaired, In port   --- green
    # 1: Akashi Repairing                         --- bright blue
    # 2: low Cond < 30, but supplied              --- light orange
    # 3: not supplied or medium damaged           --- orange
    # 4: heavy damage                             --- red
    # 5: Repairing                                --- blue
    # 6: In mission                               --- grey
    # 7: In map                                   --- primary / high contrast
    return ['#8BC34A', '#64B5F6', '#FBC02D', '#EF6C00', '#E53935', '#2196F3', '#009688', '#2E7D32'][state]
  ''

module.exports =
  name: 'omniship'
  priority: 100000.1
  displayName: <span><FontAwesome key={0} name='bars' /> 全能舰队</span>
  description: '舰队展示页面，展示所有舰队信息'
  reactClass: React.createClass
    DI: new DataInterface()
    getInitialState: ->
      activeDeck: 0
      dataVersion: 0
      showDataVersion: 0
      mode: 'detail'  # 'combined' / 'battle' / 'detail'
      data:
        decks: []
        decksAddition:
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
          condRemain: [0, 0, 0, 0]
          lv: []
          tyku: []
          saku25a: []
          saku25: []
          speed: []
          cost: []
        ships: {}
        shipsAddition:
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
    changeMode: (mode) ->
      @setState {mode: mode}
    updateDecksInfo: () ->
      data = @state.data
      lv = []
      tyku = []
      saku25a = []
      saku25 = []
      speed = []
      cost = []
      for deck, i in data.decks
        lv[i] = @DI.getDeckLvInfo(deck)
        tyku[i] = @DI.getDeckTyku(deck)
        saku25[i] = @DI.getDeckSaku25(deck)
        saku25a[i] = @DI.getDeckSaku25a(deck)
        speed[i] = @DI.getDeckSpeed(deck)
        cost[i] = @DI.getDeckCost(deck)
      data.decksAddition.lv = lv
      data.decksAddition.tyku = tyku
      data.decksAddition.saku25a = saku25a
      data.decksAddition.saku25 = saku25
      data.decksAddition.speed = speed
      data.decksAddition.cost = cost
      @setState {data: data}
    handleResponse: (e) ->
      {method, path, body, postBody} = e.detail
      {data} = @state
      flag = true
      switch path
        # TODO: 给粮舰 & 双飞
        when '/kcsapi/api_port/port'
          decks = @state.data.decks
          # update combined state
          if body.api_combined_flag?
            data.combined.state = body.api_combined_flag
          # update cond
          data.shipsAddition.condTimeStamps = @DI.getShipCondStamps(data.shipsAddition.condTimeStamps)
          deckCondRemain = []
          for deck, i in decks
            deckCondRemain[i] = @DI.getDeckCondRemain(deck, data.shipsAddition.condTimeStamps)
          data.decksAddition.condRemain = deckCondRemain
          # update akashi
          if @DI.isAkashiRepairing(decks[0])
            if data.decksAddition.akashiTimeStamp == 0
              data.decksAddition.akashiTimeStamp = Date.now()
          else
            data.decksAddition.akashiTimeStamp = 0
          # save ndocks
          data.decksAddition.ndocks = body.api_ndock
          # reset inbattle
          data.decksAddition.inBattle = [false, false, false, false]
          # reset goback
          data.combined.goback = []
        when '/kcsapi/api_req_hensei/change'
          decks = @state.data.decks
          # update akashi
          if @DI.isAkashiRepairing(decks[0])
            if data.decksAddition.akashiTimeStamp == 0
              data.decksAddition.akashiTimeStamp = Date.now()
          else
            data.decksAddition.akashiTimeStamp = 0
          # update deck cond
          deckCondRemain = []
          for deck, i in decks
            deckCondRemain[i] = @DI.getDeckCondRemain(deck, data.shipsAddition.condTimeStamps)
          data.decksAddition.condRemain = deckCondRemain
        when '/kcsapi/api_req_hokyu/charge', '/kcsapi/api_get_member/deck', '/kcsapi/api_get_member/ship_deck', '/kcsapi/api_get_member/ship2', '/kcsapi/api_req_kaisou/powerup', '/kcsapi/api_get_member/ndock', '/kcsapi/api_req_nyukyo/start', '/kcsapi/api_req_nyukyo/speedchange'
          decks = @state.data.decks
          # update cond
          data.shipsAddition.condTimeStamps = @DI.getShipCondStamps(data.shipsAddition.condTimeStamps)
          deckCondRemain = []
          for deck, i in decks
            deckCondRemain[i] = @DI.getDeckCondRemain(deck, data.shipsAddition.condTimeStamps)
          data.decksAddition.condRemain = deckCondRemain
        when '/kcsapi/api_get_member/ship3'
          decks = @state.data.decks
          # update cond
          data.shipsAddition.condTimeStamps = @DI.getShipCondStamps(data.shipsAddition.condTimeStamps)
          deckCondRemain = []
          for deck, i in decks
            deckCondRemain[i] = @DI.getDeckCondRemain(deck, data.shipsAddition.condTimeStamps)
          data.decksAddition.condRemain = deckCondRemain
        when '/kcsapi/api_req_kousyou/destroyship'
          # update cond
          shipId = parseInt postBody.api_ship_id
          delete data.shipsAddition.condTimeStamps[shipId]
        when '/kcsapi/api_req_map/start'
          # update deck state
          deckId = parseInt(postBody.api_deck_id) - 1
          data.decksAddition.inBattle[deckId] = true
        when '/kcsapi/api_req_sortie/battleresult', '/kcsapi/api_req_combined_battle/battleresult'
          decks = @state.data.decks
          # update goback ids
          if body.api_escape_flag? and body.api_escape_flag > 0
            escapeIdx = body.api_escape.api_escape_idx[0] - 1
            towIdx = body.api_escape.api_tow_idx[0] - 1
            escapeId = decks[escapeIdx // 6].api_ship[escapeIdx % 6]
            towId = decks[towIdx // 6].api_ship[towIdx % 6]
        when '/kcsapi/api_req_combined_battle/goback_port'
          if escapeId != -1 and towId != -1
            # console.log "退避：#{_ships[escapeId].api_name} 护卫：#{_ships[towId].api_name}"
            data.combined.goback.push escapeId
            data.combined.goback.push towId
        when '/kcsapi/api_req_map/start', '/kcsapi/api_req_map/next'
          combined = data.combined.state > 0
          decks = @state.data.decks
          {inBattle} = data.decksAddition
          {goback} = data.combined
          {_ships, _slotitems} = window
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
            deck = decks[deckId]
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
        else
          flag = false
      return unless flag
      data.decks = window._decks
      # update decks info
      @updateDecksInfo()
      state = []
      for i, deck of data.decks
        state[i] = @DI.getDeckState(deck, data.decksAddition)
      data.decksAddition.state = state
      @setState
        dataVersion: @state.dataVersion + 1
        data: data
    componentDidMount: ->
      window.addEventListener 'game.response', @handleResponse
    componentWillUnmount: ->
      window.removeEventListener 'game.response', @handleResponse
    shouldComponentUpdate: (nextProps, nextState)->
      # if ship-pane is visibile and dataVersion is changed, this pane should update!
      # TODO: add performance measurement
      if nextState.dataVersion isnt @showDataVersion or !_.isEqual(@state, nextState) or !_.isEqual(@props, nextProps)
        @showDataVersion = nextState.dataVersion
        return true
      false
    # # Conditional Renderer Sample
    # componentWillMount: ->
    #   if layout == 'horizontal'
    #     @render = ThemeRenderer || LayoutPortrait
    #   else
    #     @render = ThemeRenderer || LayoutLandscape
    render: ->
      {mode} = @state
      <Panel bsStyle="default" >
        <link rel="stylesheet" href={join(relative(ROOT, __dirname), 'assets', 'omniship.css')} />
        <link rel="stylesheet" href={join(relative(ROOT, __dirname), 'assets', 'flex.css')} />
        <div className="toolbar flex-row">
          <ButtonGroup>
          {
            for i in [0..3]
              <Button key={i} bsSize="small"
                              style={background: "#{getStyle @state.data.decksAddition.state[i]}"}
                              onClick={@handleClick.bind(this, i)}
                              className={if @state.activeDeck == i then 'active' else ''}>
                {@state.data.decksAddition.names[i]}
              </Button>
          }
          </ButtonGroup>
          <Button key={0} bsSize="small" onclick={@changeMode.bind(this, 'detail')} className="detail"><FontAwesome key={0} name="reorder"/></Button>
          <Button key={1} bsSize="small" onclick={@changeMode.bind(this, 'battle')} className="battle"><FontAwesome key={0} name="asterisk"/></Button>
          <Button key={2} bsSize="small" onclick={@changeMode.bind(this, 'combined')} className="combined">★</Button>
        </div>
          {
            if mode == 'combined'
              <div></div>
            else if mode == 'battle'
              <div></div>
            else if mode == 'detail'
              decks = @state.data.decks
              for deck, i in decks
                <div className="ship-deck" className={if @state.activeDeck is i then 'show' else 'hidden'} key={i}>
                  <PaneBody
                    key={i}
                    deckIndex={i}
                    activeDeck={@state.activeDeck}
                    data={@state.data}
                  />
                </div>
          }
      </Panel>
