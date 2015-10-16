{_, $, $$, React, ReactBootstrap, ROOT, toggleModal} = window
{$ships, $shipTypes, _ships, resolveTime} = window
{ProgressBar} = ReactBootstrap

###
@props.deckCondRemain
@props.deckRepairRemain
@props.akashiRemain
@props.getDeckMissionRemain
###
RecoveryBar = React.createClass
  componentWillUnmount: ->
    @interval = clearInterval @interval
  componentDidMount: ->
    #   $(".rec-progress-#{@props.deckIndex}.progress-bar").style.backgroundColor = "#28BDF4"
    # else if @props.missionTimer.remain? and@state.elapsed - @props.missionTimer.remain < 0
    #   $(".rec-progress-#{@props.deckIndex}.progress-bar").style.backgroundColor = "#747474"
    # else if @props.condTimer.remain? and @state.elapsed - @props.condTimer.remain < 0
    #   $(".rec-progress-#{@props.deckIndex}.progress-bar").style.backgroundColor = "#F4CD28"
    # else
    #   $(".rec-progress-#{@props.deckIndex}.progress-bar").style.backgroundColor = "#7FC135"
  render: ->
    <div>
      <link rel="stylesheet" href={join(relative(ROOT, __dirname), 'recoverybar.css')} />
      {
        switch @props.decksAddition.state[@props.deckIndex]
          when 0
            <ProgressBar key={1} className="rec-progress rec-progress-#{@props.deckIndex} ready" now={100} />
          when 1
            <ProgressBar key={1} className="rec-progress rec-progress-#{@props.deckIndex} akashi" now={100} />
          when 2
            <ProgressBar key={1} className="rec-progress rec-progress-#{@props.deckIndex} cond" now={100} />
          when 5
            <ProgressBar key={1} className="rec-progress rec-progress-#{@props.deckIndex} repair" now={100} />
          when 6
            <ProgressBar key={1} className="rec-progress rec-progress-#{@props.deckIndex} mission" now={100} />
      }
    </div>

module.exports = RecoveryBar
