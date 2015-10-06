{_, $, $$, React, ReactBootstrap, ROOT, toggleModal} = window
{$ships, $shipTypes, _ships} = window
{Button, ButtonGroup} = ReactBootstrap
{ProgressBar} = ReactBootstrap

###
@todo: reset timer
###
RecoveryBar = React.createClass
  getInitialState: ->
    elapsed: 0
  updateCountdown: ->
    @setState
      elapsed: @state.elapsed + 1000
  componentWillUnmount: ->
    @interval = clearInterval @interval
  componentDidMount: ->
    # @interval = setInterval @updateCountdown, 1000 if !@interval?
    if @props.repairTimer.remain? and @state.elapsed - @props.repairTimer.remain < 0
      $(".miniship .rec-progress-#{@props.deckIndex}.progress-bar").style.backgroundColor = "#28BDF4"
    else if @props.missionTimer.remain? and@state.elapsed - @props.missionTimer.remain < 0
      $(".miniship .rec-progress-#{@props.deckIndex}.progress-bar").style.backgroundColor = "#747474"
    else if @props.condTimer.remain? and @state.elapsed - @props.condTimer.remain < 0
      $(".miniship .rec-progress-#{@props.deckIndex}.progress-bar").style.backgroundColor = "#F4CD28"
    else
      $(".miniship .rec-progress-#{@props.deckIndex}.progress-bar").style.backgroundColor = "#7FC135"
  componentDidUpdate: (prevProps, prevState) ->
    if @props.repairTimer.remain? and @state.elapsed - @props.repairTimer.remain < 0
      $(".miniship .rec-progress-#{@props.deckIndex}.progress-bar").style.backgroundColor = "#28BDF4"
    else if @props.missionTimer.remain? and @state.elapsed - @props.missionTimer.remain < 0
      $(".miniship .rec-progress-#{@props.deckIndex}.progress-bar").style.backgroundColor = "#747474"
    else if @props.condTimer.remain? and @state.elapsed - @props.condTimer.remain < 0
      $(".miniship .rec-progress-#{@props.deckIndex}.progress-bar").style.backgroundColor = "#F4CD28"
    else
      $(".miniship .rec-progress-#{@props.deckIndex}.progress-bar").style.backgroundColor = "#7FC135"
  render: ->
    if @props.repairTimer.remain? and @state.elapsed - @props.repairTimer.remain < 0
      <ProgressBar key={1} className="rec-progress-#{@props.deckIndex}"
      now={
        if @state.elapsed - @props.repairTimer.remain < 0
          (@props.repairTimer.total - @props.repairTimer.remain - 60000 + @state.elapsed) / @props.repairTimer.total * 100
        else
          100
        } />
    else if @props.missionTimer.remain? and @state.elapsed - @props.missionTimer.remain < 0
      <ProgressBar key={1} className="rec-progress-#{@props.deckIndex}"
      now={
        if @state.elapsed - @props.missionTimer.remain < 0
          (@props.missionTimer.total - @props.missionTimer.remain + @state.elapsed) / @props.missionTimer.total * 100
        else
          100
        } />
    else if @props.condTimer.remain? and @state.elapsed - @props.condTimer.remain < 0
      <ProgressBar key={1} className="rec-progress-#{@props.deckIndex}"
      now={
        if @state.elapsed - @props.condTimer.remain< 0
          (@props.condTimer.total - @props.condTimer.remain + @state.elapsed) / @props.condTimer.total * 100
        else
          100
        } />
    else
      <ProgressBar key={1} className="rec-progress rec-progress-#{@props.deckIndex}" now={100} />

module.exports = RecoveryBar
