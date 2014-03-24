class PagesController < ApplicationController
  layout "admin", only: [:admin]

  def index
  end

  # Admin main page
  def admin

  end
end
