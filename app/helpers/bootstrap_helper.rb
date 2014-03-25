# Handles bootstrap-to-rails integration
module BootstrapHelper

  # Renders bootstrap error from flash
  # @param flash_type [Flash]
  # @return [String] CSS class of alert
  def alert_class_for flash_type
    case flash_type
      when :success
        "alert-success"
      when :error
        "alert-danger"
      when :alert
        "alert-warning"
      when :notice
        "alert-info"
      else
        flash_type.to_s
    end
  end
end
