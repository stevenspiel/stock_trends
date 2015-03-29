$ ->
  $("[data-destroy='sym']").click (e) ->
    $(e.target).parents('sym').remove()
