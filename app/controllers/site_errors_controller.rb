# Site errors admin actions
class SiteErrorsController < ApplicationController
  before_action :set_site_error, only: [:show, :edit, :update, :destroy]

  # GET /site_errors
  # GET /site_errors.json
  def index
    @site_errors = SiteError.all
  end

  # GET /site_errors/1
  # GET /site_errors/1.json
  def show
  end

  # GET /site_errors/new
  def new
    @site_error = SiteError.new
  end

  # GET /site_errors/1/edit
  def edit
  end

  # POST /site_errors
  # POST /site_errors.json
  def create
    @site_error = SiteError.new(site_error_params)

    respond_to do |format|
      if @site_error.save
        format.html { redirect_to @site_error, notice: 'Site error was successfully created.' }
        format.json { render action: 'show', status: :created, location: @site_error }
      else
        format.html { render action: 'new' }
        format.json { render json: @site_error.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /site_errors/1
  # PATCH/PUT /site_errors/1.json
  def update
    respond_to do |format|
      if @site_error.update(site_error_params)
        format.html { redirect_to @site_error, notice: 'Site error was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @site_error.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /site_errors/1
  # DELETE /site_errors/1.json
  def destroy
    @site_error.destroy
    respond_to do |format|
      format.html { redirect_to site_errors_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_site_error
      @site_error = SiteError.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def site_error_params
      params.require(:site_error).permit(:domain)
    end
end
