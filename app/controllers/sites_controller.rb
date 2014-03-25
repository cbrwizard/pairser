class SitesController < ApplicationController
  include Links
  include Access
  before_action :require_admin, only: [:new, :edit, :create, :update, :destroy, :index, :show]

  before_action :set_site, only: [:show, :edit, :update, :destroy]

  # Parses a link and grabs all goods' info
  # @note POST /sites/parse
  # @todo create check for nil
  # @todo create redirect with notice
  # @todo create check for invalid image size
  # @todo create check for existing good by website
  # @todo create check if correct domain but can't find anything = wrong link
  def parse
    website = params[:url]
    website_domain = get_host_without_www(website)
    site_instruction = Site.find_by_domain(website_domain)
    if site_instruction.present?
      begin
        good = _parse_to_good(website, site_instruction)
        if good.persisted?
          redirect_to view_good_path(good.id), notice: 'Вещь добавлена!'
        end
      # If there was an error during parsing
      rescue Watir::Exception
        _form_site_error(website_domain)
        redirect_to root_path, alert: "Ошибка. Проверьте правильность ссылки или попробуйте позже. Администраторы уже работают над устранением ошибки!"
      end

    # If no instructions on how to parse url found
    else
      _form_parse_request(website_domain)
      redirect_to root_path, notice: "Мы пока не можем сохранить информацию с этого сайта. Но это лишь вопрос времени!"
    end

  end


  # Does the parsing
  # @note is called from sites#parse

  def _parse_to_good(website, site_instruction)
    browser = _prepare_browser(website)
    good = _create_good_essential(browser, site_instruction)

    # If other images are accessable without any actions
    if site_instruction.images_selector.present?
      _parse_other_images(browser, site_instruction, good)

    # If thumbnails must be clicked to get other images
    elsif site_instruction.button_selector.present?
      _parse_thumbnail_images(browser, site_instruction, good)
    end
    good
  end



  # Creates a browser and visits website
  def _prepare_browser(website)
    browser = Watir::Browser.new :phantomjs
    browser.goto website
    browser
  end

  # Creates a good with main info from url
  def _create_good_essential(browser, site_instruction)
    title = browser.element(css: site_instruction.name_selector).text

    main_image_path = browser.element(css: site_instruction.main_image_selector).attribute_value('src')
    main_image = Image.where(website: main_image_path).first_or_create

    good = current_user.goods.where(name: title, main_image_id: main_image.id).first_or_create

    main_image.good_id = good.id
    main_image.save
    good
  end


  # Gets other images
  # @note if there are instructions that there are aditional images on url
  # @todo do it without clicks
  def _parse_other_images(browser, site_instruction, good)
    buttons = browser.elements(css: site_instruction.images_selector)
    buttons.each do |button|
      if button.visible?
        begin
          button.click
          ad_image_path = browser.element(css: site_instruction.main_image_selector).attribute_value('src')
          Image.where(website: ad_image_path, good_id: good.id).first_or_create
        rescue
          "skipping image"
        end
      end
    end
  end


  # Gets images from thumbnails
  # @note if there are instructions that there are aditional images on url in thumbnails
  # @note clicks on thumbnails and gets big versions of them from main image selector
  def _parse_thumbnail_images(browser, site_instruction, good)
    buttons = browser.elements(css: site_instruction.button_selector)
    main_image_path = browser.element(css: site_instruction.main_image_selector).attribute_value('src')
    buttons.each do |button|
      if button.visible?
        begin
          button.click
          browser.wait_until{main_image_path != browser.element(css: site_instruction.main_image_selector).attribute_value('src')}
          ad_image_path = browser.element(css: site_instruction.main_image_selector).attribute_value('src')
          Image.where(website: ad_image_path, good_id: good.id).first_or_create!
        rescue
          "skipping image"
        end
      end
    end
  end



  # Creates a parse request for this domain
  # @note called from sites#parse if no instructions found
  # @param domain [String] website domain
  def _form_parse_request(domain)
    parse_request = ParseRequest.where(domain: domain).first_or_create
    parse_request.count += 1
    parse_request.save
  end


  # Creates a site error record for this domain
  # @note called from sites#parse if there were errors during parse
  # @param domain [String] website domain
  def _form_site_error(domain)
    site_error = SiteError.where(domain: domain).first_or_create
    site_error.count = 0
    site_error.count += 1
    site_error.save
  end

  # GET /sites
  # GET /sites.json
  def index
    @sites = Site.all
  end

  # GET /sites/1
  # GET /sites/1.json
  def show
  end

  # GET /sites/new
  def new
    @site = Site.new
  end

  # GET /sites/1/edit
  def edit
  end

  # POST /sites
  # POST /sites.json
  def create
    @site = Site.new(site_params)

    respond_to do |format|
      if @site.save
        format.html { redirect_to @site, notice: 'Site was successfully created.' }
        format.json { render action: 'show', status: :created, location: @site }
      else
        format.html { render action: 'new' }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sites/1
  # PATCH/PUT /sites/1.json
  def update
    respond_to do |format|
      if @site.update(site_params)
        format.html { redirect_to @site, notice: 'Site was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sites/1
  # DELETE /sites/1.json
  def destroy
    @site.destroy
    respond_to do |format|
      format.html { redirect_to sites_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_site
      @site = Site.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def site_params
      params.require(:site).permit(:domain, :name_selector, :main_image_selector, :images_selector, :button_selector)
    end
end
