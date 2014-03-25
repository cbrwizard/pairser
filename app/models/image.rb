# Good' image. Created during url parsing
# @example
#   #<Image id: 1, website: "http://cache.net-a-porter.com/images/products/45127...", good_id: 1, created_at: "2014-03-25 14:19:37", updated_at: "2014-03-25 14:19:37">
class Image < ActiveRecord::Base
  belongs_to :good
  validates_formatting_of :website, using: :url

  scope :ad_images_of_good, -> (good) {where(good_id: good.id).where.not(id: good.main_image_id)}
end
