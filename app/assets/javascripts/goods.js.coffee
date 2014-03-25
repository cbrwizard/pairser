$ ->
  goods.init()

  $(".good_block").click ->
    window.location = $(this).attr("data-link")

goods =
  init: ->
    setTimeout(->
      goods.masonry_on()
    ,400)
    goods.carousel_on()

  masonry_on: ->
    $("#my_goods").masonry({
      columnWidth: '.good_block',
      itemSelector: '.good_block'
    })

  carousel_on: ->
    $(".item:first-child, .carousel-indicators li:first-child").addClass('active')
    $(".carousel").carousel()
    if $(".carousel-inner .item").length > 1
      $('.carousel-control, .carousel-indicators').removeClass('hidden')