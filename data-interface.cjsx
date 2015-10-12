{relative, join} = require 'path-extra'
{_, $, $$, React, ReactBootstrap, ROOT, toggleModal} = window
{$ships, $shipTypes, _ships} = window
{log, success, warn, error} = window
{OverlayTrigger, Tooltip, Overlay, Popover} = ReactBootstrap
{__, __n} = require 'i18n'

class DataInterface
  ############
  # Deck Information
  ############

  # Tyku
  # 制空値 = [(艦載機の対空値) × √(搭載数)] の総計 + 熟練補正
  # [T]
  getDeckTyku: (deck) ->
    {$ships, $slotitems, _ships, _slotitems} = window
    basicTyku = alvTyku = totalTyku = 0
    for shipId in deck.api_ship
      continue if shipId == -1
      ship = _ships[shipId]
      for itemId, slotId in ship.api_slot
        continue unless itemId != -1 && _slotitems[itemId]?
        item = _slotitems[itemId]
        # Basic tyku
        if item.api_type[3] in [6, 7, 8]
          basicTyku += Math.floor(Math.sqrt(ship.api_onslot[slotId]) * item.api_tyku)
        else if item.api_type[3] == 10 && item.api_type[2] == 11
          basicTyku += Math.floor(Math.sqrt(ship.api_onslot[slotId]) * item.api_tyku)
        # Alv
        if item.api_type[3] == 6 && item.api_alv > 0 && item.api_alv <= 7
          alvTyku += [0, 1, 4, 6, 11, 16, 17, 25][item.api_alv]
        else if item.api_type[3] in [7, 8] && item.api_alv == 7
          alvTyku += 3
        else if item.api_type[3] == 10 && item.api_type[2] == 11 && item.api_alv == 7
          alvTyku += 9
    totalTyku = basicTyku + alvTyku

    basic: basicTyku
    alv: alvTyku
    total: totalTyku

  # Saku (2-5 旧式)
  # 偵察機索敵値×2 ＋ 電探索敵値 ＋ √(艦隊の装備込み索敵値合計 - 偵察機索敵値 - 電探索敵値)
  # [T]
  getDeckSaku25: (deck) ->
    {$ships, $slotitems, _ships, _slotitems} = window
    reconSaku = shipSaku = radarSaku = 0
    for shipId in deck.api_ship
      continue if shipId == -1
      ship = _ships[shipId]
      shipSaku += ship.api_sakuteki[0]
      for itemId, slotId in ship.api_slot
        continue unless itemId != -1 && _slotitems[itemId]?
        item = _slotitems[itemId]
        switch item.api_type[3]
          when 9
            reconSaku += item.api_saku
            shipSaku -= item.api_saku
          when 10
            if item.api_type[2] == 10
              reconSaku += item.api_saku
              shipSaku -= item.api_saku
          when 11
            radarSaku += item.api_saku
            shipSaku -= item.api_saku
    reconSaku = reconSaku * 2.00
    shipSaku = Math.sqrt(shipSaku)
    totalSaku = reconSaku + radarSaku + shipSaku

    recon: parseFloat(reconSaku.toFixed(2))
    radar: parseFloat(radarSaku.toFixed(2))
    ship: parseFloat(shipSaku.toFixed(2))
    total: parseFloat(totalSaku.toFixed(2))

  # Saku (2-5 秋式)
  # 索敵スコア = 艦上爆撃機 × (1.04) + 艦上攻撃機 × (1.37) + 艦上偵察機 × (1.66) + 水上偵察機 × (2.00)
  #            + 水上爆撃機 × (1.78) + 小型電探 × (1.00) + 大型電探 × (0.99) + 探照灯 × (0.91)
  #            + √(各艦毎の素索敵) × (1.69) + (司令部レベルを5の倍数に切り上げ) × (-0.61)
  # [T]
  getDeckSaku25a: (deck) ->
    {$ships, $slotitems, _ships, _slotitems} = window
    totalSaku = shipSaku = itemSaku = teitokuSaku = 0
    for shipId in deck.api_ship
      continue if shipId == -1
      ship = _ships[shipId]
      shipPureSaku = ship.api_sakuteki[0]
      for itemId, slotId in ship.api_slot
        continue unless itemId != -1 && _slotitems[itemId]?
        item = _slotitems[itemId]
        shipPureSaku -= item.api_saku
        switch item.api_type[3]
          when 7
            itemSaku += item.api_saku * 1.04
          when 8
            itemSaku += item.api_saku * 1.37
          when 9
            itemSaku += item.api_saku * 1.66
          when 10
            if item.api_type[2] == 10
              itemSaku += item.api_saku * 2.00
            else if item.api_type[2] == 11
              itemSaku += item.api_saku * 1.78
          when 11
            if item.api_type[2] == 12
              itemSaku += item.api_saku * 1.00
            else if item.api_type[2] == 13
              itemSaku += item.api_saku * 0.99
          when 24
            itemSaku += item.api_saku * 0.91
      shipSaku += Math.sqrt(shipPureSaku) * 1.69
    teitokuSaku = 0.61 * Math.floor((window._teitokuLv + 4) / 5) * 5
    totalSaku = shipSaku + itemSaku - teitokuSaku

    ship: parseFloat(shipSaku.toFixed(2))
    item: parseFloat(itemSaku.toFixed(2))
    teitoku: parseFloat(teitokuSaku.toFixed(2))
    total: parseFloat(totalSaku.toFixed(2))

  # [T]
  getDeckLvInfo: (deck) ->
    {$ships, $slotitems, _ships} = window
    totalLv = totalShip = 0
    for shipId in deck.api_ship
      continue if shipId == -1
      ship = _ships[shipId]
      totalLv += ship.api_lv
      totalShip += 1
    avgLv = totalLv / totalShip

    totalLv: totalLv
    avgLv: parseFloat(avgLv.toFixed(0))

  # [T]
  getDeckSpeed: (deck) ->
    {$ships, $slotitems, _ships} = window
    # hi / low and more
    speed = 'hi'
    for shipId in deck.api_ship
      continue if shipId == -1
      ship = _ships[shipId]
      if ship?.api_soku < 10
        speed = 'low'
        break
    speed

  # [T]
  getDeckCost: (deck) ->
    {$ships, $slotitems, _ships} = window
    fuel = bullet = 0
    for shipId in deck.api_ship
      continue if shipId == -1
      ship = _ships[shipId]
      fuel += ship?.api_fuel_max
      bullet += ship?.api_bull_max

    fuel: fuel
    bullet: bullet

  # [ ] 50%
  getDeckCondRemain: (deck, condStamps) ->
    that = this
    remains = deck.api_ship.map (id) ->
      complete = that.getShipCondComplete(id, condStamps)
      if complete > 0
        complete - condStamps[id]
      else
        0
    longest = remains.reduce (a, b) -> Math.max(a, b)

  # [T]
  getDeckMissionRemain: (deck) ->
    if deck.api_mission[0] == 0
      return 0
    remain = deck.api_mission[2] - Date.now()

  # [T]
  getDeckRepairRemain: (deck, ndocks) ->
    remains = [0]
    repairings = []
    deck.api_ship.map (id) ->
      if id in window._ndocks
        repairings.push id
    if repairings.length == 0
      return 0
    for id in repairings
      for i, ndock of ndocks
        if id == ndock.api_ship_id
          remains.push ndock.api_complete_time
    maxRemain = remains.reduce (a, b) -> Math.max(a, b)
    if maxRemain == 0
      return 0
    else
      maxRemain - Date.now()

  # [T]
  isAkashiRepairing: (deck) ->
    {$ships, $slotitems, _slotitems, _ships, _ndocks} = window
    workShip = 19
    repairItem = 86
    if !deck?
      return false
    firstDeckId = deck.api_ship[0]
    firstDeck = $ships[_ships[firstDeckId].api_ship_id]
    akashi = firstDeck if firstDeck.api_stype is workShip
    myAkashi = _ships[firstDeckId]
    if (myAkashi.api_nowhp * 4 // myAkashi.api_maxhp) > 2
      akashiCapacity = 1
      for itemId in myAkashi.api_slot
        continue if itemId == -1
        if _slotitems[itemId].api_slotitem_id is repairItem
          akashiCapacity += 1
      for i in [1 .. akashiCapacity]
        ship = _ships[deck.api_ship[i]]
        if ship.api_nowhp < ship.api_maxhp and ship.api_id not in _ndocks
          return true
    return false

  # priority: ready | not suggested | can't sortie
  # 0: Cond > 30, Supplied, Repaired, In port      --- green
  # 1: Akashi Repairing                            --- bright blue
  # 2: low Cond < 30, but supplied                 --- light orange
  # 3: not supplied or medium damaged              --- orange
  # 4: heavy damage                                --- red
  # 5: Repairing                                   --- blue
  # 6: In mission                                  --- grey
  # 7: In map                                      --- primary / high contrast
  # [T]
  getDeckState: (deck, deckData) ->
    state = 0
    {$ships, _ships} = window
    if deckData.inBattle[deck.api_id - 1]
      return state = Math.max(state, 7)
    if deck.api_mission[0] > 0
      return state = Math.max(state, 6)
    for shipId in deck.api_ship
      continue if shipId == -1
      ship = _ships[shipId]
      shipInfo = $ships[ship.api_ship_id]
      # Repairing
      if shipId in window._ndocks
        return state = Math.max(state, 5)
      # heavy damaged
      if (ship.api_nowhp / ship.api_maxhp) < 0.25
        state = Math.max(state, 4)
      # damaged
      if (ship.api_nowhp / ship.api_maxhp) < 0.75
        state = Math.max(state, 3)
      # Not supplied
      if (ship.api_fuel / shipInfo.api_fuel_max) < 0.99 || (ship.api_bull / shipInfo.api_bull_max) < 0.99
        state = Math.max(state, 3)
      # low cond
      if ship.api_cond <= 30
        state = Math.max(state, 2)
    if @isAkashiRepairing(deck)
      state = Math.max(state, 1)
    state

  ###################
  # ship Information
  ###################
  # most directly from _ships[shipId]

  # [ ]
  # condStamps = {shipId: startTimeStamp, ...}
  getShipCondStamps: (condStamps) ->
    {$ships, _ships} = window
    for shipId, ship of _ships
      if ship.api_cond < 49
        if condStamps[ship.api_id]?
          # calibrate
          t = Date.now()
          while Math.abs(t - condStamps[ship.api_id]) > 3 * 60 * 1000
            t -= 3 * 60 * 1000
          if t < condStamps[ship.api_id]
            condStamps[ship.api_id] = t
          # clean
          complete = Math.ceil((49 - ship.api_cond) / 3) * (3 * 60 * 1000) + condStamps[ship.api_id]
          if complete > Date.now()
            delete condStamps[ship.api_id]
        else
          # new start
          condStamps[ship.api_id] = Date.now()
      else
        # stop
        delete condStamps[ship.api_id]
    condStamps

  # [T]
  getShipCondComplete: (shipId, condStamps) ->
    {$ships, _ships} = window
    ship = _ships[shipId]
    stamp = condStamps[shipId]
    complete = 0
    if shipId == -1 or ship.api_cond >= 49
      return complete
    if stamp?
      complete = Math.ceil((49 - ship.api_cond) / 3) * (3 * 60 * 1000) + stamp
    else
      console.log 'requesting unexist timestamp'
    complete

module.exports = DataInterface

### test code
deck = _decks[0];
path = require('path-extra');
data = {};
data.decks = {}; data.ships = {}; data.combined = {};
data.ships.condStamps = {};
omni = require(path.join(ROOT, 'plugins', 'compactview', 'parts', 'omniship'));
data.ships.condStamps = omni.DI.getShipCondStamps(data.ships.condStamps);
data.decks.inBattle = [false, false, false, false]
shipId = 4004;
omni.DI.getShipCondComplete(shipId, data.ships.condStamps);
resolveTime((omni.DI.getShipCondComplete(shipId, data.ships.condStamps) - Date.now()) / 1000);
###
