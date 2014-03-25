# On goods/my and goods/view pages
$ ->
  goods.init()

  # When clicking on goods in /my opens goods/view page
  $(".good_block").click ->
    window.location = $(this).attr("data-link")

goods =
  # Initiates goods functions
  init: ->
    setTimeout(->
      goods.masonry_on()
    ,400)
    goods.carousel_on()


  # Enables masonry on /my
  masonry_on: ->
    $("#my_goods").masonry({
      columnWidth: '.good_block',
      itemSelector: '.good_block'
    })


  # Enables carousel on /view
  # @note shows controls if there are several images of good
  carousel_on: ->
    $(".item:first-child, .carousel-indicators li:first-child").addClass('active')
    $(".carousel").carousel()
    if $(".carousel-inner .item").length > 1
      $('.carousel-control, .carousel-indicators').removeClass('hidden')