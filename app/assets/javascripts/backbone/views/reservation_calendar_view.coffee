Gather.Views.ReservationCalendarView = Backbone.View.extend

  URL_PARAMS_TO_VIEW_TYPES:
    'day': 'agendaDay'
    'week': 'agendaWeek'
    'month': 'month'

  initialize: (options) ->
    @newUrl = options.newUrl
    @baseUrl = options.baseUrl
    @calendar = @$('#calendar')
    @ruleSet = options.ruleSet
    @resourceId = options.resourceId
    @storageKey = "calendar#{@resourceId}Settings"

    @calendar.fullCalendar
      events: options.feedUrl
      defaultView: @initialViewType(options.viewType, options.defaultViewType)
      defaultDate: options.focusDate || @savedSettings().currentDate
      height: 700
      allDaySlot: false
      eventOverlap: false
      selectable: @ruleSet.access_level != "read_only"
      selectOverlap: false
      selectHelper: true
      header:
        left: 'title'
        center: 'agendaDay,agendaWeek,month'
        right: 'today prev,next'
      select: @onSelect.bind(this)
      windowResize: @onWindowResize.bind(this)
      viewRender: @onViewRender.bind(this)
      loading: @onLoading.bind(this)
      eventDrop: @onEventChange.bind(this)
      eventResize: @onEventChange.bind(this)

  events:
    'click .modal .btn-primary': 'create'

  onSelect: (start, end, _, view) ->
    modal = @$('#create-confirm-modal')
    body = modal.find('.modal-body')
    changedInterval = false

    # If month view, default selection is 12am to 12am, which is weird.
    # Change to 12:00 - 13:00 instead. This works better with fixed times.
    if view.name == "month" && start.hours() == 0 && end.hours() == 0
      start.hours(12)
      end.hours(13)
      end.days(end.days() - 1)

    # Apply fixed times and handle change if occurs
    [start, end, changed] = @applyFixedTimes(start, end)
    if changed
      if @hasEventInInterval(start, end)
        @calendar.fullCalendar 'unselect'
      else
        @calendar.fullCalendar 'select', start, end
      return

    # Save for create method to use.
    @selection =
      start: start.format(Gather.TIME_FORMATS.machineDatetime)
      end: end.format(Gather.TIME_FORMATS.machineDatetime)

    # Build confirmation string
    if (start.format('YYYYMMDD') == end.format('YYYYMMDD'))
      date = start.format(Gather.TIME_FORMATS.regDate)
      startTime = start.format(Gather.TIME_FORMATS.regTime)
      endTime = end.format(Gather.TIME_FORMATS.regTime)
      body.html("Reserve on <b>#{date}</b> from <b>#{startTime}</b> to <b>#{endTime}</b>?")
    else
      startTime = start.format(Gather.TIME_FORMATS.fullDatetime)
      endTime = end.format(Gather.TIME_FORMATS.fullDatetime)
      body.html("Reserve from <b>#{startTime}</b> to <b>#{endTime}</b>?")

    modal.modal('show')

  onWindowResize: ->
    @setViewForWidth()

  onViewRender: ->
    @updatePermalink()
    @saveSettings()

  onLoading: (isLoading) ->
    Gather.loadingIndicator[if isLoading then 'show' else 'hide']()

  onEventChange: (event, _, revertFunc) ->
    $.ajax
      url: "/reservations/#{event.id}"
      method: "POST"
      data:
        _method: "PATCH"
        reservation_reservation:
          starts_at: event.start.format()
          ends_at: event.end.format()
      error: (xhr) =>
        revertFunc()
        Gather.errorModal.modal('show').find('.modal-body').html(xhr.responseText)

  updatePermalink: ->
    @$('#permalink').attr('href', @permalink())

  setViewForWidth: ->
    @calendar.fullCalendar('changeView', 'agendaDay') if @forceDay()

  forceDay: ->
    $(window).width() < 640

  create: ->
    # newUrl includes a QS param already so we use '&'
    window.location.href = "#{@newUrl}&#{$.param(@selection)}"

  initialViewType: (linkParam, defaultType) ->
    type = @forceDay() && 'day' || linkParam || @savedSettings().viewType || defaultType || 'week'
    @URL_PARAMS_TO_VIEW_TYPES[type]

  permalink: ->
    @baseUrl.replace("placeholder=xxx", "view=#{@viewType()}&date=#{@currentDate()}")

  viewType: ->
    @calendar.fullCalendar('getView').name.replace('agenda', '').toLowerCase()

  currentDate: ->
    @calendar.fullCalendar('getView').intervalStart.format(Gather.TIME_FORMATS.compactDate)

  hasEventInInterval: (start, end) ->
    matches = @calendar.fullCalendar 'clientEvents', (event) ->
      event.start.isBefore(end) && event.end.isAfter(start)
    matches.length > 0

  applyFixedTimes: (start, end) ->
    fixedStart = @ruleSet.fixed_start_time && $.fullCalendar.moment(@ruleSet.fixed_start_time)
    fixedEnd = @ruleSet.fixed_end_time && $.fullCalendar.moment(@ruleSet.fixed_end_time)
    changed = false

    if fixedStart && fixedStart.format('HHmm') != start.format('HHmm')
      start = @nearestFixedTime(start, fixedStart)
      length = end.diff(start)
      end = $.fullCalendar.moment(start).add(length)
      changed = true

    if fixedEnd && fixedEnd.format('HHmm') != end.format('HHmm')
      end = @nearestFixedTime(end, fixedEnd)
      changed = true

    end.add(1, 'day') if end.isBefore(start)

    [start, end, changed]

  # Gets the moment nearest to selectedTime with the hours and minutes of fixedTime.
  nearestFixedTime: (selectedTime, fixedTime) ->
    today = $.fullCalendar.moment(selectedTime)
    today.hours(fixedTime.hours()).minutes(fixedTime.minutes())

    if selectedTime.isBefore(today)
      nearest = $.fullCalendar.moment(today).subtract(1, 'day')
    else
      nearest = today

    nearest.add(1, 'days') if selectedTime.diff(nearest, 'hours', true) > 12

    nearest

  savedSettings: ->
    settings = JSON.parse(window.localStorage.getItem(@storageKey) || '{}')

    # currentDate setting expires after one hour
    if settings.savedAt
      settingsAge = moment.duration(moment().diff(moment(settings.savedAt))).asSeconds()
      delete settings.currentDate if settingsAge > 3600

    settings

  saveSettings: ->
    window.localStorage.setItem(@storageKey, JSON.stringify(
      viewType: @viewType()
      currentDate: @currentDate()
      savedAt: new Date()
    ))
