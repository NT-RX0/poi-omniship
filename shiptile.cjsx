{relative, join} = require 'path-extra'
{_, $, $$, React, ReactBootstrap, ROOT, toggleModal} = window
{$ships, $shipTypes, _ships} = window
{Button, ButtonGroup} = ReactBootstrap
{ProgressBar, OverlayTrigger, Tooltip, Alert, Overlay, Label, Panel, Popover} = ReactBootstrap
{__, __n} = require 'i18n'

StatusLabelMini = require './statuslabelmini'
CondBar = require './condbar'
RecoveryBar = require './recovery-bar'
Slotitems = require './slotitems'

getHpStyle = (percent) ->
  if percent <= 25
    'danger'
  else if percent <= 50
    'warning'
  else if percent <= 75
    'primary'
  else
    'success'

getMaterialStyle = (percent) ->
  if percent <= 50
    'danger'
  else if percent <= 75
    'warning'
  else if percent < 100
    'primary'
  else
    'success'

getCondStyle = (cond) ->
  if cond > 84
    '#FCEB00'
  else if cond > 49
    '#FFBF00'
  else if cond < 20
    '#DD514C'
  else if cond < 30
    '#F37B1D'
  else if cond < 40
    '#FFC880'
  else
    '#FFF'

getStatusStyle = (status) ->
  if status?
    flag = status == 0 or status == 1 # retreat or repairing
    if flag? and flag
      return {opacity: 0.4}
  else
    return {}

ShipTile = React.createClass
  render: ->
    {ship, shipInfo, shipType, label} = @props
    <div className="ship-tile">
      <div className="status-label">
        <StatusLabelMini.reactClass label={label}/>
      </div>
      <div className="ship-item" style={getStatusStyle label}>
        <OverlayTrigger placement="top" overlay={
          <Tooltip>
            <Slotitems className="ship-slot" data={ship.api_slot.concat(ship.api_slot_ex || -1)} onslot={ship.api_onslot} maxeq={ship.api_maxeq} layout="mini"/>
          </Tooltip>
        }>
          <div className="ship-info" >
            <span className="ship-lv">
              Lv. {ship.api_lv}
            </span>
            <span className="ship-name">
              {shipInfo.api_name}
            </span>
            <span className="ship-cond" style={color:getCondStyle ship.api_cond}>
              ★{ship.api_cond}
            </span>
          </div>
        </OverlayTrigger>
        <div className="flex-row" style={width:"100%", marginTop:5}>
          <span className="ship-hp">
            <span className="ship-hp-text" style={flex: "none", display: "flex"}>
              {ship.api_nowhp} / {ship.api_maxhp}
            </span>
            <OverlayTrigger show = {ship.api_ndock_time} placement='bottom' overlay={<Tooltip>入渠时间：{resolveTime ship.api_ndock_time / 1000}</Tooltip>}>
              <ProgressBar style={flex: "auto"} bsStyle={getHpStyle ship.api_nowhp / ship.api_maxhp * 100} now={ship.api_nowhp / ship.api_maxhp * 100} />
            </OverlayTrigger>
            <span className="ship-fuelbullet" style={flex: "none"}>
              <ProgressBar bsStyle={getMaterialStyle ship.api_fuel / shipInfo.api_fuel_max * 100}
                           now={ship.api_fuel / shipInfo.api_fuel_max * 100} />
            </span>
            <span className="ship-fuelbullet" style={flex: "none"}>
              <ProgressBar bsStyle={getMaterialStyle ship.api_bull / shipInfo.api_bull_max * 100}
                           now={ship.api_bull / shipInfo.api_bull_max * 100} />
            </span>
          </span>
        </div>
      </div>
    </div>

module.exports = ShipTile
