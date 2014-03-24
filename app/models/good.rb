class Good < ActiveRecord::Base
  has_many :images
  belongs_to :user


  # @return [String] ссылка на главное изображение товара
  def get_main_image_website
    Image.find(self.main_image_id).website
  end

end
