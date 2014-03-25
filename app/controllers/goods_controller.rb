class GoodsController < ApplicationController
  include Access
  before_action :require_admin, only: [:new, :edit, :create, :update, :destroy, :show, :index]

  before_action :require_user_signed_in, only: [:my]
  before_action :set_good, only: [:show, :edit, :update, :destroy, :view]

  # List of user' goods
  def my
    @my_goods = current_user.goods
  end

  # GET /goods
  # GET /goods.json
  def index
    @goods = Good.all
  end

  # GET /goods/1
  # GET /goods/1.json
  def show
  end


  # User-friendly view of good
  # @note sortes images so that main one is first
  # @note GET /goods/1/view
  def view
    if belongs_to_user?(@good)
      @good_images = [@good.main_image] + @good.images.where.not(id: @good.main_image_id)
      @good_images.flatten!
    else
      redirect_to root_path, alert: 'Это не ваша сохраненная вещь'
    end
  end

  # GET /goods/new
  def new
    @good = Good.new
  end

  # GET /goods/1/edit
  def edit
  end

  # POST /goods
  # POST /goods.json
  def create
    @good = Good.new(good_params)

    respond_to do |format|
      if @good.save
        format.html { redirect_to @good, notice: 'Good was successfully created.' }
        format.json { render action: 'show', status: :created, location: @good }
      else
        format.html { render action: 'new' }
        format.json { render json: @good.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /goods/1
  # PATCH/PUT /goods/1.json
  def update
    respond_to do |format|
      if @good.update(good_params)
        format.html { redirect_to @good, notice: 'Good was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @good.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /goods/1
  # DELETE /goods/1.json
  def destroy
    @good.destroy
    respond_to do |format|
      format.html { redirect_to goods_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_good
      @good = Good.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def good_params
      params.require(:good).permit(:name, :main_image_id, :user_id)
    end
end
