class ParseRequest < ActiveRecord::Base
  validates :domain, presence: true
end
