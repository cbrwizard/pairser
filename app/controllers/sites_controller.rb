class SitesController < ApplicationController
  include Links

  before_action :set_site, only: [:show, :edit, :update, :destroy]
  layout "admin", only: [:new, :edit, :create, :update, :destroy, :index]

  # Parses a link and grabs all goods' info
  # @todo create check for nil
  # @todo create redirect with notice
  # @todo create check for invalid image
  # @todo create check for existing good by website
  # @todo create check if correct domain but can't find anything = wrong link
  def parse

    #
    website = params[:website]
    website_domain = get_host_without_www(website)
    site = Site.find_by_domain(website_domain)
    if site.present?
      #
      browser = Watir::Browser.new :phantomjs
      browser.goto website
      main_image_path = browser.element(css: site.main_image_selector).attribute_value('src')
      title = browser.element(css: site.name_selector).text


      #
      main_image = Image.where(website: main_image_path).first_or_create
      good = current_user.goods.where(name: title, main_image_id: main_image.id).first_or_create
      main_image.good_id = good.id
      main_image.save


      # If other images are accessable without any actions
      if site.images_selector.present?
        buttons = browser.elements(css: site.images_selector)
        buttons.each do |button|
          if button.visible?
            begin
              button.click
              ad_image_path = browser.element(css: site.main_image_selector).attribute_value('src')
              Image.where(website: ad_image_path, good_id: good.id).first_or_create
            rescue
              "skipping image"
            end
          end
        end
      # If thumbnails must be clicked to get other images
      elsif site.button_selector.present?
        buttons = browser.elements(css: site.button_selector)
        buttons.each do |button|
          if button.visible?
            begin
              button.click
              browser.wait_until{main_image_path != browser.element(css: site.main_image_selector).attribute_value('src')}
              ad_image_path = browser.element(css: site.main_image_selector).attribute_value('src')
              Image.where(website: ad_image_path, good_id: good.id).first_or_create
            rescue
              "skipping image"
            end
          end
        end
      end

      if good.persisted?
        redirect_to my_goods_path
      end
      # If no instructions on how to parse website found, increate count on requests
    else
      parse_request = ParseRequest.where(domain: website_domain).first_or_create
      parse_request.count += 1
      parse_request.save

      redirect_to my_goods_path, notice: "Мы пока не можем сохранить информацию с этого сайта. Но это вопрос времени!"
    end

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
