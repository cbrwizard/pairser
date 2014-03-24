class Image < ActiveRecord::Base
  belongs_to :good
  validates_formatting_of :website, using: :url
end
