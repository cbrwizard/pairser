# No instructions parser module
module SmartParser
  extend ActiveSupport::Concern

  # Parses a website without instructions from Site
  # @note is called from Parser#parse_to_good
  # @param browser [Watir::Browser] browser which checks everything
  # @return [Good] resulting good
  def parse_without_instructions(browser)
    #browser.goto 'http://www.pinterest.com/pin/219761656791055032/'
    #browser.goto 'http://www.wildberries.ru/catalog/1265257/detail.aspx'
    #browser.goto 'http://www.pandora.net/en-us/explore/products/bracelets#!590715CSP-M'
    #browser.goto 'http://www.net-a-porter.com/product/367278?cm_sp=we_recommend-_-367278-_-slot2'
    #browser.goto 'http://www.boden.co.uk/en-GB/Mens-Shirts/Semi-Fitted/MA397-PNK/Mens-Pink-Stripe-Washed-Oxford-Shirt.html?orcid=-71#cs0'
    #browser.goto 'http://valerygold.ru/magazin/product/kolco-0341.2.0.0-8'
    #browser.goto 'http://www.incity.ru/catalog/oz_13/vo_iskusstvennaya_koja/395948.html'
    # Finds all images with size > 99px
    all_big_images = []
    browser.images.each do |image|
      src = image.src
      all_big_images << [FastImage.size(src).inject(:+), src] if image.visible? && [:gif, :png, :jpeg, :bmp, :tiff].include?(FastImage.type(src)) && FastImage.size(src)[0] > 99 && FastImage.size(src)[1] > 99
      break if all_big_images.length >= 30 # in case of huge number of images
    end
    all_big_images.uniq!
    largest_image = all_big_images.max

    # Finds largest image
    main_image_src = largest_image[1]
    main_image_element = browser.image(src: main_image_src)

    # def check_image(image_element, src)
    main_image_exists = false
    # Checks if src is broken
    if main_image_element.exists?
      main_image_exists = true
    else
      # Removes 'http:' from start of src
      unless main_image_exists
        main_image_element = browser.image(src: main_image_src.sub(/^https?\:/, ''))
        if main_image_element.exists?
          main_image_exists = true
        end
      end

      # Removes http and www from start of src
      unless main_image_exists
        main_image_element = browser.image(src: main_image_src.sub(/^https?\:\/\//, '').sub(/^www./,''))
        if main_image_element.exists?
          main_image_exists = true
        end
      end

      # Removes http and www and domain from start of src
      unless main_image_exists
        main_image_element = browser.image(src: main_image_src.sub(/^https?\:\/\//, '').sub(/^www./,'').sub(get_host_without_www(main_image_src), ''))
        if main_image_element.exists?
          main_image_exists = true
        end
      end
    end

    # If main image dom element was found after all
    if main_image_exists

      # Tries to find a common parent of image and headings
      tmp_parent = main_image_element.parent
      good_container = false
      for i in 0..10
        itemprop_name = tmp_parent.element(css: "[itemprop='name']")
        if itemprop_name.exists?
          text = itemprop_name.text
          good_container = tmp_parent
          break
        else
          h1 = tmp_parent.h1
          if h1.exists?
            text = h1.text
            good_container = tmp_parent
            break
          else
            h2 = tmp_parent.h2
            if h2.exists?
              text = h2.text
              good_container = tmp_parent
              break
            else
              h3 = tmp_parent.h3
              if h3.exists?
                text = h3.text
                good_container = tmp_parent
                break
              end
            end
          end
        end
        tmp_parent = tmp_parent.parent
      end
    end

    big_images = []
    # Successfully found a goods container
    if good_container
      # Looks for other images in that container

      all_big_images.each do |image|
        src = image[1]
        image_element = good_container.image(src: src)

        image_exists = false
        # Checks if src is broken
        if image_element.exists?
          image_exists = true
        else
          # Removes 'http:' from start of src
          unless image_exists
            image_element = good_container.image(src: src.sub(/^https?\:/, ''))
            if image_element.exists?
              image_exists = true
            end
          end

          # Removes http and www from start of src
          unless image_exists
            image_element = good_container.image(src: src.sub(/^https?\:\/\//, '').sub(/^www./,''))
            if image_element.exists?
              image_exists = true
            end
          end

          # Removes http and www and domain from start of src
          unless image_exists
            image_element = good_container.image(src: src.sub(/^https?\:\/\//, '').sub(/^www./,'').sub(get_host_without_www(src), ''))
            if image_element.exists?
              image_exists = true
            end
          end
        end
        # Checks if src is broken
        unless image_element.exists?

          # Removes 'http:' from start of src
          unless image_element.exists?
            image_element = good_container.image(src: image[1].slice(5..-1))
          end
        end
        big_images << image if src != main_image_src && image_element.exists?
      end
    else
      text = browser.title
    end

    meta_images = []
    metas = browser.elements(css: "meta[property='og:image']")
    metas.each do |meta_image|
      src = meta_image.attribute_value('content')
      meta_images << [FastImage.size(src).inject(:+), src] if [:gif, :png, :jpeg, :bmp, :tiff].include?(FastImage.type(src)) && FastImage.size(src)[0] > 99 && FastImage.size(src)[1] > 99
      break if meta_images.length >= 30 # in case of huge number of images
    end
    big_images.concat meta_images
    big_images.uniq!


    # Finds copy of main image without domain, etc
    big_images_rel_paths = big_images.map{|img| img[1].sub(/^https?\:\/\//, '').sub(/^www./,'').sub(get_host_without_www(img[1]), '')}
    main_image_rel_path = main_image_src.sub(/^https?\:\/\//, '').sub(/^www./,'').sub(get_host_without_www(main_image_src), '')

    big_images.delete_at big_images_rel_paths.index(main_image_rel_path)

    main_image_src
    text
    big_images

    #
    main_image = Image.create(website: main_image_src)
    good = current_user.goods.where(name: text, main_image_id: main_image.id).first_or_create
    main_image.good_id = good.id
    main_image.save

    #
    big_images.each do |image|
      ad_image_path = image[1]
      Image.create(website: ad_image_path, good_id: good.id)
    end

    good
  end
end