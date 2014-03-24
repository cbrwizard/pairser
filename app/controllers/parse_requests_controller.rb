class ParseRequestsController < ApplicationController
  before_action :set_parse_request, only: [:show, :edit, :update, :destroy]
  layout "admin", only: [:new, :edit, :create, :update, :destroy, :index]

  # GET /parse_requests
  # GET /parse_requests.json
  def index
    @parse_requests = ParseRequest.all
  end

  # GET /parse_requests/1
  # GET /parse_requests/1.json
  def show
  end

  # GET /parse_requests/new
  def new
    @parse_request = ParseRequest.new
  end

  # GET /parse_requests/1/edit
  def edit
  end

  # POST /parse_requests
  # POST /parse_requests.json
  def create
    @parse_request = ParseRequest.new(parse_request_params)

    respond_to do |format|
      if @parse_request.save
        format.html { redirect_to @parse_request, notice: 'Parse request was successfully created.' }
        format.json { render action: 'show', status: :created, location: @parse_request }
      else
        format.html { render action: 'new' }
        format.json { render json: @parse_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /parse_requests/1
  # PATCH/PUT /parse_requests/1.json
  def update
    respond_to do |format|
      if @parse_request.update(parse_request_params)
        format.html { redirect_to @parse_request, notice: 'Parse request was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @parse_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /parse_requests/1
  # DELETE /parse_requests/1.json
  def destroy
    @parse_request.destroy
    respond_to do |format|
      format.html { redirect_to parse_requests_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_parse_request
      @parse_request = ParseRequest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def parse_request_params
      params.require(:parse_request).permit(:domain, :count)
    end
end
