class ParseRequest < ActiveRecord::Base
  validates_formatting_of :domain, using: :url
end
