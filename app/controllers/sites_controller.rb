class SitesController < ApplicationController
  include Links
  include Access
  include Parser

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
        good = parse_to_good(website, site_instruction)
        if good.persisted?
          redirect_to view_good_path(good.id), notice: 'Вещь добавлена!'
        end
      # If there was an error during parsing
      rescue Watir::Exception::UnknownObjectException, Selenium::WebDriver::Error::InvalidElementStateError
        form_site_error(website_domain)
        redirect_to root_path, alert: "Ошибка. Проверьте правильность ссылки или попробуйте позже. Администраторы уже работают над устранением ошибки!"
      end

    # If no instructions on how to parse url found
    else
      form_parse_request(website_domain)
      redirect_to root_path, notice: "Мы пока не можем сохранить информацию с этого сайта. Но это лишь вопрос времени!"
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
