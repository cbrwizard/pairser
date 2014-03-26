# Parser module which follows instructions
module ManualParser
  extend ActiveSupport::Concern

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


  # Creates a good with main info(text and main image) from url
  # @note is called from Parser#parse_to_good
  # @param site_instruction [Site] site instruction of this website
  # @param browser [Watir::Browser] browser which checks everything
  # @return [Good] resulting good
  def create_good_essential(browser, site_instruction)
    title = browser.element(css: site_instruction.name_selector).text

    main_image_object = browser.image(css: site_instruction.main_image_selector)
    main_image_path = main_image_object.attribute_value('src')
    main_image = Image.create(website: main_image_path)

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
        Image.create(website: ad_image_path, good_id: good.id) if is_ok_size?(ad_image_path)
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
          Image.create(website: ad_image_path, good_id: good.id) if is_ok_size?(ad_image_path)
        rescue
          "skipping image"
        end
      end
    end
  end
end