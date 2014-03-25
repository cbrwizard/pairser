require 'active_support/concern'

# For model counting
# @note on admin page
# @see SiteError
# @see ParseRequest
module AdminCount
  extend ActiveSupport::Concern

  included do
    scope :errors_count, -> {sum :count}
  end
end