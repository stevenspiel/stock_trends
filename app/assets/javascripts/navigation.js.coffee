$ ->
  window.Navigation =
    init: ->
      @$userNavToggle = $("[data-toggle='user-nav']")
      @$userNav = $("#user-nav")
      @setUserNavListener()

    setUserNavListener: ->
      @$userNavToggle.click =>
        @$userNav.toggle()
      $(document).click (e) =>
        unless $(event.target).closest("#user-nav, [data-toggle='user-nav']").length
          if @$userNav.is(":visible")
            @$userNav.hide()

  window.Navigation.init() if $("[data-toggle='user-nav']").length
