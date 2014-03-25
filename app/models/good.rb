# Goods. They are created when parsed from url
# @example
#   #<Good id: 1, name: "FlyKnit Lunar1+ sneakers", main_image_id: 1, created_at: "2014-03-25 14:19:36", updated_at: "2014-03-25 14:19:36", user_id: 1>
class Good < ActiveRecord::Base
  has_many :images
  has_one :main_image, class_name: 'Image'
  belongs_to :user

  validates :user_id, presence: true

  # Gets url of goods' main image
  # @note is called in good' view
  # @example
  #   url = Good.first.get_main_image_website
  # @return [String] url of good' main image
  def get_main_image_website
    Image.find(self.main_image_id).website
  end

end
