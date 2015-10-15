{relative, join} = require 'path-extra'
{_, $, $$, React, ReactBootstrap, ROOT, toggleModal} = window
{$ships, $shipTypes, _ships} = window
{Button, ButtonGroup, OverlayTrigger, Tooltip, Overlay, Popover, ProgressBar} = ReactBootstrap
{__, __n} = require 'i18n'

DeckInfo = React.createClass
  render: ->
    <link rel="stylesheet" href={join(relative(ROOT, __dirname), "deckinfo.css")} />
    <div className="deck-info flex-column" >
      <span className="total-lv flex-row">Lv+: {@props.decksAddition.lv[@props.deckIndex].totalLv}</span>
      <span className="tyku flex-row">{__ 'Fighter Power'}: {@props.decksAddition.tyku[@props.deckIndex].total}</span>
      <span className="saku flex-row">{__ 'LOS'}: {@props.decksAddition.saku25a[@props.deckIndex].total}</span>
      <span className="speed flex-row">速度: {@props.decksAddition.speed[@props.deckIndex]}</span>
      <span className="cost flex-row">消耗: 油{@props.decksAddition.cost[@props.deckIndex].fuel} 弹{@props.decksAddition.cost[@props.deckIndex].bullet}</span>
    </div>

module.exports = DeckInfo
