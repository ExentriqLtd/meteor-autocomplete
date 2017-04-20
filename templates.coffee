# Events on template instances, sent to the autocomplete class
acEvents =
  "keydown": (e, t) -> t.ac.onKeyDown(e)
  "keyup": (e, t) -> t.ac.onKeyUp(e)
  "focus": (e, t) -> t.ac.onFocus(e)
#  "blur": (e, t) -> t.ac.onBlur(e)

Template.inputAutocomplete.events(acEvents)
Template.textareaAutocomplete.events(acEvents)

attributes = -> _.omit(@, 'settings') # Render all but the settings parameter

autocompleteHelpers = {
  attributes,
  autocompleteContainer: new Template('AutocompleteContainer', ->
    ac = new AutoComplete( Blaze.getData().settings )
    # Set the autocomplete object on the parent template instance
    this.parentView.templateInstance().ac = ac

    # Set nodes on render in the autocomplete class
    this.onViewReady ->
      n = this.parentView.firstNode()
      n = $(n).find('input,textarea')
      ac.element = n[0]
      ac.$element = n
    return Blaze.With(ac, -> Template._autocompleteContainer)
  )
}

Template.inputAutocomplete.helpers(autocompleteHelpers)
Template.textareaAutocomplete.helpers(autocompleteHelpers)

Template.inputAutocomplete.onRendered ->
  @outsideClick = (evt) =>
    unless $(evt.target).closest('.autocomplete-wrapper, .-autocomplete-container').length
      @ac.onBlur(evt)
      @ac.hideList()
  $(document).on('click', @outsideClick)

Template.textareaAutocomplete.onRendered ->
  @outsideClick = (evt) =>
    unless $(evt.target).closest('.autocomplete-wrapper, .-autocomplete-container').length or $(evt.target).is(@.ac.$element)
      @ac.onBlur(evt)
      @ac.hideList()
  $(document).on('click', @outsideClick)

Template.inputAutocomplete.onDestroyed ->
  $(document).off('click', @outsideClick)

Template.textareaAutocomplete.onDestroyed ->
  $(document).off('click', @outsideClick)


Template._autocompleteContainer.rendered = ->
  @data.tmplInst = this

Template._autocompleteContainer.destroyed = ->
  # Meteor._debug "autocomplete destroyed"
  @data.teardown()

###
  List rendering helpers
###

Template._autocompleteContainer.events
  # t.data is the AutoComplete instance; `this` is the data item
  "click .autocomplete-selectable": (e, t) ->
    console.log('click')
    t.data.onItemClick(this, e)

  "click .-autocomplete-list>li": (e, t) ->
    if $(e.target).closest(t.data.matchedRule().itemClass || '.-autocomplete-item').length
      t.data.onItemClick(this, e)
  "mouseenter ": (e, t) ->
    if $(e.target).closest(t.data.matchedRule().itemClass || '.-autocomplete-item').length
      t.data.onItemHover(this, e)

Template._autocompleteContainer.helpers
  empty: ->
    return @filteredList()?.count() is 0

  updateCollapsible: ->
    Tracker.afterFlush ->
      $('.eq-ui-collapsible').eq_collapsible()

  index: ->
    return this.index()

  template: ->
    return @matchedRule().tailTemplate

  templateArgs: ->
    return @matchedRule().tailTemplateArgs

  prependTemplate: ->
    return @matchedRule().prependTemplate

  prependTemplateArgs: ->
    return @matchedRule().prependTemplateArgs || {}

  hide: ->
    return @matchedRule().hide?()

  hideTail: ->
    return @matchedRule().hideTail?()

  hidePrepend: ->
    return @matchedRule().hidePrepend?()

  removeHolder: ->
    return @matchedRule().removeHolder

  noMatchTemplate: ->
    @matchedRule().noMatchTemplate || Template._noMatch
