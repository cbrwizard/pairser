class Good < ActiveRecord::Base
  has_many :images
  has_one :main_image, class_name: 'Image'
  belongs_to :user

  validates :user_id, presence: true

  # @return [String] ссылка на главное изображение товара
  def get_main_image_website
    Image.find(self.main_image_id).website
  end

end
