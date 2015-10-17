{relative, join} = require 'path-extra'
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
  # componentDidMount: ->
  render: ->
    <div className="recovery-bar">
      <link rel="stylesheet" href={join(relative(ROOT, __dirname), 'recoverybar.css')} />
      {
        switch @props.decksAddition?.state?[@props.deckIndex]
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
          when 7
            <ProgressBar key={1} className="rec-progress rec-progress-#{@props.deckIndex} battle" striped now={100} />
          else
            <ProgressBar bsStyle='success' key={1} className="rec-progress rec-progress-#{@props.deckIndex}" now={100} />
      }
    </div>

module.exports = RecoveryBar
