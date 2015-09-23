$ ->
  class window.Sym
    constructor: ->
      @bindSymDisableButton()

    bindSymDisableButton: ->
      $("[data-disable='sym']").click (e) ->
        e.preventDefault()
        $container = $(e.target).parents('.sym')
        id = $container.data('sym-id')
        $.ajax
          url: "/syms/#{id}/disable"
          type: 'POST'
          dataType: 'json'
          success: (data, status, xhr) ->
            $container.remove()
          error: (data, status, xhr) ->
            debugger
            alert 'There was an error disabling the sym.'

  new window.Sym if $("[data-disable='sym']").length
