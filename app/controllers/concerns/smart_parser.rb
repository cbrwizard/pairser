# No instructions parser module
module SmartParser
  extend ActiveSupport::Concern

  # Parses a website without instructions from Site
  # @note looks for a largest image, then tries to find a common container with a heading. After that takes other images from that container and grabs images from meta tags.
  # @note is called from Parser#parse_to_good
  # @param browser [Watir::Browser] browser which checks everything
  # @param website [String] url of good
  # @return [Good] resulting good
  def parse_without_instructions(browser, website)

    main_image_exists, good_container, big_images, text = prepare_variables

    all_big_images = get_all_big_images(browser)
    largest_image = all_big_images.max

    # Finds main image
    unless largest_image.blank?
      main_image_src = largest_image[1]
      main_image_element = browser.image(src: main_image_src)

      main_image_exists, main_image_element = check_image_element(main_image_element, main_image_src, browser)
    end

    # If main image dom element was found after all (it may not be found)
    if main_image_exists
      good_container, text = find_container_and_text(main_image_element)
    end

    # If successfully found a goods container
    if good_container
      # Looks for other images in that container
      all_big_images.each do |image|
        src = image[1]
        image_element = good_container.image(src: src)
        image_exists, image_element = check_image_element(image_element, src, browser)

        big_images << image if image_exists
      end
    else
      text = browser.title
    end

    meta_images = find_meta_images(browser)
    big_images.concat meta_images

    if main_image_exists
      big_images = remove_image_dublicates(big_images.uniq, main_image_src)
      main_image = Image.create(website: main_image_src)
    else
      # Takes main image from additional images
      main_image = Image.create(website: big_images[0][1])
      big_images.delete_at(0)
    end

    smart_create_good(text, main_image, website, big_images)
  end


  # Prepares variables for parsing
  # @return [Boolean] by default, there is no main image
  # @return [Boolean] by default, there is no good container
  # @return [Boolean] by default, there is no other images
  # @return [Boolean] by default, there is no good heading
  def prepare_variables
    return false, false,[],''
  end


  # Gets all big images from website
  # @param browser [Watir::Browser] browser which checks everything
  # @todo Ignore images with 'logo' in name
  def get_all_big_images(browser)
    all_big_images = []
    browser.images.each do |image|
      src = image.src
      all_big_images << [FastImage.size(src).inject(:+), src] if image.visible? && is_ok_type?(src) && is_ok_size?(src)
      break if all_big_images.length >= 30 # in case of huge number of images
    end
    all_big_images.uniq
  end


  # Tries to locate image element on page
  # @note image_exists boolean is used because it works faster than browser checking
  # @param image_element [Watir DOM] - dom element where image 'should' exist
  # @param src [String] - url of image
  # @param browser [Watir::Browser] browser which checks everything
  # @return [Boolean] image_exists - if image was found in DOM
  # @return [Watir DOM] image_element - image DOM element
  def check_image_element(image_element, src, browser)
    # Checks if src is broken
    image_exists = false
    if image_element.exists?
      image_exists = true
    else
      # Removes http from start of src
      unless image_exists
        image_element = browser.image(src: src.sub(/^https?\:/, ''))
        if image_element.exists?
          image_exists = true
        end
      end

      # Removes http and www from start of src
      unless image_exists
        image_element = browser.image(src: src.sub(/^https?\:\/\//, '').sub(/^www./,''))
        if image_element.exists?
          image_exists = true
        end
      end

      # Removes http and www and domain from start of src
      unless image_exists
        image_element = browser.image(src: src.sub(/^https?\:\/\//, '').sub(/^www./,'').sub(get_host_without_www(src), ''))
        if image_element.exists?
          image_exists = true
        end
      end
    end
    return image_exists, image_element
  end


  # Tries to locate good' container and its' heading
  # @note checks by going up in DOM and looking for headings according to priority order
  # @param image_element [Watir DOM] - dom element where image exists
  # @return [Watir DOM] good_container - good container DOM element
  # @return [String] text - a heading text
  def find_container_and_text(image_element)
    good_container = false
    tmp_parent = image_element.parent
    text = ''
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
    return good_container, text
  end


  # Finds images in meta tags
  # @note checks for size and type
  # @param browser [Watir::Browser] browser which checks everything
  # @return [Array] meta images array
  def find_meta_images(browser)
    meta_images = []
    metas = browser.elements(css: "meta[property='og:image']")
    metas.each do |meta_image|
      src = meta_image.attribute_value('content')
      meta_images << [FastImage.size(src).inject(:+), src] if is_ok_type?(src) && is_ok_size?(src)
      break if meta_images.length >= 30 # in case of huge number of images
    end
    meta_images
  end


  # Checks for a copy of main image in big images
  # @note checks for different domains, paths, etc
  # @param big_images [Array] array of additional images
  # @param main_image_src [String] url of main image
  # @return [Array] additional images array
  def remove_image_dublicates(big_images, main_image_src)
    big_images_rel_paths = big_images.map{|img| img[1].sub(/^https?\:\/\//, '').sub(/^www./,'').sub(get_host_without_www(img[1]), '')}
    main_image_rel_path = main_image_src.sub(/^https?\:\/\//, '').sub(/^www./,'').sub(get_host_without_www(main_image_src), '')

    big_images.delete_at big_images_rel_paths.index(main_image_rel_path)
    big_images
  end


  # Creates a good using all info collected
  # @param text [String] heading of good
  # @param main_image [String] url of main image
  # @param website [String] url of good
  # @param big_images [Array] array of additional images
  # @return [Good] resulting good
  def smart_create_good(text, main_image, website, big_images)
    good = current_user.goods.where(name: text, main_image_id: main_image.id, website: website).first_or_create
    main_image.good_id = good.id
    main_image.save

    big_images.each do |image|
      Image.create(website: image[1], good_id: good.id)
    end
    good
  end
end

