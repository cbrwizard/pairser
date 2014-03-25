class PagesController < ApplicationController

  def index
  end

  # Admin main page
  def admin
    @parse_requests_count = ParseRequest.count
    @site_errors_count = SiteError.count

  end
end
