{relative, join} = require 'path-extra'
{$, $$, _, React, ReactBootstrap, ROOT} = window
{OverlayTrigger, Tooltip} = ReactBootstrap

getBackdropStyle = ->
  if window.isDarkTheme
    backgroundColor: 'rgba(33, 33, 33, 0.7)'
  else
    backgroundColor: 'rgba(256, 256, 256, 0.7)'

Slotitems = React.createClass
  name: 'slotitems'
  render: ->
    <div className={@name}>
      <link rel="stylesheet" href={join(relative(ROOT, __dirname), "#{@name}.css")} />
      <link rel="stylesheet" href={join(relative(ROOT, __dirname), "flex.css")} />
    {
      {$slotitems, _slotitems} = window
      <OverlayTrigger placement='top' overlay={
        <Tooltip className="flex-column">
        {
          for itemId, i in @props.data
            continue unless itemId != -1 && _slotitems[itemId]?
            item = _slotitems[itemId]
            <span key={i} className="tooltip-container flex-row">
              <span className="tooltip-name flex-row">
                {item.api_name}
                <span className="item-improvement flex-row">
                  {if item.api_level > 0 then <strong style={color: '#45A9A5'}>★+{item.api_level}</strong> else ''}
                  &nbsp;&nbsp;{
                    if item.api_alv? and item.api_alv >=1 and item.api_alv <= 3
                      for j in [1..item.api_alv]
                        <strong key={j} style={color: '#3EAEFF'}>|</strong>
                    else if item.api_alv? and item.api_alv >= 4 and item.api_alv <= 6
                      for j in [1..item.api_alv - 3]
                        <strong key={j} style={color: '#F9C62F'}>\</strong>
                    else if item.api_alv? and item.api_alv >= 7 and item.api_alv <= 9
                      <strong key={j} style={color: '#F9C62F'}> <FontAwesome key={0} name='angle-double-right'/> </strong>
                    else if item.api_alv? and item.api_alv >= 9
                      <strong key={j} style={color: '#F94D2F'}>★</strong>
                    else ''
                  }&nbsp;&nbsp;
                </span>
              </span>
              <span className="tooltip-onslot
                               #{if (item.api_type[3] >= 6 && item.api_type[3] <= 10) || (item.api_type[3] >= 21 && item.api_type[3] <= 22) || item.api_type[3] == 33 then 'show' else 'hide'}"
                               bsStyle="#{if @props.onslot[i] < @props.maxeq[i] then 'warning' else 'default'}">
                {@props.onslot[i]}
              </span>
            </span>
        }
        </Tooltip>
      }>
      {
        <div className="slotitem-container flex-row">
        {
          for itemId, i in @props.data
            continue unless itemId != -1 && _slotitems[itemId]?
            item = _slotitems[itemId]
            <span key={i} className="slotitem-unit">
              <img key={itemId} src={join('assets', 'img', 'slotitem', "#{item.api_type[3] + 100}.png")} />
              <span className="slotitem-onslot
                              #{if (item.api_type[3] >= 6 && item.api_type[3] <= 10) || (item.api_type[3] >= 21 && item.api_type[3] <= 22) || item.api_type[3] == 33 || i == 5 then 'show' else 'hide'}
                              #{if @props.onslot[i] < @props.maxeq[i] && i != 5 then 'text-warning' else ''}"
                              style={getBackdropStyle()}>
                {if i == 5 then '+' else @props.onslot[i]}
              </span>
            </span>
        }
        </div>
      }
      </OverlayTrigger>
    }
    </div>

module.exports = Slotitems
