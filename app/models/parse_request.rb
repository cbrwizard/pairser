# User requests to add instructions to website. Created during url parsing when there is no instruction for website
# @example
#   #<ParseRequest id: 1, domain: "github.com", count: 1, created_at: "2014-03-25 16:21:13", updated_at: "2014-03-25 16:21:14">

class ParseRequest < ActiveRecord::Base
  include AdminCount
  validates :domain, presence: true
end
