# A website instruction for parser. Created by admin
# @example
#   #<Site id: 1, domain: "net-a-porter.com", name_selector: "#product-details h1", main_image_selector: "#medium-image", images_selector: "", button_selector: "#thumbnails-container img", created_at: "2014-03-25 14:19:37", updated_at: "2014-03-25 14:19:37">

class SiteError < ActiveRecord::Base
  include AdminCount
end
