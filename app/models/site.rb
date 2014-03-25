class Site < ActiveRecord::Base
  #validates :name_selector, presence: true
  #validates :main_image_selector, presence: true
  validates :domain, presence: true
end
