{_, $, $$, React, ReactBootstrap, ROOT, FontAwesome, toggleModal} = window
{$ships, $shipTypes, _ships} = window
{Label} = ReactBootstrap

getShipStatus = (shipId) ->
  {_ships, _ndocks} = window
  status = -1
  # retreat status
  if escapeId? and shipId in @props.escapeId
    return status = 0
  # reparing
  if shipId in _ndocks
    return status = 1
  # special 1 locked phase 1
  else if _ships[shipId].api_sally_area == 1
    return status = 2
  # special 2 locked phase 2
  else if _ships[shipId].api_sally_area == 2
    return status = 3
  # special 3 locked phase 3
  else if  _ships[shipId].api_sally_area == 3
    return status = 4
  # special 3 locked phase 3
  else if _ships[shipId].api_sally_area == 4
    return status = 5
  return status

StatusLabelMini = React.createClass
  shouldComponentUpdate: (nextProps, nextState) ->
    not _.isEqual(nextProps.label, @props.label)
  render: ->
    if @props.label?
      switch @props.label
        when 0
          <Label bsStyle="danger"><FontAwesome key={0} name='exclamation-circle' /></Label>
        when 1
          <Label bsStyle="info"><FontAwesome key={0} name='wrench' /></Label>
        when 2
          <Label bsStyle="info"><FontAwesome key={0} name='lock' /></Label>
        when 3
          <Label bsStyle="primary"><FontAwesome key={0} name='lock' /></Label>
        when 4
          <Label bsStyle="success"><FontAwesome key={0} name='lock' /></Label>
        when 5
          <Label bsStyle="warning"><FontAwesome key={0} name='lock' /></Label>
        else
          <Label bsStyle="default" style={opacity: 0}></Label>

module.exports =
  reactClass: StatusLabelMini
  getShipStatus: getShipStatus
