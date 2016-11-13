class User < ActiveRecord::Base
  validates :openid,  presence: true, uniqueness: true
  validates :name,  presence: true
end
