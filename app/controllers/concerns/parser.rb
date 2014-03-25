# Parser module
# @todo do it in Threads with ajax images uploading
module Parser
  extend ActiveSupport::Concern

  # Does the parsing
  # @note is called from sites#parse
  # @param website [String] url of good
  # @param site_instruction [Site] site instruction of this website
  # @return [Good] resulting good
  def parse_to_good(website, site_instruction, website_domain)
    browser = prepare_browser(website)
    begin
      if site_instruction.present?
        good = parse_with_instructions(browser, site_instruction)
      else
      # If no instructions on how to parse url found
        good = parse_without_instructions(browser)
        form_parse_request(website_domain)
      end
      # If there was an error during parsing
    rescue Watir::Exception::UnknownObjectException, Selenium::WebDriver::Error::InvalidElementStateError
      form_site_error(website_domain)
      redirect_to root_path, alert: "Ошибка. Проверьте правильность ссылки или попробуйте позже. Администраторы уже работают над устранением ошибки!"
    end
    good
  end


  # Parses a website without instructions from Site
  # @note is called from Parser#parse_to_good
  # @param browser [Watir::Browser] browser which checks everything
  # @return [Good] resulting good
  def parse_without_instructions(browser)

    # Finds all images with size > 99px
    all_big_images = []
    browser.images.each do |image|
      src = image.src
      all_big_images << [FastImage.size(src).inject(:+), src] if FastImage.size(src)[0] > 99 && FastImage.size(src)[1] > 99
    end
    largest_image = all_big_images.max

    # Finds largest image
    main_image_src = largest_image[1]
    main_image_element = browser.image(src: main_image_src)

    # Checks if src is broken
    unless main_image_element.exists?
      # Removes 'http:' from start of src
      main_image_element = browser.image(src: main_image_src.slice(5..-1))
    end

    # If main image dom element was found after all
    if main_image_element.exists?
      # Tries to find a common parent of image and headings
      tmp_parent = main_image_element.parent
      good_container = false
      for i in 0 .. 5
        if tmp_parent.h1.exists? || tmp_parent.h2.exists?
          good_container = tmp_parent
          break
        end
        tmp_parent = tmp_parent.parent
      end

      # Successfully found a goods container
      if good_container
        h1 = good_container.h1
        if h1.exists?
          text = h1.text
        else
          h2 = good_container.h2
          text = h2.text
        end

        # Looks for other images in that container
        big_images = []
        good_container.images.each do |image|
          src = image.src
          big_images << [FastImage.size(src).inject(:+), src] if FastImage.size(src)[0] > 99 && FastImage.size(src)[1] > 99
        end
      else
        text = browser.title
      end
    end
    good
  end


  # Parses a website following instructions from Site
  # @note is called from Parser#parse_to_good
  # @param browser [Watir::Browser] browser which checks everything
  # @param site_instruction [Site] site instruction of this website
  # @see Site
  # @return [Good] resulting good
  def parse_with_instructions(browser, site_instruction)
    good = create_good_essential(browser, site_instruction)

    # If other images are accessable without any actions
    if site_instruction.images_selector.present?
      parse_other_images(browser, site_instruction, good)

    # If thumbnails must be clicked to get other images
    elsif site_instruction.button_selector.present?
      parse_thumbnail_images(browser, site_instruction, good)
    end
    good
  end


  # Creates a browser and visits website
  # @note is called from Parser#parse_to_good
  # @param website [String] url of good
  # @return [Watir::Browser] browser which checks everything
  def prepare_browser(website)
    browser = Watir::Browser.new :phantomjs
    browser.window.resize_to(2000, 2000)
    browser.goto website
    browser
  end


  # Creates a good with main info(text and main image) from url
  # @note is called from Parser#parse_to_good
  # @param site_instruction [Site] site instruction of this website
  # @param browser [Watir::Browser] browser which checks everything
  # @return [Good] resulting good
  def create_good_essential(browser, site_instruction)
    title = browser.element(css: site_instruction.name_selector).text

    main_image_object = browser.image(css: site_instruction.main_image_selector)
    main_image_path = main_image_object.attribute_value('src')
    main_image = Image.where(website: main_image_path).first_or_create

    good = current_user.goods.where(name: title, main_image_id: main_image.id).first_or_create
    main_image.good_id = good.id
    main_image.save
    good
  end


  # Gets other images
  # @note is called from Parser#parse_to_good
  # @note if there are instructions that there are aditional images on url
  # @param site_instruction [Site] site instruction of this website
  # @param browser [Watir::Browser] browser which checks everything
  # @param good [Good] a good saved with main info
  def parse_other_images(browser, site_instruction, good)
    images = browser.images(css: site_instruction.images_selector)
    images.each do |image|
      begin
        ad_image_path = image.attribute_value('src')
        Image.where(website: ad_image_path, good_id: good.id).first_or_create if is_ok_size?(ad_image_path)
      rescue
        "skipping image"
      end
    end
  end


  # Gets images from thumbnails
  # @note is called from Parser#parse_to_good
  # @note if there are instructions that there are aditional images on url in thumbnails
  # @note clicks on thumbnails and gets big versions of them from main image selector
  # @param site_instruction [Site] site instruction of this website
  # @param browser [Watir::Browser] browser which checks everything
  # @param good [Good] a good saved with main info
  def parse_thumbnail_images(browser, site_instruction, good)
    buttons = browser.elements(css: site_instruction.button_selector)
    main_image_object = browser.image(css: site_instruction.main_image_selector)
    main_image_path = main_image_object.attribute_value('src')
    buttons.each do |button|
      if button.visible?
        begin
          button.click
          browser.wait_until{main_image_path != browser.element(css: site_instruction.main_image_selector).attribute_value('src')}
          ad_image_path = browser.element(css: site_instruction.main_image_selector).attribute_value('src')
          Image.where(website: ad_image_path, good_id: good.id).first_or_create if is_ok_size?(ad_image_path)
        rescue
          "skipping image"
        end
      end
    end
  end


  # Checks if image size is okay
  # @note is called from Parser methods
  # @param image_path [String] url to image
  # @return [Boolean]
  def is_ok_size?(image_path)
    FastImage.size(image_path)[0] > 99 && FastImage.size(image_path)[1] > 99
  end


  # Creates a parse request for this domain
  # @note called from sites#parse if no instructions found
  # @param domain [String] website domain
  def form_parse_request(domain)
    parse_request = ParseRequest.where(domain: domain).first_or_create
    parse_request.count += 1
    parse_request.save
  end


  # Creates a site error record for this domain
  # @note called from sites#parse if there were errors during parse
  # @param domain [String] website domain
  def form_site_error(domain)
    site_error = SiteError.where(domain: domain).first_or_create
    site_error.count = 0
    site_error.count += 1
    site_error.save
  end
end