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
    if @props.layout == 'expand'
      <div className={@name}>
        <link rel="stylesheet" href={join(relative(ROOT, __dirname), "#{@name}.css")} />
      {
        {$slotitems, _slotitems} = window
        for itemId, i in @props.data
          continue unless itemId != -1 && _slotitems[itemId]?
          item = _slotitems[itemId]
          <div key={i} className="slotitem-container">
            <OverlayTrigger placement='left' overlay={
              <Tooltip>
                {item.api_name}&nbsp;&nbsp;
                {if item.api_level > 0 then <strong style={color: '#45A9A5'}>★+{item.api_level}</strong> else ''}
                {
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
              </Tooltip>
            }>
              <img key={itemId} src={join('assets', 'img', 'slotitem', "#{item.api_type[3] + 100}.png")} />
            </OverlayTrigger>
            <span className="slotitem-onslot
                            #{if (item.api_type[3] >= 6 && item.api_type[3] <= 10) || (item.api_type[3] >= 21 && item.api_type[3] <= 22) || item.api_type[3] == 33 || i == 5 then 'show' else 'hide'}
                            #{if @props.onslot[i] < @props.maxeq[i] && i != 5 then 'text-warning' else ''}"
                            style={getBackdropStyle()}>
              {if i == 5 then '+' else @props.onslot[i]}
            </span>
          </div>
      }
      </div>
    else if @props.layout == 'mini'
      <div className="#{@name}-mini" style={display:"flex", flexFlow:"column"}>
        <link rel="stylesheet" href={join(relative(ROOT, __dirname), "#{@name}.css")} />
      {
        {$slotitems, _slotitems} = window
        for itemId, i in @props.data
          continue if itemId == -1
          item = _slotitems[itemId]
          <div key={i} className="slotitem-container">
            <img key={itemId} src={join('assets', 'img', 'slotitem', "#{item.api_type[3] + 100}.png")}} />
            <span className="slotitem-name">
              {item.api_name}
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
            <span className="slotitem-onslot
                             #{if (item.api_type[3] >= 6 && item.api_type[3] <= 10) || (item.api_type[3] >= 21 && item.api_type[3] <= 22) || item.api_type[3] == 33 then 'show' else 'hide'}"
                             bsStyle="#{if @props.onslot[i] < @props.maxeq[i] then 'warning' else 'default'}">
              {@props.onslot[i]}
            </span>
          </div>
      }
      </div>
    else
      <div></div>

module.exports = Slotitems
