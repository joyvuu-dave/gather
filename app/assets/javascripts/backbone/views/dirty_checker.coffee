Mess.Views.DirtyChecker = Backbone.View.extend

  initialize: (params) ->
    params.helpers = params.helpers || []
    params.helpers.push(@datetimePickerHelper)
    @$el.dirtyForms
      helpers: params.helpers

  events:
    'click': 'foo'
    'dp.change': 'datetimePickerChanged'
    'cocoon:after-insert': 'cocoonChange'
    'cocoon:after-remove': 'cocoonChange'

  datetimePickerChanged: (e) ->
    # Event always fires on page load, so the first time, we just save the original value.
    if !@$(e.target).data('original-datetime')
      @$(e.target).data('original-datetime', e.date)

  cocoonChange: ->
    @$el.dirtyForms('rescan')

  # A helper that lets other code manually mark the form as dirty by adding the .dirty-flag class.
  customDirtyHelper:
    isDirty: ($node) ->
      if $node.is('form') then $node.hasClass('dirty-flag') else false
    setClean: ($node) ->
      $node.removeClass('dirty-flag') if $node.is('form')

  # A helper that checks datetimepickers for dirtiness. Works in conjunction with event above.
  datetimePickerHelper:
    isDirty: ($node) ->
      isDirty = false
      $node.find('.input-group.datetimepicker').each ->
        orig = $(this).data('original-datetime')
        current = $(this).data('DateTimePicker').date()
        if orig && current && !orig.isSame(current) || (!orig && !current)
          isDirty = true
          return false
      isDirty
