$ ->
  $("[data-disable='sym']").click (e) ->
    $container = $(e.target).parents('.sym')
    $container.remove()
