# Links module
module Links
  extend ActiveSupport::Concern

  # Parses website domain without www
  # @param url [String] domain
  # @example
  #   website_domain = get_host_without_www('http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html')
  # @return [String] domain without www.
  def get_host_without_www(url)
    url = "http://#{url}" if URI.parse(url).scheme.nil?
    host = URI.parse(url).host.downcase
    host.start_with?('www.') ? host[4..-1] : host
  end
end