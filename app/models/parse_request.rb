class ParseRequest < ActiveRecord::Base
  include AdminCount
  validates :domain, presence: true
end
