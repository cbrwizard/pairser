# Parser module
# @todo do it in Threads with ajax images uploading
module Parser
  include Links
  include ManualParser
  include SmartParser
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
    browser.close
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