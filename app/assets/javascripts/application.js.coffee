# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require jquery_ujs
#= require bootstrap-sprockets
#= require select2
#= require highcharts/highstock
#= require moment
#= require_tree .
#= stub public

$ ->
  $('.select2-autocomplete').each (i, e) ->
    select = $(e)
    multiple = select.data('multiple')
    select.select2
      multiple: multiple
      dropdownCssClass: 'bigdrop'
      initSelection: (element, callback) ->
        ids = $(element).val()
        return unless ids.length
        return $.ajax select.data('initialize'),
          dataType: 'json'
          method: 'GET'
          data: { ids: ids }
        .done (data) ->
          callback(data)
      ajax:
        url: select.data('source')
        dataType: 'json'
        data: (term, page) -> { search_term: term }
        results: (data) ->
          results: data
