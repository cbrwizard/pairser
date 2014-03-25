# Admin/user access
module Access
  extend ActiveSupport::Concern

  # Redirects visitor to root if not admin
  # @note is called on admin pages
  def require_admin
    unless is_admin?
      redirect_to root_path, alert: 'Доступ только для администрации'
    end
  end


  # Checks if current_user is admin
  # @return [Boolean]
  def is_admin?
    current_user.try(:admin?)
  end


  # Checks if a good belongs to user
  # @note is called on goods/view
  # @param good [Active Record Single] Товар
  # @return [Boolean]
  def belongs_to_user?(good)
    good.user_id == current_user.try(:id)
  end


  # Redirects visitor if not signed in
  # @note is called on goods/my
  def require_user_signed_in
    unless user_signed_in?
      redirect_to root_path, alert: "Для этого нужно авторизоваться"
    end
  end
end