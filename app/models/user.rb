# A user. Created by user. Can be admin
# @example
#   #<User id: 1, email: "admin@lol.ru", encrypted_password: "$2a$10$nFF3s4XcUvPrHsMzcef6Pu1qqCyZL0N3NHpOuYmfXJ0c...", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: "2014-03-25 15:40:16", sign_in_count: 2, current_sign_in_at: "2014-03-25 15:40:16", last_sign_in_at: "2014-03-25 14:19:48", current_sign_in_ip: "127.0.0.1", last_sign_in_ip: "127.0.0.1", created_at: "2014-03-25 14:19:36", updated_at: "2014-03-25 15:40:16", admin: true>

class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :goods
end
