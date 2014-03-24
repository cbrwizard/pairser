$ ->
  goods.init()

  $(".good_block").click ->
    window.location = $(this).attr("data-link")


goods =
  init: ->
    setTimeout(->
      goods.masonry_on()
    ,400)

  masonry_on: ->
    $("#my_goods").masonry({
      columnWidth: '.good_block',
      itemSelector: '.good_block'
    })
