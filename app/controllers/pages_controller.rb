class PagesController < ApplicationController

  # Main page
  # @note GET /
  def index
  end

  # Admin main page
  # @note GET /admin
  # @note counts the number of requests and errors
  def admin
    @parse_requests_count = ParseRequest.errors_count
    @site_errors_count = SiteError.errors_count

  end
end
