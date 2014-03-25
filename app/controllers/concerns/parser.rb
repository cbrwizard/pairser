# Parser module
# @todo do it in Threads with ajax images uploading
module Parser
  extend ActiveSupport::Concern


  # Does the parsing
  # @note is called from sites#parse
  def parse_to_good(website, site_instruction)
    browser = prepare_browser(website)
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
  def prepare_browser(website)
    browser = Watir::Browser.new :phantomjs
    browser.goto website
    browser
  end

  # Creates a good with main info from url
  def create_good_essential(browser, site_instruction)
    title = browser.element(css: site_instruction.name_selector).text

    main_image_path = browser.image(css: site_instruction.main_image_selector).attribute_value('src')
    if main_image_path.width > 99 && main_image_path.height > 99
      main_image = Image.where(website: main_image_path).first_or_create

      good = current_user.goods.where(name: title, main_image_id: main_image.id).first_or_create

      main_image.good_id = good.id
      main_image.save
      good
    else
      false
    end
  end


  # Gets other images
  # @note if there are instructions that there are aditional images on url
  def parse_other_images(browser, site_instruction, good)
    images = browser.elements(css: site_instruction.images_selector)
    images.each do |image|
      begin
        if image.width > 99 && image.height > 99
          ad_image_path = image.attribute_value('src')
          Image.where(website: ad_image_path, good_id: good.id).first_or_create
        end
      rescue
        "skipping image"
      end
    end
  end


  # Gets images from thumbnails
  # @note if there are instructions that there are aditional images on url in thumbnails
  # @note clicks on thumbnails and gets big versions of them from main image selector
  def parse_thumbnail_images(browser, site_instruction, good)
    buttons = browser.elements(css: site_instruction.button_selector)
    main_image_path = browser.element(css: site_instruction.main_image_selector).attribute_value('src')
    buttons.each do |button|
      if button.visible?
        begin
          button.click
          browser.wait_until{main_image_path != browser.element(css: site_instruction.main_image_selector).attribute_value('src')}
          if main_image_path.width > 99 && main_image_path.height > 99
            ad_image_path = browser.element(css: site_instruction.main_image_selector).attribute_value('src')
            Image.where(website: ad_image_path, good_id: good.id).first_or_create
          end
        rescue
          "skipping image"
        end
      end
    end
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