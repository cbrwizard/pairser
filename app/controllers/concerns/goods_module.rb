# Goods module
module GoodsModule
  extend ActiveSupport::Concern

  # Checks if a good belongs to user
  # @note is called on goods/view
  # @param good [Active Record Single] Товар
  # @return [Boolean]
  def belongs_to_user?(good)
    good.user_id == current_user.try(:id)
  end
end