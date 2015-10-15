{relative, join} = require 'path-extra'
{_, $, $$, React, ReactBootstrap, ROOT, toggleModal} = window
{$ships, $shipTypes, _ships} = window
{Button, ButtonGroup, OverlayTrigger, Tooltip, Overlay, Popover, ProgressBar} = ReactBootstrap
{__, __n} = require 'i18n'

DeckInfo = React.createClass
  render: ->
    <link rel="stylesheet" href={"deckinfo.css"} />
    <div className="deck-info" style={display: "flex"}>
    {
      i = @props.deckIndex
      decksAddition = @props.decksAddition
      totalLv = decksAddition.lv[i].totalLv
      avgLv = decksAddition.lv[i].avgLv
      tyku = decksAddition.tyku[i]
      saku25 = decksAddition.saku25[i]
      saku25a = decksAddition.saku25a[i]
      speed = decksAddition.speed[i]
      cost = decksAddition.cost[i]
      if i? and decksAddition? and totallv? and avgLv? and tyku? and saku25? and saku25a? and speed? and cost?
        <span className="total-lv">Lv＋{totalLv?}</span>
        <span className="tyku">{__ 'Fighter Power'}: {tyku?}</span>
        <span className="saku">{__ 'LOS'}: {saku25a?}</span>
        <span className="speed">速度：{speed?}</span>
        <span className="cost">消耗：{cost?}</span>
      else
        <span>No Data</span>
    }
    </div>

module.exports = DeckInfo
